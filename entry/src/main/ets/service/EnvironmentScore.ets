// ============================================================
// 智慧环境生活管家 — 环境评分算法
// ============================================================
import { EnvironmentData, EnvironmentLevel, EnvironmentScore } from '../model/DataModels'
import { THRESHOLDS, SCORE_WEIGHTS, SCORE_LEVELS } from '../data/Constants'

export function calculateEnvironmentScore(env: EnvironmentData): EnvironmentScore {
  let score = 100
  let anomalies: string[] = []

  // 温度评分
  let tempDiff = Math.abs(env.temperature - THRESHOLDS.temperature.ideal)
  if (env.temperature < THRESHOLDS.temperature.min) {
    let penalty = (THRESHOLDS.temperature.min - env.temperature) * SCORE_WEIGHTS.temperature
    score -= penalty
    anomalies.push(`温度偏低 ${env.temperature}°C`)
  } else if (env.temperature > THRESHOLDS.temperature.max) {
    let penalty = (env.temperature - THRESHOLDS.temperature.max) * SCORE_WEIGHTS.temperature
    score -= penalty
    anomalies.push(`温度偏高 ${env.temperature}°C`)
  }

  // 湿度评分
  if (env.humidity < THRESHOLDS.humidity.min) {
    let diff = THRESHOLDS.humidity.min - env.humidity
    score -= Math.floor(diff / 5) * SCORE_WEIGHTS.humidity
    anomalies.push(`湿度偏低 ${env.humidity}%`)
  } else if (env.humidity > THRESHOLDS.humidity.max) {
    let diff = env.humidity - THRESHOLDS.humidity.max
    score -= Math.floor(diff / 5) * SCORE_WEIGHTS.humidity
    anomalies.push(`湿度偏高 ${env.humidity}%`)
  }

  // PM2.5 评分
  if (env.pm25 > THRESHOLDS.pm25.good) {
    let over = env.pm25 - THRESHOLDS.pm25.good
    score -= Math.floor(over / 10) * SCORE_WEIGHTS.pm25
    if (env.pm25 > THRESHOLDS.pm25.unhealthy) {
      anomalies.push(`PM2.5 严重超标 ${env.pm25}μg/m³`)
    } else if (env.pm25 > THRESHOLDS.pm25.moderate) {
      anomalies.push(`PM2.5 偏高 ${env.pm25}μg/m³`)
    } else {
      anomalies.push(`PM2.5 略高 ${env.pm25}μg/m³`)
    }
  }

  // CO2 评分
  if (env.co2 > THRESHOLDS.co2.good) {
    let over = env.co2 - THRESHOLDS.co2.good
    score -= Math.floor(over / 200) * SCORE_WEIGHTS.co2
    if (env.co2 > THRESHOLDS.co2.high) {
      anomalies.push(`CO2 严重偏高 ${env.co2}ppm`)
    } else if (env.co2 > THRESHOLDS.co2.moderate) {
      anomalies.push(`CO2 偏高 ${env.co2}ppm`)
    }
  }

  // 噪声评分
  if (env.noise > THRESHOLDS.noise.quiet) {
    let over = env.noise - THRESHOLDS.noise.quiet
    score -= Math.floor(over / 5) * SCORE_WEIGHTS.noise
    if (env.noise > THRESHOLDS.noise.noisy) {
      anomalies.push(`噪声过大 ${env.noise}dB`)
    } else if (env.noise > THRESHOLDS.noise.moderate) {
      anomalies.push(`噪声偏高 ${env.noise}dB`)
    }
  }

  // 确定等级
  score = Math.max(0, Math.min(100, Math.round(score)))
  let level: EnvironmentLevel

  if (score >= SCORE_LEVELS.comfortable) {
    level = EnvironmentLevel.COMFORTABLE
  } else if (score >= SCORE_LEVELS.mild) {
    // 根据主要异常判断
    if (anomalies.length > 0) {
      if (anomalies.some(a => a.includes('湿度偏低'))) {
        level = EnvironmentLevel.DRY
      } else if (anomalies.some(a => a.includes('湿度偏高')) || anomalies.some(a => a.includes('CO2'))) {
        level = EnvironmentLevel.STUFFY
      } else {
        level = EnvironmentLevel.POLLUTED
      }
    } else {
      level = EnvironmentLevel.STUFFY
    }
  } else if (score >= SCORE_LEVELS.moderate) {
    level = EnvironmentLevel.POLLUTED
  } else {
    if (anomalies.some(a => a.includes('噪声'))) {
      level = EnvironmentLevel.NOISY
    } else {
      level = EnvironmentLevel.POLLUTED
    }
  }

  // 生成建议
  let suggestion = generateTopSuggestion(env, level, anomalies)

  return { score, level, anomalies, suggestion }
}

function generateTopSuggestion(env: EnvironmentData, level: EnvironmentLevel, anomalies: string[]): string {
  if (level === EnvironmentLevel.COMFORTABLE) {
    return '当前环境舒适，享受美好时光吧 ☀️'
  }
  if (anomalies.length === 0) {
    return '环境状态良好'
  }

  // 按优先级返回最先需要处理的建议
  if (env.pm25 > THRESHOLDS.pm25.moderate) {
    return 'PM2.5偏高，建议开启空气净化器 🌬️'
  }
  if (env.co2 > THRESHOLDS.co2.moderate) {
    if (env.outdoorPm25 < env.pm25) {
      return 'CO2偏高，室外空气更好，建议开窗通风 🪟'
    }
    return 'CO2偏高，建议开窗10分钟换气 🪟'
  }
  if (env.humidity < THRESHOLDS.humidity.min) {
    return '室内偏干，建议开启加湿器 💧'
  }
  if (env.humidity > THRESHOLDS.humidity.max) {
    return '室内偏闷，建议开窗或开启除湿 💨'
  }
  if (env.temperature > THRESHOLDS.temperature.max) {
    return '温度偏高，建议开启空调或开窗通风 ❄️'
  }
  if (env.temperature < THRESHOLDS.temperature.min) {
    return '温度偏低，建议调高空调温度 🔥'
  }
  if (env.noise > THRESHOLDS.noise.moderate) {
    return '噪声偏高，建议关闭窗户进入静音模式 🔇'
  }
  return '检测到环境异常，请查看详情'
}
