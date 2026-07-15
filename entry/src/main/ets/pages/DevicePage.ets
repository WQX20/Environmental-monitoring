// ============================================================
// 设备页 — 控制列表 + 统计 + 一键全关
// ============================================================
import { AppState, Device } from '../model/DataModels'
import { DeviceCard } from '../components/DeviceCard'
import { LinkagePanel } from '../components/LinkagePanel'
import { toggleDevice, updateDeviceTarget, executeAllOff, publishOperation, clearAllManualOverrides, clearManualOverride, subscribeStateChange } from '../service/DeviceController'
import { sharedState } from '../data/AppStateManager'
import { COLORS, FONTS, RADIUS, DURATION, ICONS } from '../data/Constants'

@Component
export struct DevicePage {
  @Prop uiRevision: number = 0
  @State appState: AppState = sharedState
  @State toastMessage: string = ''
  @State showToast: boolean = false
  @State refreshToken: number = 0
  private unsubscribeStateChange: (() => void) | undefined = undefined

  aboutToAppear(): void {
    this.unsubscribeStateChange = subscribeStateChange(() => { this.refreshToken++ })
  }
  aboutToDisappear(): void {
    if (this.unsubscribeStateChange) { this.unsubscribeStateChange(); this.unsubscribeStateChange = undefined }
  }

  handleToggle(deviceId: string): void {
    let device = this.appState.devices.find(d => d.id === deviceId)
    if (device) {
      let msg = toggleDevice(device)
      if (device.isOn) { clearManualOverride(this.appState, device.id) }
      else { if (!this.appState.manualOverrideDeviceIds.includes(device.id)) this.appState.manualOverrideDeviceIds.push(device.id) }
      publishOperation(this.appState, msg)
      this.showToastMessage(msg)
    }
  }

  handleUpdateTarget(deviceId: string, value: number): void {
    let device = this.appState.devices.find(d => d.id === deviceId)
    if (device) {
      updateDeviceTarget(device, value)
      let msg = `${device.name} → ${value}${device.unit}`
      if (!this.appState.manualOverrideDeviceIds.includes(device.id)) this.appState.manualOverrideDeviceIds.push(device.id)
      publishOperation(this.appState, msg)
      this.showToastMessage(msg)
    }
  }

  handleAllOff(): void {
    let results = executeAllOff(this.appState)
    clearAllManualOverrides(this.appState)
    this.showToastMessage('所有设备已关闭')
  }

  showToastMessage(msg: string): void {
    this.toastMessage = msg
    this.showToast = true
    setTimeout(() => { this.showToast = false }, DURATION.toast)
  }

  getSummary(): string {
    let on = this.appState.devices.filter(d => d.isOn).length
    if (on === 0) return '所有设备已关闭'
    return `${on}/${this.appState.devices.length} 台运行中`
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column({ space: 0 }) {
          // ═══ 头部 ═══
          Row() {
            Column({ space: 4 }) {
              Text('设备中心').fontSize(FONTS.titleLg).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
              Text(this.getSummary()).fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Button() {
              Row({ space: 4 }) {
                Text(ICONS.powerOff).fontSize(16)
                Text('全关').fontSize(FONTS.caption).fontWeight(FontWeight.Bold)
              }
            }
            .height(36)
            .backgroundColor(COLORS.surface)
            .fontColor(COLORS.danger)
            .borderRadius(RADIUS.lg)
            .border({ width: 1.5, color: '#FECACA' })
            .padding({ left: 12, right: 12 })
            .onClick(() => { this.handleAllOff() })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20, bottom: 16 })

          // ═══ 设备列表 ═══
          List() {
            ForEach(this.appState.devices, (device: Device) => {
              ListItem() {
                DeviceCard({
                  deviceName: device.name, deviceIcon: device.icon, deviceId: device.id,
                  deviceType: device.type, isOn: device.isOn,
                  targetValue: device.targetValue, currentValue: device.currentValue, unit: device.unit,
                  onDeviceToggle: (id: string): void => { this.handleToggle(id) },
                  onTargetUpdate: (id: string, value: number): void => { this.handleUpdateTarget(id, value) }
                })
              }
            }, (device: Device) => `${device.id}_${this.refreshToken}`)
          }
          .width('92%')
          .margin({ bottom: 16 })

          // ═══ 联动面板 ═══
          LinkagePanel({
            panelTitle: '联动面板',
            currentScene: this.appState.currentScene,
            lastOperationMessage: this.appState.lastOperationMessage,
            operationHistory: this.appState.operationHistory,
            onAllOff: (): void => { this.handleAllOff() },
            refreshSeed: this.refreshToken
          })
          .margin({ left: 16, right: 16, bottom: 24 })

          Blank().height(80)
        }
        .width('100%')
      }
      .width('100%').height('100%')
      .backgroundColor(COLORS.bgPrimary)

      // ═══ Toast ═══
      if (this.showToast) {
        Row({ space: 8 }) {
          Text(this.toastMessage)
            .fontSize(FONTS.caption)
            .fontColor(COLORS.textInverse)
        }
        .padding({ top: 12, bottom: 12, left: 20, right: 20 })
        .backgroundColor('#1E293B')
        .borderRadius(RADIUS.lg)
        .shadow({ radius: 16, color: 'rgba(30,41,59,0.50)', offsetY: 6 })
        .margin({ bottom: 100 })
      }
    }
    .width('100%').height('100%')
  }
}
