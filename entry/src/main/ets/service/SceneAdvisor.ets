// ============================================================
// 场景建议引擎 (极简符号图标版)
// ============================================================
import { EnvironmentData, SceneMode } from '../model/DataModels'
import { THRESHOLDS, ICONS } from '../data/Constants'

export interface SceneRecommendation {
  title: string
  detail: string
  priority: number
  icon: string
}

export function getSceneRecommendations(scene: SceneMode, env: EnvironmentData): SceneRecommendation[] {
  let recs: SceneRecommendation[] = []
  switch (scene) {
    case SceneMode.SLEEP: recs = getSleepRecommendations(env); break
    case SceneMode.STUDY: recs = getStudyRecommendations(env); break
    case SceneMode.CHILD: recs = getChildRecommendations(env); break
    case SceneMode.ELDERLY: recs = getElderlyRecommendations(env); break
    case SceneMode.AWAY: recs = getAwayRecommendations(env); break
    default: recs = getNormalRecommendations(env); break
  }
  recs.sort((a, b) => a.priority - b.priority)
  return recs
}

function getSleepRecommendations(env: EnvironmentData): SceneRecommendation[] {
  let recs: SceneRecommendation[] = []
  recs.push({ title: '调暗灯光', detail: '已自动将灯光调至最低亮度，营造入睡氛围', priority: 1, icon: ICONS.deskLamp })
  recs.push({ title: '静音模式', detail: '已开启免打扰，屏蔽通知提醒', priority: 2, icon: ICONS.noise })
  if (env.temperature > 26) recs.push({ title: '温度偏高', detail: `当前${env.temperature}°C，建议开启空调至24°C`, priority: 1, icon: ICONS.ac })
  if (env.temperature < 20) recs.push({ title: '温度偏低', detail: `当前${env.temperature}°C，建议调高空调温度`, priority: 1, icon: ICONS.warm })
  if (env.humidity < 40) recs.push({ title: '湿度偏低', detail: `湿度${env.humidity}%，建议开启加湿器`, priority: 2, icon: ICONS.humidity })
  if (env.noise > 40) recs.push({ title: '噪声偏高', detail: `环境噪声${env.noise}dB，建议关窗`, priority: 2, icon: ICONS.curtain })
  if (env.co2 > 800) recs.push({ title: '空气流通', detail: '睡前开窗通风10分钟，改善空气质量', priority: 3, icon: ICONS.leaf })
  return recs
}

function getStudyRecommendations(env: EnvironmentData): SceneRecommendation[] {
  let recs: SceneRecommendation[] = []
  recs.push({ title: '专注模式', detail: '开启专注计时，每个50分钟提醒休息', priority: 1, icon: ICONS.catStudy })
  recs.push({ title: '护眼光线', detail: `当前光照${env.light}lux，建议保持在300-500lux`, priority: 2, icon: ICONS.deskLamp })
  if (env.noise > 50) recs.push({ title: '噪声干扰', detail: `噪声${env.noise}dB偏高，建议关窗或戴耳机`, priority: 1, icon: ICONS.noise })
  if (env.co2 > 1000) recs.push({ title: 'CO2偏高', detail: `CO2浓度${env.co2}ppm，影响专注力，建议开窗`, priority: 1, icon: ICONS.curtain })
  if (env.humidity < 35) recs.push({ title: '湿度偏低', detail: '干燥环境不适合长时间学习，建议开加湿器', priority: 2, icon: ICONS.humidity })
  if (env.pm25 > 50) recs.push({ title: '空气不佳', detail: '建议开启空气净化器，保持呼吸舒适', priority: 2, icon: ICONS.purifier })
  return recs
}

function getChildRecommendations(env: EnvironmentData): SceneRecommendation[] {
  let recs: SceneRecommendation[] = []
  recs.push({ title: '温度适宜', detail: '儿童房建议温度22-24°C，湿度45-55%', priority: 1, icon: ICONS.temp })
  recs.push({ title: '噪声保护', detail: `噪声阈值设为${THRESHOLDS.noise.quiet}dB，保护听力`, priority: 2, icon: ICONS.noise })
  if (env.temperature < 22 || env.temperature > 24) recs.push({ title: '温度提醒', detail: `当前${env.temperature}°C，超出儿童适宜范围`, priority: 1, icon: ICONS.warn })
  if (env.humidity < 45 || env.humidity > 55) recs.push({ title: '湿度提醒', detail: `湿度${env.humidity}%偏离理想范围`, priority: 2, icon: ICONS.humidity })
  if (env.pm25 > 25) recs.push({ title: '空气净化', detail: '儿童更敏感，PM2.5建议保持在25以下', priority: 1, icon: ICONS.purifier })
  if (env.noise > THRESHOLDS.noise.quiet) recs.push({ title: '噪声偏高', detail: '建议减少周围噪声以保护儿童听力', priority: 2, icon: ICONS.noise })
  return recs
}

function getElderlyRecommendations(env: EnvironmentData): SceneRecommendation[] {
  let recs: SceneRecommendation[] = []
  recs.push({ title: '舒适温度', detail: '老年人舒适温度22-26°C，避免温差过大', priority: 1, icon: ICONS.temp })
  recs.push({ title: '呼吸健康', detail: '关注PM2.5和CO2，保障呼吸道健康', priority: 2, icon: ICONS.catHealth })
  if (env.temperature < 22) recs.push({ title: '注意保暖', detail: `当前${env.temperature}°C偏低，老年人需注意保暖`, priority: 1, icon: ICONS.warm })
  if (env.temperature > 28) recs.push({ title: '防暑降温', detail: `当前${env.temperature}°C偏高，注意防暑`, priority: 1, icon: ICONS.ac })
  if (env.humidity < 40) recs.push({ title: '呼吸道干燥', detail: '开启加湿器，避免呼吸道不适', priority: 2, icon: ICONS.humidity })
  if (env.pm25 > 50) recs.push({ title: '不宜外出', detail: 'PM2.5偏高，建议减少外出并开净化器', priority: 1, icon: ICONS.navHome })
  return recs
}

function getAwayRecommendations(env: EnvironmentData): SceneRecommendation[] {
  let recs: SceneRecommendation[] = []
  recs.push({ title: '离家检查', detail: '确认门窗、空调、灯光已关闭', priority: 1, icon: ICONS.check })
  recs.push({ title: '节能模式', detail: '关闭非必要电器，进入节能模式', priority: 2, icon: ICONS.catEnergy })
  if (env.outdoorPm25 > 75) recs.push({ title: '今日空气差', detail: '室外空气污染，回来后建议先开净化器', priority: 3, icon: ICONS.warn })
  if (env.outdoorTemp > 35 || env.outdoorTemp < 5) recs.push({ title: '极端天气', detail: `室外${env.outdoorTemp}°C，回家前可远程开空调`, priority: 2, icon: ICONS.temp })
  return recs
}

function getNormalRecommendations(env: EnvironmentData): SceneRecommendation[] {
  let recs: SceneRecommendation[] = []
  recs.push({ title: '环境监测中', detail: '智能监测室内环境各项指标', priority: 1, icon: ICONS.secMetrics })
  if (env.outdoorPm25 < env.pm25) recs.push({ title: '适合通风', detail: `室外PM2.5(${env.outdoorPm25})低于室内(${env.pm25})，建议开窗`, priority: 2, icon: ICONS.curtain })
  return recs
}
