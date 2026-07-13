// ============================================================
// 智慧环境生活管家 — 设备联动控制
// ============================================================
import { AppState, Device, DeviceType, EnvironmentData } from '../model/DataModels'
import { THRESHOLDS } from '../data/Constants'

type StateChangeListener = () => void

const stateChangeListeners: StateChangeListener[] = []

export function subscribeStateChange(listener: StateChangeListener): () => void {
  stateChangeListeners.push(listener)
  return (): void => {
    let index = stateChangeListeners.indexOf(listener)
    if (index >= 0) {
      stateChangeListeners.splice(index, 1)
    }
  }
}

function notifyStateChange(): void {
  for (let listener of stateChangeListeners) {
    listener()
  }
}

function recordOperation(state: AppState, message: string): void {
  state.lastOperationMessage = message
  state.operationHistory.unshift(`${new Date().toLocaleTimeString()} ${message}`)
  if (state.operationHistory.length > 5) {
    state.operationHistory.pop()
  }
  notifyStateChange()
}

export function publishOperation(state: AppState, message: string): void {
  recordOperation(state, message)
}

function isManualOverride(state: AppState, deviceId: string): boolean {
  return state.manualOverrideDeviceIds.includes(deviceId)
}

function markManualOverride(state: AppState, deviceId: string): void {
  if (!state.manualOverrideDeviceIds.includes(deviceId)) {
    state.manualOverrideDeviceIds.push(deviceId)
  }
}

export function clearManualOverride(state: AppState, deviceId: string): void {
  state.manualOverrideDeviceIds = state.manualOverrideDeviceIds.filter(id => id !== deviceId)
}

export function clearAllManualOverrides(state: AppState): void {
  state.manualOverrideDeviceIds = []
}

// 获取联动建议（不执行）
export function getLinkageSuggestions(state: AppState): string[] {
  let actions: string[] = []
  let env = state.currentEnv

  if (env.pm25 > THRESHOLDS.pm25.moderate) {
    let purifier = state.devices.find(d => d.type === DeviceType.PURIFIER)
    if (purifier && !purifier.isOn) {
      actions.push(`PM2.5达${env.pm25}μg/m³，建议开启${purifier.name}`)
    }
  }
  if (env.temperature > 28) {
    let ac = state.devices.find(d => d.type === DeviceType.AC)
    if (ac && !ac.isOn) {
      actions.push(`温度达${env.temperature}°C，建议开启${ac.name}制冷至26°C`)
    }
  }
  if (env.humidity < THRESHOLDS.humidity.min) {
    let humidifier = state.devices.find(d => d.type === DeviceType.HUMIDIFIER)
    if (humidifier && !humidifier.isOn) {
      actions.push(`湿度仅${env.humidity}%，建议开启${humidifier.name}`)
    }
  }
  if (env.light < THRESHOLDS.light.dim) {
    let light = state.devices.find(d => d.type === DeviceType.LIGHT)
    if (light && !light.isOn) {
      actions.push(`光照不足${env.light}lux，建议开启${light.name}`)
    }
  }
  if (env.noise > THRESHOLDS.noise.moderate) {
    let curtain = state.devices.find(d => d.type === DeviceType.CURTAIN)
    if (curtain && curtain.isOn) {
      actions.push(`噪声${env.noise}dB偏高，建议关闭窗户减少噪声`)
    }
  }

  return actions
}

// 一键优化：自动执行联动
export function executeAutoOptimize(state: AppState): string[] {
  let executed: string[] = []
  let skipped: string[] = []
  let env = state.currentEnv

  // PM2.5 高 → 开净化器
  if (env.pm25 > THRESHOLDS.pm25.moderate) {
    let purifier = state.devices.find(d => d.type === DeviceType.PURIFIER)
    if (purifier && !purifier.isOn && !isManualOverride(state, purifier.id)) {
      purifier.isOn = true
      executed.push(`已开启${purifier.name}`)
    } else if (purifier && isManualOverride(state, purifier.id)) {
      skipped.push(`${purifier.name}已被手动接管，已跳过自动开启`)
    }
  }

  // 温度高 → 开空调
  if (env.temperature > 28) {
    let ac = state.devices.find(d => d.type === DeviceType.AC)
    if (ac && !ac.isOn && !isManualOverride(state, ac.id)) {
      ac.isOn = true
      ac.targetValue = 26
      executed.push(`已开启${ac.name}，目标26°C`)
    } else if (ac && isManualOverride(state, ac.id)) {
      skipped.push(`${ac.name}已被手动接管，已跳过自动调节`)
    }
  }

  // 湿度低 → 开加湿器
  if (env.humidity < THRESHOLDS.humidity.min) {
    let humidifier = state.devices.find(d => d.type === DeviceType.HUMIDIFIER)
    if (humidifier && !humidifier.isOn && !isManualOverride(state, humidifier.id)) {
      humidifier.isOn = true
      humidifier.targetValue = 50
      executed.push(`已开启${humidifier.name}，目标50%`)
    } else if (humidifier && isManualOverride(state, humidifier.id)) {
      skipped.push(`${humidifier.name}已被手动接管，已跳过自动调节`)
    }
  }

  // 光照不足 → 开台灯
  if (env.light < THRESHOLDS.light.dim) {
    let light = state.devices.find(d => d.type === DeviceType.LIGHT)
    if (light && !light.isOn && !isManualOverride(state, light.id)) {
      light.isOn = true
      executed.push(`已开启${light.name}`)
    } else if (light && isManualOverride(state, light.id)) {
      skipped.push(`${light.name}已被手动接管，已跳过自动开启`)
    }
  }

  if (executed.length === 0) {
    executed.push('当前环境良好，无需调整设备 ✅')
  }

  if (skipped.length > 0) {
    executed = executed.concat(skipped)
  }

  recordOperation(state, executed.join('\n'))

  return executed
}

