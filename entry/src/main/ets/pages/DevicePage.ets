// ============================================================
// 设备页：空气净化器/空调/加湿器/台灯/窗帘
// ============================================================
import { AppState, Device, DeviceType } from '../model/DataModels'
import { DeviceCard } from '../components/DeviceCard'
import { LinkagePanel } from '../components/LinkagePanel'
import { toggleDevice, updateDeviceTarget, executeAllOff, publishOperation, clearManualOverride, clearAllManualOverrides } from '../service/DeviceController'
import { sharedState } from '../data/AppStateManager'
import { COLORS } from '../data/Constants'

@Component
export struct DevicePage {
  @State appState: AppState = sharedState
  @State toastMessage: string = ''
  @State showToast: boolean = false

  handleToggle(deviceId: string): void {
    let device = this.appState.devices.find(d => d.id === deviceId)
    if (device) {
      let msg = toggleDevice(device)
      if (device.isOn) {
        this.appState.manualOverrideDeviceIds = this.appState.manualOverrideDeviceIds.filter(id => id !== device?.id)
      } else {
        if (!this.appState.manualOverrideDeviceIds.includes(device.id)) {
          this.appState.manualOverrideDeviceIds.push(device.id)
        }
      }
      publishOperation(this.appState, msg)
      this.showToastMessage(msg)
    }
  }

  handleUpdateTarget(deviceId: string, value: number): void {
    let device = this.appState.devices.find(d => d.id === deviceId)
    if (device) {
      updateDeviceTarget(device, value)
      let msg = `已将${device.name}目标值调整为${value}${device.unit}`
      if (!this.appState.manualOverrideDeviceIds.includes(device.id)) {
        this.appState.manualOverrideDeviceIds.push(device.id)
      }
      publishOperation(this.appState, msg)
      this.showToastMessage(msg)
    }
  }

  handleAllOff(): void {
    let results = executeAllOff(this.appState)
    clearAllManualOverrides(this.appState)
    this.showToastMessage(results.join('\n'))
  }

  showToastMessage(msg: string): void {
    this.toastMessage = msg
    this.showToast = true
    setTimeout(() => {
      this.showToast = false
    }, 2000)
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          // 标题
          Text('🔌 设备联动中心')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.text)
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 4 })

          Text('智能控制家中设备，一键联动优化环境')
            .fontSize(13)
            .fontColor(COLORS.textSecondary)
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 12 })

          // 设备列表
          List() {
            ForEach(this.appState.devices, (device: Device) => {
              ListItem() {
                DeviceCard({
                  deviceName: device.name,
                  deviceIcon: device.icon,
                  deviceId: device.id,
                  deviceType: device.type,
                  isOn: device.isOn,
                  targetValue: device.targetValue,
                  currentValue: device.currentValue,
                  unit: device.unit,
                  onDeviceToggle: (id: string): void => { this.handleToggle(id) },
                  onTargetUpdate: (id: string, value: number): void => { this.handleUpdateTarget(id, value) }
                })
              }
              .margin({ bottom: 4 })
            })
          }
          .width('90%')
          .padding({ bottom: 12 })

          LinkagePanel({
            panelTitle: '联动面板',
            currentScene: this.appState.currentScene,
            lastOperationMessage: this.appState.lastOperationMessage,
            operationHistory: this.appState.operationHistory,
            onAllOff: (): void => { this.handleAllOff() }
          })
          .margin({ bottom: 16 })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(COLORS.background)

      // Toast
      if (this.showToast) {
        Text(this.toastMessage)
          .fontSize(14)
          .fontColor(COLORS.white)
          .padding(14)
          .backgroundColor('#333333')
          .borderRadius(8)
          .position({ bottom: 80 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
