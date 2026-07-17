// ============================================================
// 智慧环境生活管家 — 设计令牌系统 v2.0
// "Nature's Breath" 设计语言 — 清新、温润、富有层次
// ============================================================

// ---------- 主色系：清新绿意 ----------
// 灵感来自清晨露水与嫩叶，传递健康、自然、生机
export const COLORS: Record<string, string> = {
  // 品牌主色
  'primary': '#0D9488',           // 深青瓷 — 品牌主色
  'primaryLight': '#5EEAD4',      // 浅碧色 — 高亮/渐变
  'primaryDark': '#0F766E',       // 暗青 — 按压态
  'primarySoft': '#CCFBF1',       // 极浅青 — 卡片底色

  // 语义色
  'accent': '#14B8A6',            // 强调色
  'success': '#10B981',           // 成功绿
  'warning': '#F59E0B',           // 琥珀警告
  'danger': '#EF4444',            // 柔红危险
  'info': '#3B82F6',              // 信息蓝

  // 背景层级
  'bgPrimary': '#F0FDF4',         // 页面底色 — 极淡绿
  'bgSecondary': '#F8FAFC',       // 次级背景
  'surface': '#FFFFFF',           // 卡片白
  'surfaceHover': '#FAFFFB',      // 卡片悬浮态

  // 文字层级
  'textPrimary': '#0F172A',       // 主文字 — 近黑夜
  'textSecondary': '#475569',     // 次文字 — 石板灰
  'textTertiary': '#94A3B8',      // 辅助文字
  'textInverse': '#FFFFFF',       // 反色文字

  // 边框/分割
  'borderLight': '#E2E8F0',       // 浅边框
  'borderDefault': '#CBD5E1',     // 默认边框

  // 遮罩
  'overlay': 'rgba(15,23,42,0.04)',
}

// ---------- 主题预设 ----------
interface ThemePreset {
  name: string
  primary: string
  primaryLight: string
  primarySoft: string
  bgPrimary: string
  label: string
}
export const THEME_PRESETS: Record<string, ThemePreset> = {
  'teal':    { name: '青瓷', primary: '#0D9488', primaryLight: '#5EEAD4', primarySoft: '#CCFBF1', bgPrimary: '#F0FDF4', label: '默认' },
  'sky':     { name: '天蓝', primary: '#0284C7', primaryLight: '#7DD3FC', primarySoft: '#E0F2FE', bgPrimary: '#F0F9FF', label: '天蓝' },
  'rose':    { name: '玫瑰', primary: '#E11D48', primaryLight: '#FDA4AF', primarySoft: '#FFE4E6', bgPrimary: '#FFF1F2', label: '玫瑰' },
  'violet':  { name: '紫罗兰', primary: '#7C3AED', primaryLight: '#C4B5FD', primarySoft: '#EDE9FE', bgPrimary: '#F5F3FF', label: '紫罗' },
  'amber':   { name: '琥珀', primary: '#D97706', primaryLight: '#FCD34D', primarySoft: '#FEF3C7', bgPrimary: '#FFFBEB', label: '琥珀' },
  'slate':   { name: '岩灰', primary: '#475569', primaryLight: '#CBD5E1', primarySoft: '#F1F5F9', bgPrimary: '#F8FAFC', label: '岩灰' },
}

// ---------- 渐变色定义 ----------
// ArkUI 的 linearGradient 使用 direction + ColorStop[] 数组
export const GRADIENTS: Record<string, Array<[string, number]>> = {
  // 主渐变：青瓷 → 碧色 (用于大卡片、按钮)
  'primary': [['#0D9488', 0], ['#14B8A6', 0.5], ['#5EEAD4', 1]],
  // 温感渐变 (温度相关)
  'warm': [['#F97316', 0], ['#F59E0B', 0.5], ['#FBBF24', 1]],
  // 清凉渐变 (空调/降温)
  'cool': [['#3B82F6', 0], ['#0EA5E9', 0.5], ['#67E8F9', 1]],
  // 空气渐变 (PM2.5/CO2)
  'air': [['#8B5CF6', 0], ['#A78BFA', 0.5], ['#DDD6FE', 1]],
  // 湿润渐变 (湿度相关)
  'moisture': [['#06B6D4', 0], ['#22D3EE', 0.5], ['#A5F3FC', 1]],
  // 得分环渐变
  'score': [['#0D9488', 0], ['#5EEAD4', 1]],
  // 卡片头部渐变
  'cardHeader': [['#0D9488', 0], ['#14B8A6', 1]],
}

// ---------- 阴影接口 ----------
interface ShadowConfig {
  radius: number
  color: string
  offsetY: number
}

// ---------- 阴影层级 ----------
export const SHADOWS: Record<string, ShadowConfig> = {
  'none': { radius: 0, color: 'rgba(0,0,0,0)', offsetY: 0 },
  'sm': { radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 },
  'md': { radius: 8, color: 'rgba(15,23,42,0.08)', offsetY: 2 },
  'lg': { radius: 16, color: 'rgba(15,23,42,0.10)', offsetY: 4 },
  'xl': { radius: 24, color: 'rgba(15,23,42,0.12)', offsetY: 6 },
  'glow': { radius: 20, color: 'rgba(13,148,136,0.25)', offsetY: 0 },
}