// 一键全关
export function executeAllOff(state: AppState): string[] {
  let executed: string[] = []
  for (let device of state.devices) {
    if (device.isOn) {
      device.isOn = false
      executed.push(`已关闭${device.name}`)
    }
  }
  if (executed.length === 0) {
    executed.push('所有设备已处于关闭状态')
  }

  recordOperation(state, executed.join('\n'))

  return executed
}

// 切换单个设备
export function toggleDevice(device: Device): string {
  device.isOn = !device.isOn
  if (device.isOn) {
    return `已开启${device.name}`
  } else {
    return `已关闭${device.name}`
  }
}

// 更新设备目标值
export function updateDeviceTarget(device: Device, value: number): void {
  device.targetValue = value
}

function handleSleepScene(state: AppState, env: EnvironmentData): string[] {
  let results: string[] = []

  let light = state.devices.find(d => d.type === DeviceType.LIGHT)
  if (light && light.isOn && !isManualOverride(state, light.id)) {
    light.isOn = false
    results.push(`睡眠模式：已关闭${light.name}`)
  } else if (light && isManualOverride(state, light.id)) {
    results.push(`睡眠模式：${light.name}已被手动接管，跳过关闭`)
  }

  let curtain = state.devices.find(d => d.type === DeviceType.CURTAIN)
  if (curtain && curtain.isOn && !isManualOverride(state, curtain.id)) {
    curtain.isOn = false
    results.push(`睡眠模式：已关闭${curtain.name}遮光`)
  } else if (curtain && isManualOverride(state, curtain.id)) {
    results.push(`睡眠模式：${curtain.name}已被手动接管，跳过关闭`)
  }

  let ac = state.devices.find(d => d.type === DeviceType.AC)
  if (ac && env.temperature > THRESHOLDS.temperature.max && !ac.isOn && !isManualOverride(state, ac.id)) {
    ac.isOn = true
    ac.targetValue = 24
    results.push(`睡眠模式：已开启${ac.name}至24°C`)
  } else if (ac && isManualOverride(state, ac.id)) {
    results.push(`睡眠模式：${ac.name}已被手动接管，跳过自动调节`)
  }

  let humidifier = state.devices.find(d => d.type === DeviceType.HUMIDIFIER)
  if (humidifier && env.humidity < THRESHOLDS.humidity.min && !humidifier.isOn && !isManualOverride(state, humidifier.id)) {
    humidifier.isOn = true
    humidifier.targetValue = 50
    results.push(`睡眠模式：已开启${humidifier.name}`)
  } else if (humidifier && isManualOverride(state, humidifier.id)) {
    results.push(`睡眠模式：${humidifier.name}已被手动接管，跳过自动调节`)
  }

  return results
}

function handleStudyScene(state: AppState, env: EnvironmentData): string[] {
  let results: string[] = []

  let light = state.devices.find(d => d.type === DeviceType.LIGHT)
  if (light && !light.isOn && !isManualOverride(state, light.id)) {
    light.isOn = true
    results.push(`学习模式：已开启${light.name}`)
  } else if (light && isManualOverride(state, light.id)) {
    results.push(`学习模式：${light.name}已被手动接管，跳过开启`)
  }

  let curtain = state.devices.find(d => d.type === DeviceType.CURTAIN)
  if (curtain && curtain.isOn && env.light < THRESHOLDS.light.comfortable && !isManualOverride(state, curtain.id)) {
    curtain.isOn = false
    results.push(`学习模式：已关闭${curtain.name}以增强照明`)
  } else if (curtain && isManualOverride(state, curtain.id)) {
    results.push(`学习模式：${curtain.name}已被手动接管，跳过关闭`)
  }

  let purifier = state.devices.find(d => d.type === DeviceType.PURIFIER)
  if (purifier && env.pm25 > THRESHOLDS.pm25.good && !purifier.isOn && !isManualOverride(state, purifier.id)) {
    purifier.isOn = true
    results.push(`学习模式：已开启${purifier.name}`)
  } else if (purifier && isManualOverride(state, purifier.id)) {
    results.push(`学习模式：${purifier.name}已被手动接管，跳过开启`)
  }

  return results
}

