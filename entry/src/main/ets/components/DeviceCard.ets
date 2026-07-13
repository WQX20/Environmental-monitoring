// ============================================================
// 设备控制卡片
// ============================================================
import { Device, DeviceType } from '../model/DataModels'
import { COLORS } from '../data/Constants'

@Component
export struct DeviceCard {
  @Prop deviceName: string = ''
  @Prop deviceIcon: string = ''
  @Prop deviceId: string = ''
  @Prop deviceType: DeviceType = DeviceType.AC
  @Prop isOn: boolean = false
  @Prop targetValue: number = 0
  @Prop currentValue: number = 0
  @Prop unit: string = ''
  @State isExpanded: boolean = false
  onDeviceToggle?: (id: string) => void
  onTargetUpdate?: (id: string, value: number) => void

  build() {
    Column() {
      // 主行：图标 + 名称 + 开关
      Row() {
        Text(this.deviceIcon)
          .fontSize(28)
          .width(44)
          .textAlign(TextAlign.Center)

        Column() {
          Text(this.deviceName)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(COLORS.text)
          Text(this.getStatusText())
            .fontSize(12)
            .fontColor(this.isOn ? COLORS.success : COLORS.textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 8 })

        Toggle({ type: ToggleType.Switch, isOn: this.isOn })
          .onChange((value: boolean) => {
            if (this.onDeviceToggle) {
              this.onDeviceToggle(this.deviceId)
            }
          })
      }
      .width('100%')
      .onClick(() => {
        this.isExpanded = !this.isExpanded
      })

      // 展开的滑块控制
      if (this.isExpanded && this.isOn) {
        Row() {
          Text(`目标: ${this.targetValue}${this.unit}`)
            .fontSize(12)
            .fontColor(COLORS.textSecondary)
          Slider({
            value: this.targetValue,
            min: this.getSliderMin(),
            max: this.getSliderMax(),
            step: this.getSliderStep()
          })
            .layoutWeight(1)
            .margin({ left: 12, right: 12 })
            .onChange((value: number) => {
              if (this.onTargetUpdate) {
                this.onTargetUpdate(this.deviceId, value)
              }
            })
        }
        .width('100%')
        .padding({ top: 12, left: 52 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.isOn ? COLORS.primaryLight + '15' : COLORS.white)
    .borderRadius(14)
    .border({ width: 1, color: this.isOn ? COLORS.primaryLight : COLORS.divider })
    .margin({ bottom: 8 })
  }

  getStatusText(): string {
    if (!this.isOn) return '已关闭'
    if (this.deviceType === DeviceType.AC) {
      return `运行中 · 当前${this.currentValue}°C`
    }
    if (this.deviceType === DeviceType.PURIFIER) {
      return `运行中 · PM2.5 ${this.currentValue}μg/m³`
    }
    if (this.deviceType === DeviceType.HUMIDIFIER) {
      return `运行中 · ${this.currentValue}%`
    }
    if (this.deviceType === DeviceType.LIGHT) {
      return `运行中 · 亮度${this.currentValue}%`
    }
    if (this.deviceType === DeviceType.CURTAIN) {
      return `已打开 · ${this.currentValue}%`
    }
    return '运行中'
  }

  getSliderMin(): number {
    if (this.deviceType === DeviceType.AC) return 18
    if (this.deviceType === DeviceType.HUMIDIFIER) return 30
    return 0
  }

  getSliderMax(): number {
    if (this.deviceType === DeviceType.AC) return 30
    if (this.deviceType === DeviceType.HUMIDIFIER) return 80
    return 100
  }

  getSliderStep(): number {
    if (this.deviceType === DeviceType.AC) return 1
    return 5
  }
}