// ---------- 间距系统 (基于 4px 栅格) ----------
export const SPACING: Record<string, number> = {
  'xs': 4,
  'sm': 8,
  'md': 12,
  'lg': 16,
  'xl': 20,
  '2xl': 24,
  '3xl': 32,
}

// ---------- 圆角系统 ----------
export const RADIUS: Record<string, number> = {
  'sm': 8,
  'md': 12,
  'lg': 16,
  'xl': 20,
  '2xl': 24,
  'full': 999,
}

// ---------- 字体大小 ----------
export const FONTS: Record<string, number> = {
  'caption': 11,
  'bodySm': 13,
  'body': 15,
  'bodyLg': 17,
  'titleSm': 18,
  'title': 20,
  'titleLg': 24,
  'display': 36,
  'displayLg': 48,
}

// ============================================================
// 以下为业务常量 (保持不变)
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

// ---------- 定时器间隔 (毫秒) ----------
export const TIMERS: TimersConfig = {
  dataRefresh: 3000,
  suggestionCheck: 10000,
  trendRecord: 60000
}

// ---------- AI 模型接入配置 ----------
interface AiModelConfig {
  enabled: boolean
  endpoint: string
  timeoutMs: number
  maxSuggestions: number
}

export const AI_MODEL_CONFIG: AiModelConfig = {
  enabled: true,
  endpoint: 'http://192.168.6.51:3000/ai/advice',
  timeoutMs: 10000,
  maxSuggestions: 3
}

// ---------- 动画时长 ----------
export const DURATION: Record<string, number> = {
  'fast': 150,
  'normal': 250,
  'slow': 400,
  'toast': 2000,
  'result': 3000,
}

// ---------- 场景描述 ----------
export const SCENE_DESCRIPTIONS: Record<string, string> = {
  '睡眠模式': '调暗灯光、关闭窗帘，营造舒适入睡环境',
  '学习模式': '安静专注空间，定时提醒休息与通风',
  '儿童模式': '守护儿童健康环境，严控温湿度与噪声',
  '老人模式': '关注呼吸健康与温湿舒适，降低风险',
  '离家模式': '全屋节能检查，远程环境实时监控',
  '普通模式': '智能监测室内环境，提供实时建议'
}

// ============================================================
// 极简符号图标系统 — 融入 Nature's Breath 主题
// 使用 Unicode 几何符号替代彩色 emoji，统一风格
// ============================================================
export const ICONS: Record<string, string> = {
  // ── 导航 ──
  'navHome': '◎',
  'navScene': '◉',
  'navDevice': '⚙',
  'navAi': '✦',

  // ── 环境指标 ──
  'temp': '◐',
  'humidity': '❖',
  'pm25': '◉',
  'co2': '◎',
  'noise': '♪',
  'light': '☀',

  // ── 设备 ──
  'ac': '❆',
  'purifier': '❈',
  'humidifier': '❖',
  'deskLamp': '☀',
  'curtain': '◫',

  // ── 场景 ──
  'sleep': '☾',
  'study': '◈',
  'child': '♥',
  'elderly': '☘',
  'away': '➤',
  'normal': '◎',

  // ── 状态 ──
  'check': '✓',
  'warn': '△',
  'close': '✕',

  // ── 操作 ──
  'optimize': '✦',
  'powerOff': '⊗',
  'link': '⛓',
  'refresh': '↻',

  // ── 分类标签 ──
  'catEnv': '◉',
  'catHealth': '大',
  'catStudy': '◈',
  'catEnergy': '⚡',

  // ── 区块标题 ──
  'secMetrics': '◐',
  'secSuggestion': '◈',
  'secTrend': '↑',
  'secHealth': '♥',
  'secLink': '⛓',
  'secRecommend': '☰',
  'secOutdoor': '◉',

  // ── 评分等级 ──
  'levelGreat': '◎',
  'levelGood': '◉',
  'levelOkay': '◐',
  'levelBad': '○',

  // ── 健康提醒 ──
  'remDrink': '◐',
  'remRest': '◈',
  'remSleep': '☾',
  'remExercise': '➤',

  // ── 杂项 ──
  'bullet': '·',
  'arrow': '→',
  'toast': '◈',
  'leaf': '☘',
  'warm': '◐',
}

// ---------- 场景图标 (极简符号版) ----------
export const SCENE_ICONS: Record<string, string> = {
  '睡眠模式': '☾',
  '学习模式': '◈',
  '儿童模式': '♥',
  '老人模式': '☘',
  '离家模式': '➤',
  '普通模式': '◎'
}

// ---------- 场景主题色 ----------
export const SCENE_COLORS: Record<string, string> = {
  '睡眠模式': '#6366F1',
  '学习模式': '#8B5CF6',
  '儿童模式': '#F59E0B',
  '老人模式': '#10B981',
  '离家模式': '#64748B',
  '普通模式': '#0D9488',
}

// ---------- 设备图标 (极简符号版) ----------
export const DEVICE_ICONS: Record<string, string> = {
  'ac': '❆',
  'purifier': '❈',
  'humidifier': '❖',
  'light': '☀',
  'curtain': '◫'
}