function handleChildScene(state: AppState, env: EnvironmentData): string[] {
  let results: string[] = []

  let light = state.devices.find(d => d.type === DeviceType.LIGHT)
  if (light && !light.isOn && !isManualOverride(state, light.id)) {
    light.isOn = true
    results.push(`儿童模式：已开启${light.name}`)
  } else if (light && isManualOverride(state, light.id)) {
    results.push(`儿童模式：${light.name}已被手动接管，跳过开启`)
  }

  let purifier = state.devices.find(d => d.type === DeviceType.PURIFIER)
  if (purifier && env.pm25 > 25 && !purifier.isOn && !isManualOverride(state, purifier.id)) {
    purifier.isOn = true
    results.push(`儿童模式：已开启${purifier.name}`)
  } else if (purifier && isManualOverride(state, purifier.id)) {
    results.push(`儿童模式：${purifier.name}已被手动接管，跳过开启`)
  }

  let humidifier = state.devices.find(d => d.type === DeviceType.HUMIDIFIER)
  if (humidifier && env.humidity < 45 && !humidifier.isOn && !isManualOverride(state, humidifier.id)) {
    humidifier.isOn = true
    humidifier.targetValue = 50
    results.push(`儿童模式：已开启${humidifier.name}`)
  } else if (humidifier && isManualOverride(state, humidifier.id)) {
    results.push(`儿童模式：${humidifier.name}已被手动接管，跳过开启`)
  }

  return results
}

function handleElderlyScene(state: AppState, env: EnvironmentData): string[] {
  let results: string[] = []

  let purifier = state.devices.find(d => d.type === DeviceType.PURIFIER)
  if (purifier && env.pm25 > THRESHOLDS.pm25.good && !purifier.isOn && !isManualOverride(state, purifier.id)) {
    purifier.isOn = true
    results.push(`老人模式：已开启${purifier.name}`)
  } else if (purifier && isManualOverride(state, purifier.id)) {
    results.push(`老人模式：${purifier.name}已被手动接管，跳过开启`)
  }

  let humidifier = state.devices.find(d => d.type === DeviceType.HUMIDIFIER)
  if (humidifier && env.humidity < THRESHOLDS.humidity.min && !humidifier.isOn && !isManualOverride(state, humidifier.id)) {
    humidifier.isOn = true
    humidifier.targetValue = 50
    results.push(`老人模式：已开启${humidifier.name}`)
  } else if (humidifier && isManualOverride(state, humidifier.id)) {
    results.push(`老人模式：${humidifier.name}已被手动接管，跳过开启`)
  }

  let ac = state.devices.find(d => d.type === DeviceType.AC)
  if (ac && env.temperature > THRESHOLDS.temperature.max && !ac.isOn && !isManualOverride(state, ac.id)) {
    ac.isOn = true
    ac.targetValue = 26
    results.push(`老人模式：已开启${ac.name}至26°C`)
  } else if (ac && isManualOverride(state, ac.id)) {
    results.push(`老人模式：${ac.name}已被手动接管，跳过自动调节`)
  }

  return results
}

function handleAwayScene(state: AppState): string[] {
  let results: string[] = []
  let curtain = state.devices.find(d => d.type === DeviceType.CURTAIN)
  let curtainWasOn = curtain ? curtain.isOn : false

  results = results.concat(executeAllOff(state))

  if (curtain && curtainWasOn) {
    results.push(`离家模式：已关闭${curtain.name}`)
  }

  return results
}

function handleNormalScene(state: AppState): string[] {
  return ['当前为普通模式，设备状态无需调整']
}

// 切换场景时的设备联动
export function applySceneAutomation(state: AppState): string[] {
  let env = state.currentEnv
  let results: string[] = []

  switch (state.currentScene) {
    case '睡眠模式':
      results = handleSleepScene(state, env)
      break
    case '学习模式':
      results = handleStudyScene(state, env)
      break
    case '儿童模式':
      results = handleChildScene(state, env)
      break
    case '老人模式':
      results = handleElderlyScene(state, env)
      break
    case '离家模式':
      results = handleAwayScene(state)
      break
    default:
      results = handleNormalScene(state)
      break
  }

  recordOperation(state, results.join('\n'))

  return results
}
