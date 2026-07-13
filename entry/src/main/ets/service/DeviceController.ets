// ============================================================
// 智慧环境生活管家 — 设备联动控制
// ============================================================
import { AppState, Device, DeviceType } from '../model/DataModels'
import { THRESHOLDS } from '../data/Constants'

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
  let env = state.currentEnv

  // PM2.5 高 → 开净化器
  if (env.pm25 > THRESHOLDS.pm25.moderate) {
    let purifier = state.devices.find(d => d.type === DeviceType.PURIFIER)
    if (purifier && !purifier.isOn) {
      purifier.isOn = true
      executed.push(`已开启${purifier.name}`)
    }
  }

  // 温度高 → 开空调
  if (env.temperature > 28) {
    let ac = state.devices.find(d => d.type === DeviceType.AC)
    if (ac && !ac.isOn) {
      ac.isOn = true
      ac.targetValue = 26
      executed.push(`已开启${ac.name}，目标26°C`)
    }
  }

  // 湿度低 → 开加湿器
  if (env.humidity < THRESHOLDS.humidity.min) {
    let humidifier = state.devices.find(d => d.type === DeviceType.HUMIDIFIER)
    if (humidifier && !humidifier.isOn) {
      humidifier.isOn = true
      humidifier.targetValue = 50
      executed.push(`已开启${humidifier.name}，目标50%`)
    }
  }

  // 光照不足 → 开台灯
  if (env.light < THRESHOLDS.light.dim) {
    let light = state.devices.find(d => d.type === DeviceType.LIGHT)
    if (light && !light.isOn) {
      light.isOn = true
      executed.push(`已开启${light.name}`)
    }
  }

  if (executed.length === 0) {
    executed.push('当前环境良好，无需调整设备 ✅')
  }

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
