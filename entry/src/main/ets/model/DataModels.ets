// ============================================================
// 智慧环境生活管家 — 数据模型定义
// ============================================================

// ---------- 环境指标 ----------
export interface EnvironmentData {
  temperature: number        // °C
  humidity: number           // %
  pm25: number               // μg/m³
  co2: number                // ppm
  noise: number              // dB
  light: number              // lux
  outdoorTemp: number
  outdoorHumidity: number
  outdoorPm25: number
  outdoorQuality: string     // '优'|'良'|'轻度污染'|'中度污染'|'重度污染'
}

// ---------- 环境评分 ----------
export enum EnvironmentLevel {
  COMFORTABLE = '舒适',
  STUFFY = '偏闷',
  DRY = '偏干',
  POLLUTED = '污染偏高',
  NOISY = '噪声过大'
}

export interface EnvironmentScore {
  score: number
  level: EnvironmentLevel
  anomalies: string[]
  suggestion: string
}

// ---------- 场景模式 ----------
export enum SceneMode {
  SLEEP = '睡眠模式',
  STUDY = '学习模式',
  CHILD = '儿童模式',
  ELDERLY = '老人模式',
  AWAY = '离家模式',
  NORMAL = '普通模式'
}

// ---------- 设备 ----------
export enum DeviceType {
  AC = '空调',
  PURIFIER = '空气净化器',
  HUMIDIFIER = '加湿器',
  LIGHT = '台灯',
  CURTAIN = '窗帘'
}

export interface Device {
  id: string
  name: string
  icon: string
  isOn: boolean
  targetValue: number
  currentValue: number
  unit: string
  type: DeviceType
}

// ---------- AI 建议 ----------
export enum SuggestionCategory {
  ENV = '环境',
  HEALTH = '健康',
  STUDY = '学习',
  ENERGY = '节能'
}

export interface Suggestion {
  id: string
  timestamp: number
  category: SuggestionCategory
  title: string
  detail: string
  actionLabel: string
  actionType: string
  icon: string
}

// ---------- 历史趋势 ----------
export interface TrendPoint {
  time: string
  temperature: number
  humidity: number
  pm25: number
  co2: number
  score: number
}

// ---------- 健康提醒 ----------
export interface HealthReminder {
  type: string
  message: string
  interval: number
  lastTriggered: number
}

// ---------- 应用全局状态 ----------
export class AppState {
  currentEnv: EnvironmentData
  currentScene: SceneMode
  devices: Device[]
  suggestions: Suggestion[]
  trendHistory: TrendPoint[]
  healthReminders: HealthReminder[]
  sessionStartTime: number

  constructor() {
    this.currentEnv = {
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
    this.currentScene = SceneMode.NORMAL
    this.devices = [
      { id: 'ac', name: '客厅空调', icon: '❄️', isOn: false, targetValue: 26, currentValue: 25, unit: '°C', type: DeviceType.AC },
      { id: 'purifier', name: '空气净化器', icon: '🌬️', isOn: false, targetValue: 0, currentValue: 30, unit: 'μg/m³', type: DeviceType.PURIFIER },
      { id: 'humidifier', name: '加湿器', icon: '💧', isOn: false, targetValue: 50, currentValue: 50, unit: '%', type: DeviceType.HUMIDIFIER },
      { id: 'light', name: '书桌台灯', icon: '💡', isOn: false, targetValue: 100, currentValue: 0, unit: '%', type: DeviceType.LIGHT },
      { id: 'curtain', name: '客厅窗帘', icon: '🪟', isOn: true, targetValue: 100, currentValue: 100, unit: '%', type: DeviceType.CURTAIN }
    ]
    this.suggestions = []
    this.trendHistory = []
    this.healthReminders = [
      { type: 'drink', message: '记得喝水哦，已间隔1小时', interval: 60, lastTriggered: Date.now() },
      { type: 'rest', message: '专注50分钟，建议休息5分钟', interval: 50, lastTriggered: Date.now() },
      { type: 'sleep', message: '已过23:00，建议准备入睡', interval: 0, lastTriggered: Date.now() }
    ]
    this.sessionStartTime = Date.now()
  }
}
