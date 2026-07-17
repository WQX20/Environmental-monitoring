import fs from 'node:fs'
import http from 'node:http'

function loadLocalEnv() {
  const envPath = new URL('./.env', import.meta.url)
  if (!fs.existsSync(envPath)) {
    return
  }

  const envText = fs.readFileSync(envPath, 'utf8')
  for (let line of envText.split(/\r?\n/)) {
    const trimmed = line.trim()
    if (trimmed.length === 0 || trimmed.startsWith('#')) {
      continue
    }

    const equalsIndex = trimmed.indexOf('=')
    if (equalsIndex <= 0) {
      continue
    }

    const key = trimmed.slice(0, equalsIndex).trim()
    const value = trimmed.slice(equalsIndex + 1).trim()
    if (key.length > 0 && process.env[key] === undefined) {
      process.env[key] = value
    }
  }
}

loadLocalEnv()

const PORT = Number.parseInt(process.env.PORT || '3000', 10)
const MODE = (process.env.AI_BACKEND_MODE || 'mock').toLowerCase()
const MODEL_API_URL = process.env.MODEL_API_URL || ''
const MODEL_API_KEY = process.env.MODEL_API_KEY || ''
const MODEL_NAME = process.env.MODEL_NAME || 'gpt-4o-mini'

function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization'
  })
  res.end(JSON.stringify(payload))
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let body = ''
    req.on('data', (chunk) => {
      body += chunk
      if (body.length > 1_000_000) {
        reject(new Error('request body too large'))
        req.destroy()
      }
    })
    req.on('end', () => resolve(body))
    req.on('error', reject)
  })
}

function buildPrompt(payload) {
  return [
    '你是一个智慧环境生活管家的AI助手。',
    '请根据输入的场景、环境数据、设备状态和最近操作，输出 1 到 3 条简短建议。',
    '要求：',
    '1. 只输出 JSON，不要输出额外说明。',
    '2. JSON 结构为 {"suggestions":[{"title":"","detail":"","actionLabel":"","actionType":"","category":"","icon":""}] }。',
    '3. category 只能是 环境/健康/学习/节能 之一。',
    '4. actionType 可用 none/openWindow/startDevice/rest。',
    '',
    '输入数据：',
    JSON.stringify(payload, null, 2)
  ].join('\n')
}

function buildChatPrompt(payload) {
  return [
    '你是一个智慧环境生活管家的AI助手。',
    '请根据输入的本地环境数据直接回答用户问题。',
    '要求：',
    '1. 用中文回答，简洁明确，尽量控制在 3 句话以内。',
    '2. 如果需要，优先结合环境数据、场景模式、设备状态和最近操作来分析。',
    '3. 不要输出 JSON，不要复述全部原始数据。',
    '4. 如果信息不足，可以明确说明“根据当前数据推测”。',
    '',
    '输入数据：',
    JSON.stringify(payload, null, 2)
  ].join('\n')
}

function buildMockSuggestions(payload) {
  const env = payload?.currentEnv || {}
  const suggestions = []

  if (typeof env.co2 === 'number' && env.co2 > 800) {
    suggestions.push({
      title: 'CO2 偏高，建议通风',
      detail: `当前 CO2 为 ${env.co2} ppm，建议短时开窗通风。`,
      actionLabel: '记录已开窗',
      actionType: 'openWindow',
      category: '环境',
      icon: '◫'
    })
  }

  if (typeof env.humidity === 'number' && env.humidity < 40) {
    suggestions.push({
      title: '湿度偏低，建议加湿',
      detail: `当前湿度为 ${env.humidity}% ，适合开启加湿器。`,
      actionLabel: '开启加湿器',
      actionType: 'startDevice',
      category: '环境',
      icon: '❖'
    })
  }

  if (typeof env.noise === 'number' && env.noise > 60) {
    suggestions.push({
      title: '噪声偏高，注意专注',
      detail: `当前噪声为 ${env.noise} dB，建议减少干扰。`,
      actionLabel: '知道了',
      actionType: 'none',
      category: '健康',
      icon: '♪'
    })
  }

  if (suggestions.length === 0) {
    suggestions.push({
      title: '环境状态良好',
      detail: '当前环境整体较稳定，可以继续保持监测。',
      actionLabel: '知道了',
      actionType: 'none',
      category: '环境',
      icon: '◉'
    })
  }

  return { suggestions: suggestions.slice(0, 3) }
}

