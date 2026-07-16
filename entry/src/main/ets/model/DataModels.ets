// ============================================================
// 智慧环境生活管家 — 数据模型定义
// ============================================================
import { DEVICE_ICONS, THEME_PRESETS } from '../data/Constants'

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
  roomId: string
}

// ---------- 房间 ----------
export interface Room {
  id: string
  name: string
  icon: string
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
  lastOperationMessage: string
  operationHistory: string[]
  manualOverrideDeviceIds: string[]
  // 用户 & 房间
  familyName: string
  memberCount: number
  rooms: Room[]
  currentRoomId: string
  // 主题
  currentThemeKey: string

  constructor() {
    this.currentEnv = {
      temperature: 25, humidity: 50, pm25: 30, co2: 600, noise: 40, light: 300,
      outdoorTemp: 28, outdoorHumidity: 55, outdoorPm25: 25, outdoorQuality: '良'
    }
    this.currentScene = SceneMode.NORMAL
    this.devices = [
      { id: 'ac_living', name: '客厅空调', icon: DEVICE_ICONS.ac, isOn: false, targetValue: 26, currentValue: 25, unit: '°C', type: DeviceType.AC, roomId: 'living' },
      { id: 'purifier_living', name: '空气净化器', icon: DEVICE_ICONS.purifier, isOn: false, targetValue: 0, currentValue: 30, unit: 'μg/m³', type: DeviceType.PURIFIER, roomId: 'living' },
      { id: 'humidifier_living', name: '加湿器', icon: DEVICE_ICONS.humidifier, isOn: false, targetValue: 50, currentValue: 50, unit: '%', type: DeviceType.HUMIDIFIER, roomId: 'living' },
      { id: 'light_study', name: '书桌台灯', icon: DEVICE_ICONS.light, isOn: false, targetValue: 100, currentValue: 0, unit: '%', type: DeviceType.LIGHT, roomId: 'study' },
      { id: 'curtain_living', name: '客厅窗帘', icon: DEVICE_ICONS.curtain, isOn: true, targetValue: 100, currentValue: 100, unit: '%', type: DeviceType.CURTAIN, roomId: 'living' },
      { id: 'ac_bedroom', name: '卧室空调', icon: DEVICE_ICONS.ac, isOn: false, targetValue: 24, currentValue: 23, unit: '°C', type: DeviceType.AC, roomId: 'bedroom' },
      { id: 'light_bedroom', name: '卧室台灯', icon: DEVICE_ICONS.light, isOn: false, targetValue: 80, currentValue: 0, unit: '%', type: DeviceType.LIGHT, roomId: 'bedroom' }
    ]
    this.suggestions = []
    this.trendHistory = []
    this.healthReminders = [
      { type: 'drink', message: '记得喝水哦，已间隔1小时', interval: 60, lastTriggered: Date.now() },
      { type: 'rest', message: '专注50分钟，建议休息5分钟', interval: 50, lastTriggered: Date.now() },
      { type: 'sleep', message: '已过23:00，建议准备入睡', interval: 0, lastTriggered: Date.now() }
    ]
    this.sessionStartTime = Date.now()
    this.lastOperationMessage = ''
    this.operationHistory = []
    this.manualOverrideDeviceIds = []
    this.familyName = '我的家'
    this.memberCount = 3
    this.rooms = [
      { id: 'living', name: '客厅', icon: '◎' },
      { id: 'bedroom', name: '主卧', icon: '☾' },
      { id: 'study', name: '书房', icon: '◈' }
    ]
    this.currentRoomId = 'living'
    this.currentThemeKey = 'teal'
  }

  getThemePrimary(): string {
    return THEME_PRESETS[this.currentThemeKey]?.primary || '#0D9488'
  }
  getThemeBg(): string {
    return THEME_PRESETS[this.currentThemeKey]?.bgPrimary || '#F0FDF4'
  }
  getThemeSoft(): string {
    return THEME_PRESETS[this.currentThemeKey]?.primarySoft || '#CCFBF1'
  }
  getThemeLight(): string {
    return THEME_PRESETS[this.currentThemeKey]?.primaryLight || '#5EEAD4'
  }
}
