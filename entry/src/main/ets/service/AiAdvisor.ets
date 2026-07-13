// ============================================================
// 智慧环境生活管家 — AI 建议生成引擎
// ============================================================
import { AppState, Suggestion, SuggestionCategory, DeviceType } from '../model/DataModels'
import { THRESHOLDS } from '../data/Constants'

export function generateSuggestions(state: AppState): Suggestion[] {
  let newSuggestions: Suggestion[] = []
  let env = state.currentEnv
  let now = Date.now()
  let sessionDuration = Math.floor((now - state.sessionStartTime) / 60000) // 分钟

  // === 环境类建议 ===

  // CO2 偏高
  if (env.co2 > THRESHOLDS.co2.moderate) {
    if (env.outdoorPm25 < env.pm25) {
      newSuggestions.push({
        id: `env-co2-${now}`,
        timestamp: now,
        category: SuggestionCategory.ENV,
        title: 'CO2 偏高，建议开窗',
        detail: `当前室内CO2浓度${env.co2}ppm，室外空气更好（PM2.5:${env.outdoorPm25}），适合开窗通风10分钟`,
        actionLabel: '记录已开窗',
        actionType: 'openWindow',
        icon: '🪟'
      })
    } else {
      newSuggestions.push({
        id: `env-co2-${now}`,
        timestamp: now,
        category: SuggestionCategory.ENV,
        title: 'CO2 偏高，注意通风',
        detail: `室内CO2达${env.co2}ppm，建议短暂开窗或开启新风系统`,
        actionLabel: '开启净化器',
        actionType: 'startDevice',
        icon: '🌬️'
      })
    }
  }

  // 湿度偏低
  if (env.humidity < THRESHOLDS.humidity.min) {
    newSuggestions.push({
      id: `env-humid-${now}`,
      timestamp: now,
      category: SuggestionCategory.ENV,
      title: '室内湿度偏低',
      detail: `当前湿度${env.humidity}%，干燥环境不适合长时间学习与工作，建议开启加湿器`,
      actionLabel: '开启加湿器',
      actionType: 'startDevice',
      icon: '💧'
    })
  }

  // 室外空气更好
  if (env.outdoorPm25 < env.pm25 - 10 && env.outdoorPm25 < 50) {
    newSuggestions.push({
      id: `env-outdoor-${now}`,
      timestamp: now,
      category: SuggestionCategory.ENV,
      title: '室外空气更佳',
      detail: `室外PM2.5仅${env.outdoorPm25}μg/m³（${env.outdoorQuality}），适合开窗通风`,
      actionLabel: '知道了',
      actionType: 'none',
      icon: '☀️'
    })
  }

  // PM2.5 严重
  if (env.pm25 > THRESHOLDS.pm25.unhealthy) {
    newSuggestions.push({
      id: `env-pm25-${now}`,
      timestamp: now,
      category: SuggestionCategory.ENV,
      title: '空气质量差！',
      detail: `PM2.5高达${env.pm25}μg/m³，已自动开启空气净化器，建议减少开窗`,
      actionLabel: '查看设备状态',
      actionType: 'startDevice',
      icon: '⚠️'
    })
  }

  // === 健康类建议 ===

  // 专注提醒
  if (sessionDuration > 0 && sessionDuration % 50 < 3 && sessionDuration > 45) {
    newSuggestions.push({
      id: `health-rest-${now}`,
      timestamp: now,
      category: SuggestionCategory.HEALTH,
      title: '该休息一下了',
      detail: `你已经连续使用${sessionDuration}分钟，建议休息5分钟，站起来走动并补水`,
      actionLabel: '开始休息',
      actionType: 'rest',
      icon: '☕'
    })
  }

  // 噪声偏高影响健康
  if (env.noise > THRESHOLDS.noise.moderate) {
    newSuggestions.push({
      id: `health-noise-${now}`,
      timestamp: now,
      category: SuggestionCategory.HEALTH,
      title: '噪声偏高影响健康',
      detail: `当前噪声${env.noise}dB，长时间处于此环境可能影响听力和专注力`,
      actionLabel: '查看降噪建议',
      actionType: 'none',
      icon: '🔇'
    })
  }

  // === 学习类建议 ===

  if (state.currentScene === '学习模式') {
    if (env.humidity < 35) {
      newSuggestions.push({
        id: `study-humid-${now}`,
        timestamp: now,
        category: SuggestionCategory.STUDY,
        title: '湿度偏低，不利学习',
        detail: '干燥环境容易导致疲劳和注意力下降，建议将湿度保持在45%以上',
        actionLabel: '开启加湿器',
        actionType: 'startDevice',
        icon: '📚'
      })
    }
  }

  // === 节能类建议 ===

  if (env.outdoorTemp >= 20 && env.outdoorTemp <= 26 && env.outdoorPm25 < 50) {
    // 室外舒适，可以自然通风 — 检查空调是否开着
    let acDevice = state.devices.find(d => d.type === DeviceType.AC)
    if (acDevice && acDevice.isOn) {
      newSuggestions.push({
        id: `energy-ac-${now}`,
        timestamp: now,
        category: SuggestionCategory.ENERGY,
        title: '节能建议：关闭空调',
        detail: `室外${env.outdoorTemp}°C舒适宜人，建议关空调开窗，既省电又通风`,
        actionLabel: '关闭空调',
        actionType: 'startDevice',
        icon: '⚡'
      })
    }
  }

  return newSuggestions
}

// 合并新建议到全局状态（去重，保留最近的）
export function mergeSuggestions(state: AppState, newSuggestions: Suggestion[]): void {
  for (let sug of newSuggestions) {
    // 检查是否已有同类建议（按 title 去重）
    let exists = state.suggestions.some(s => s.title === sug.title)
    if (!exists) {
      state.suggestions.unshift(sug)
    }
  }
  // 最多保留 50 条
  if (state.suggestions.length > 50) {
    state.suggestions = state.suggestions.slice(0, 50)
  }
}
