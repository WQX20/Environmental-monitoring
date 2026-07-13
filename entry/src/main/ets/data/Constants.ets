// ============================================================
// 智慧环境生活管家 — 常量定义
// ============================================================

// ---------- 接口：阈值范围 ----------
interface ThresholdRange {
  min: number
  max: number
  ideal: number
}

interface Pm25Thresholds {
  good: number
  moderate: number
  unhealthy: number
}

interface Co2Thresholds {
  good: number
  moderate: number
  high: number
}

interface NoiseThresholds {
  quiet: number
  moderate: number
  noisy: number
}

interface LightThresholds {
  dim: number
  comfortable: number
  bright: number
}

interface ScoreWeights {
  temperature: number
  humidity: number
  pm25: number
  co2: number
  noise: number
}

interface ScoreLevels {
  comfortable: number
  mild: number
  moderate: number
}

interface TimersConfig {
  dataRefresh: number
  suggestionCheck: number
  trendRecord: number
}

// ---------- 主题色 (清新绿色系) ----------
export const COLORS: Record<string, string> = {
  'primary': '#4CAF50',
  'primaryLight': '#81C784',
  'primaryDark': '#388E3C',
  'accent': '#8BC34A',
  'background': '#F1F8E9',
  'surface': '#FFFFFF',
  'cardBg': '#F9FBE7',
  'text': '#212121',
  'textSecondary': '#757575',
  'textHint': '#BDBDBD',
  'danger': '#F44336',
  'warning': '#FF9800',
  'info': '#2196F3',
  'success': '#4CAF50',
  'divider': '#E0E0E0',
  'white': '#FFFFFF',
  'darkOverlay': 'rgba(0,0,0,0.05)'
}

// ---------- 接口：所有阈值汇总 ----------
interface AllThresholds {
  temperature: ThresholdRange
  humidity: ThresholdRange
  pm25: Pm25Thresholds
  co2: Co2Thresholds
  noise: NoiseThresholds
  light: LightThresholds
}

// ---------- 环境阈值 ----------
export const THRESHOLDS: AllThresholds = {
  temperature: { min: 22, max: 26, ideal: 24 },
  humidity: { min: 40, max: 60, ideal: 50 },
  pm25: { good: 35, moderate: 75, unhealthy: 150 },
  co2: { good: 800, moderate: 1000, high: 1500 },
  noise: { quiet: 45, moderate: 60, noisy: 75 },
  light: { dim: 100, comfortable: 300, bright: 1000 }
}

// ---------- 评分扣分权重 ----------
export const SCORE_WEIGHTS: ScoreWeights = {
  temperature: 5,
  humidity: 4,
  pm25: 6,
  co2: 5,
  noise: 4
}

// ---------- 评分等级边界 ----------
export const SCORE_LEVELS: ScoreLevels = {
  comfortable: 85,
  mild: 70,
  moderate: 55
}

// ---------- 定时器间隔 ----------
export const TIMERS: TimersConfig = {
  dataRefresh: 3000,
  suggestionCheck: 10000,
  trendRecord: 60000
}

// ---------- 场景描述 ----------
export const SCENE_DESCRIPTIONS: Record<string, string> = {
  '睡眠模式': '调暗灯光、关闭通知、监测温湿度确保舒适睡眠环境',
  '学习模式': '保持安静环境、定时提醒休息、建议开窗保持空气流通',
  '儿童模式': '显示适宜温度/湿度/噪声阈值，守护儿童健康环境',
  '老人模式': '关注呼吸健康与温湿度舒适度，降低环境风险',
  '离家模式': '检查门窗设备状态、节能建议、远程环境监控',
  '普通模式': '智能监测室内环境，提供实时数据与健康建议'
}

// ---------- 场景图标 ----------
export const SCENE_ICONS: Record<string, string> = {
  '睡眠模式': '🌙',
  '学习模式': '📚',
  '儿童模式': '👶',
  '老人模式': '🧓',
  '离家模式': '🏃',
  '普通模式': '🏠'
}
