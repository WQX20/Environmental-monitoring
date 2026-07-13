// ============================================================
// 智慧环境生活管家 — 模拟环境数据源
// ============================================================
import { AppState, EnvironmentData } from '../model/DataModels'
import { THRESHOLDS } from './Constants'

// 基准值
const BASE: EnvironmentData = {
  temperature: 25,
  humidity: 50,
  pm25: 30,
  co2: 600,
  noise: 40,
  light: 300,
  outdoorTemp: 28,
  outdoorHumidity: 55,
  outdoorPm25: 25,
  outdoorQuality: '良'
}

// 生成带波动的模拟数据
function fluctuate(base: number, range: number, min: number, max: number): number {
  let delta = (Math.random() - 0.5) * 2 * range
  let val = base + delta
  return Math.max(min, Math.min(max, Math.round(val * 10) / 10))
}

export function generateMockData(): EnvironmentData {
  let hour = new Date().getHours()

  // 不同时段的基准偏移
  let tempOffset = (hour >= 12 && hour <= 16) ? 3 : 0         // 午后偏热
  let co2Offset = (hour >= 20 || hour <= 6) ? 200 : 0          // 夜间关窗CO2偏高
  let lightOffset = (hour >= 18 || hour <= 6) ? -250 : 50      // 夜间光线弱
  let noiseOffset = (hour >= 20 && hour <= 23) ? 10 : 0        // 晚间活动噪声

  return {
    temperature: fluctuate(BASE.temperature + tempOffset, 2, 15, 35),
    humidity: fluctuate(BASE.humidity, 10, 20, 80),
    pm25: fluctuate(BASE.pm25, 20, 5, 200),
    co2: fluctuate(BASE.co2 + co2Offset, 150, 400, 2000),
    noise: fluctuate(BASE.noise + noiseOffset, 10, 20, 90),
    light: fluctuate(BASE.light + lightOffset, 100, 10, 2000),
    outdoorTemp: fluctuate(BASE.outdoorTemp, 3, 10, 40),
    outdoorHumidity: fluctuate(BASE.outdoorHumidity, 8, 20, 90),
    outdoorPm25: fluctuate(BASE.outdoorPm25, 15, 5, 180),
    outdoorQuality: '良'
  }
}

// 更新室外空气质量标签
export function updateOutdoorQuality(env: EnvironmentData): void {
  if (env.outdoorPm25 <= 35) {
    env.outdoorQuality = '优'
  } else if (env.outdoorPm25 <= 75) {
    env.outdoorQuality = '良'
  } else if (env.outdoorPm25 <= 115) {
    env.outdoorQuality = '轻度污染'
  } else if (env.outdoorPm25 <= 150) {
    env.outdoorQuality = '中度污染'
  } else {
    env.outdoorQuality = '重度污染'
  }
}

// 定时刷新环境数据
export function startDataSimulation(state: AppState, onUpdate: () => void): number {
  return setInterval(() => {
    state.currentEnv = generateMockData()
    updateOutdoorQuality(state.currentEnv)
    onUpdate()
  }, 3000)
}