function normalizeModelSuggestions(content) {
  if (!content) {
    return []
  }

  try {
    const parsed = JSON.parse(content)
    if (Array.isArray(parsed)) {
      return parsed
    }
    if (Array.isArray(parsed.suggestions)) {
      return parsed.suggestions
    }
  } catch {
    // fallback to plain text
  }

  return [{
    title: '模型建议',
    detail: String(content).slice(0, 120),
    actionLabel: '知道了',
    actionType: 'none',
    category: '环境',
    icon: '✦'
  }]
}

function extractModelContent(data) {
  return data?.choices?.[0]?.message?.content || data?.output_text || data?.answer || ''
}

async function requestModelCompletion(messages) {
  if (!MODEL_API_URL) {
    return ''
  }

  const response = await fetch(MODEL_API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(MODEL_API_KEY ? { Authorization: `Bearer ${MODEL_API_KEY}` } : {})
    },
    body: JSON.stringify({
      model: MODEL_NAME,
      messages: messages,
      temperature: 0.3
    })
  })

  if (!response.ok) {
    throw new Error(`upstream error: ${response.status}`)
  }

  const data = await response.json()
  return String(extractModelContent(data) || '')
}

async function fetchModelSuggestions(payload) {
  if (!MODEL_API_URL) {
    return buildMockSuggestions(payload)
  }

  const content = await requestModelCompletion([
    { role: 'system', content: '你是一个环境监测建议助手，只输出 JSON。' },
    { role: 'user', content: buildPrompt(payload) }
  ])
  const suggestions = normalizeModelSuggestions(content)
  return { suggestions: suggestions.slice(0, 3) }
}

function buildMockChatAnswer(payload) {
  const env = payload?.currentEnv || {}
  const question = String(payload?.question || '')
  const parts = []

  if (typeof env.co2 === 'number' && env.co2 > 800) {
    parts.push(`当前 CO2 偏高（${env.co2}ppm），优先注意通风。`)
  }
  if (typeof env.pm25 === 'number' && env.pm25 > 75) {
    parts.push(`PM2.5 也偏高（${env.pm25}），建议减少开窗并开启净化器。`)
  }
  if (typeof env.humidity === 'number' && env.humidity < 40) {
    parts.push(`湿度偏低（${env.humidity}%），长时间待着会偏干，可以考虑加湿。`)
  }
  if (typeof env.noise === 'number' && env.noise > 60) {
    parts.push(`噪声较高（${env.noise}dB），如果你在专注或休息，建议先降低干扰。`)
  }

  if (parts.length === 0) {
    parts.push('根据当前数据，环境整体比较稳定，可以继续保持监测。')
  }

  if (question.length > 0) {
    parts.unshift(`你问的是：${question}。`)
  }

  return parts.slice(0, 3).join(' ')
}

async function fetchModelChatAnswer(payload) {
  if (!MODEL_API_URL) {
    return buildMockChatAnswer(payload)
  }

  return requestModelCompletion([
    { role: 'system', content: '你是一个智慧环境生活管家的AI助手，请根据本地环境数据回答用户问题，简洁自然。' },
    { role: 'user', content: buildChatPrompt(payload) }
  ])
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization'
    })
    res.end()
    return
  }

  if (req.method === 'GET' && req.url === '/health') {
    sendJson(res, 200, { ok: true, mode: MODE })
    return
  }

  if (req.method === 'POST' && req.url === '/ai/advice') {
    try {
      const bodyText = await readBody(req)
      const payload = bodyText ? JSON.parse(bodyText) : {}

      if (MODE === 'proxy' && MODEL_API_URL) {
        const result = await fetchModelSuggestions(payload)
        sendJson(res, 200, result)
        return
      }

      sendJson(res, 200, buildMockSuggestions(payload))
    } catch (error) {
      sendJson(res, 500, {
        error: 'failed_to_generate_advice',
        message: error instanceof Error ? error.message : 'unknown error'
      })
    }
    return
  }

  if (req.method === 'POST' && req.url === '/ai/chat') {
    try {
      const bodyText = await readBody(req)
      const payload = bodyText ? JSON.parse(bodyText) : {}
      const answer = await fetchModelChatAnswer(payload)
      sendJson(res, 200, { answer: answer || '我暂时没有获取到可用回复。' })
    } catch (error) {
      sendJson(res, 500, {
        error: 'failed_to_generate_chat_answer',
        message: error instanceof Error ? error.message : 'unknown error'
      })
    }
    return
  }

  sendJson(res, 404, { error: 'not_found' })
})

server.listen(PORT, () => {
  console.log(`AI backend listening on http://127.0.0.1:${PORT}`)
  console.log(`mode=${MODE}`)
})
