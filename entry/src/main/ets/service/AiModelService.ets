// ============================================================
// AI 模型接入服务 — 仅负责请求后端并转换为建议数据
// ============================================================
import http from '@ohos.net.http'
import { AppState, EnvironmentData, Suggestion, SuggestionCategory } from '../model/DataModels'
import { AI_MODEL_CONFIG, ICONS } from '../data/Constants'

interface AiModelRequestPayload {
  scene: string
  currentEnv: EnvironmentData
  deviceSummary: string[]
  recentOperations: string[]
}

interface AiModelSuggestionItem {
  title: string
  detail: string
  actionLabel?: string
  actionType?: string
  category?: string
  icon?: string
}

interface AiModelResponseBody {
  suggestions?: AiModelSuggestionItem[]
}

interface AiChatRequestPayload {
  question: string
  scene: string
  currentEnv: EnvironmentData
  deviceSummary: string[]
  recentOperations: string[]
}

interface AiChatResponseBody {
  answer?: string
}

function decodeUtf8Bytes(bytes: Uint8Array): string {
  let encoded = ''
  for (let index = 0; index < bytes.length; index++) {
    encoded += `%${bytes[index].toString(16).padStart(2, '0')}`
  }
  return decodeURIComponent(encoded)
}

function readResponseText(result: string | Object | ArrayBuffer | Uint8Array | undefined): string {
  if (typeof result === 'string') {
    return result
  }
  if (result instanceof ArrayBuffer) {
    return decodeUtf8Bytes(new Uint8Array(result))
  }
  if (result instanceof Uint8Array) {
    return decodeUtf8Bytes(result)
  }
  return ''
}

function buildDeviceSummary(state: AppState): string[] {
  let summaries: string[] = []
  for (let device of state.devices) {
    let status = device.isOn ? '开启' : '关闭'
    summaries.push(`${device.name}:${status},目标${device.targetValue}${device.unit}`)
  }
  return summaries
}

function buildChatEndpoint(): string {
  let endpoint = AI_MODEL_CONFIG.endpoint.replace(/\/$/, '')
  if (endpoint.endsWith('/advice')) {
    return endpoint.replace(/\/advice$/, '/chat')
  }
  return `${endpoint}/chat`
}

function buildLocalChatAnswer(state: AppState, question: string): string {
  let env = state.currentEnv
  let parts: string[] = []

  if (env.co2 > 800) {
    parts.push(`当前 CO2 偏高（${env.co2}ppm），优先注意通风。`)
  }
  if (env.pm25 > 75) {
    parts.push(`PM2.5 也偏高（${env.pm25}），建议减少开窗并开启净化器。`)
  }
  if (env.humidity < 40) {
    parts.push(`湿度偏低（${env.humidity}%），长时间待着会偏干，可以考虑加湿。`)
  }
  if (env.noise > 60) {
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

function mapCategory(category?: string): SuggestionCategory {
  if (category === SuggestionCategory.HEALTH) return SuggestionCategory.HEALTH
  if (category === SuggestionCategory.STUDY) return SuggestionCategory.STUDY
  if (category === SuggestionCategory.ENERGY) return SuggestionCategory.ENERGY
  return SuggestionCategory.ENV
}

function mapIcon(icon?: string, category?: SuggestionCategory): string {
  if (icon && icon.length > 0) {
    return icon
  }
  if (category === SuggestionCategory.HEALTH) return ICONS.catHealth
  if (category === SuggestionCategory.STUDY) return ICONS.catStudy
  if (category === SuggestionCategory.ENERGY) return ICONS.catEnergy
  return ICONS.catEnv
}

function toSuggestion(item: AiModelSuggestionItem, index: number): Suggestion {
  let category = mapCategory(item.category)
  return {
    id: `ai-model-${Date.now()}-${index}`,
    timestamp: Date.now(),
    category: category,
    title: item.title,
    detail: item.detail,
    actionLabel: item.actionLabel || '知道了',
    actionType: item.actionType || 'none',
    icon: mapIcon(item.icon, category)
  }
}

export async function fetchModelSuggestions(state: AppState): Promise<Suggestion[]> {
  if (!AI_MODEL_CONFIG.enabled || AI_MODEL_CONFIG.endpoint.length === 0) {
    return []
  }

  let request = http.createHttp()
  try {
    let payload: AiModelRequestPayload = {
      scene: state.currentScene,
      currentEnv: state.currentEnv,
      deviceSummary: buildDeviceSummary(state),
      recentOperations: state.operationHistory.slice(0, 5)
    }

    let response = await request.request(AI_MODEL_CONFIG.endpoint, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json'
      },
      extraData: JSON.stringify(payload),
      connectTimeout: AI_MODEL_CONFIG.timeoutMs,
      readTimeout: AI_MODEL_CONFIG.timeoutMs
    })

    let bodyText = readResponseText(response.result)
    if (bodyText.length === 0) {
      return []
    }

    let body = JSON.parse(bodyText) as AiModelResponseBody
    let rawList = body.suggestions || []
    let results: Suggestion[] = []
    let maxCount = AI_MODEL_CONFIG.maxSuggestions < rawList.length ? AI_MODEL_CONFIG.maxSuggestions : rawList.length
    for (let index = 0; index < maxCount; index++) {
      results.push(toSuggestion(rawList[index], index))
    }
    return results
  } catch (error) {
    return []
  } finally {
    request.destroy()
  }
}

export async function fetchChatAnswer(state: AppState, question: string): Promise<string> {
  let trimmedQuestion = question.trim()
  if (trimmedQuestion.length === 0) {
    return ''
  }

  if (!AI_MODEL_CONFIG.enabled || AI_MODEL_CONFIG.endpoint.length === 0) {
    return buildLocalChatAnswer(state, trimmedQuestion)
  }

  let request = http.createHttp()
  try {
    let payload: AiChatRequestPayload = {
      question: trimmedQuestion,
      scene: state.currentScene,
      currentEnv: state.currentEnv,
      deviceSummary: buildDeviceSummary(state),
      recentOperations: state.operationHistory.slice(0, 5)
    }

    let response = await request.request(buildChatEndpoint(), {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json'
      },
      extraData: JSON.stringify(payload),
      connectTimeout: AI_MODEL_CONFIG.timeoutMs,
      readTimeout: AI_MODEL_CONFIG.timeoutMs
    })

    let bodyText = readResponseText(response.result)
    if (bodyText.length === 0) {
      return buildLocalChatAnswer(state, trimmedQuestion)
    }

    try {
      let body = JSON.parse(bodyText) as AiChatResponseBody
      if (body.answer && body.answer.length > 0) {
        return body.answer
      }
    } catch {
      return bodyText
    }

    return bodyText.length > 0 ? bodyText : buildLocalChatAnswer(state, trimmedQuestion)
  } catch (error) {
    return buildLocalChatAnswer(state, trimmedQuestion)
  } finally {
    request.destroy()
  }
}