// ============================================================
// 设备控制卡片 — 主题色 + 开关 + 可展开滑块
// ============================================================
import { DeviceType } from '../model/DataModels'
import { COLORS, RADIUS, FONTS, DURATION } from '../data/Constants'

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
    Column({ space: 0 }) {
      // ═══ 主控制行 ═══
      Row({ space: 14 }) {
        // 设备图标圆
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(48).height(48)
            .fill(this.isOn ? this.getAccent() + '18' : COLORS.bgPrimary)
            .border({ width: 2, color: this.isOn ? this.getAccent() + '40' : COLORS.borderLight })
          Text(this.deviceIcon).fontSize(24)
        }
        .width(48).height(48)

        // 名称 + 状态
        Column({ space: 3 }) {
          Text(this.deviceName)
            .fontSize(FONTS.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(COLORS.textPrimary)
          Row({ space: 6 }) {
            Circle()
              .width(7).height(7)
              .fill(this.isOn ? COLORS.success : COLORS.textTertiary)
            Text(this.getStatusText())
              .fontSize(FONTS.caption)
              .fontColor(this.isOn ? COLORS.textSecondary : COLORS.textTertiary)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 开关
        Toggle({ type: ToggleType.Switch, isOn: this.isOn })
          .selectedColor(COLORS.primary)
          .switchPointColor('#FFFFFF')
          .onChange((value: boolean) => {
            if (this.onDeviceToggle) this.onDeviceToggle(this.deviceId)
          })
      }
      .width('100%')
      .onClick(() => { this.isExpanded = !this.isExpanded })

      // ═══ 展开滑块区 ═══
      if (this.isExpanded && this.isOn) {
        Column({ space: 0 }) {
          // 分割线
          Row()
            .width('100%')
            .height(1)
            .backgroundColor(COLORS.borderLight)
            .margin({ top: 14, bottom: 12 })

          // 当前值显示
          Row({ space: 4 }) {
            Text('目标值')
              .fontSize(FONTS.caption)
              .fontColor(COLORS.textTertiary)
            Text(`${this.targetValue}${this.unit}`)
              .fontSize(FONTS.bodyLg)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getAccent())
          }
          .width('100%')
          .margin({ bottom: 10 })

          // 滑块行
          Row({ space: 10 }) {
            Text(`${this.getSliderMin()}${this.unit}`)
              .fontSize(10)
              .fontColor(COLORS.textTertiary)
              .width(32).textAlign(TextAlign.Center)

            Slider({
              value: this.targetValue,
              min: this.getSliderMin(),
              max: this.getSliderMax(),
              step: this.getSliderStep()
            })
              .layoutWeight(1)
              .blockColor(this.getAccent())
              .trackColor('#E2E8F0')
              .selectedColor(this.getAccent())
              .trackThickness(4)
              .onChange((value: number) => {
                if (this.onTargetUpdate) this.onTargetUpdate(this.deviceId, value)
              })

            Text(`${this.getSliderMax()}${this.unit}`)
              .fontSize(10)
              .fontColor(COLORS.textTertiary)
              .width(32).textAlign(TextAlign.Center)
          }
          .width('100%')
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.isOn ? this.getAccent() + '08' : COLORS.surface)
    .borderRadius(RADIUS.xl)
    .border({ width: 1, color: this.isOn ? this.getAccent() + '30' : COLORS.borderLight })
    .shadow({ radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 })
    .margin({ bottom: 10 })
  }

  getStatusText(): string {
    if (!this.isOn) return '已关闭'
    if (this.deviceType === DeviceType.AC) return `运行中 · 当前 ${this.currentValue}°C`
    if (this.deviceType === DeviceType.PURIFIER) return `运行中 · PM2.5 ${this.currentValue}μg/m³`
    if (this.deviceType === DeviceType.HUMIDIFIER) return `运行中 · ${this.currentValue}%`
    if (this.deviceType === DeviceType.LIGHT) return `运行中 · 亮度 ${this.currentValue}%`
    if (this.deviceType === DeviceType.CURTAIN) return `已打开 · ${this.currentValue}%`
    return '运行中'
  }

  getAccent(): string {
    if (this.deviceType === DeviceType.AC) return '#3B82F6'
    if (this.deviceType === DeviceType.PURIFIER) return '#8B5CF6'
    if (this.deviceType === DeviceType.HUMIDIFIER) return '#06B6D4'
    if (this.deviceType === DeviceType.LIGHT) return '#F59E0B'
    if (this.deviceType === DeviceType.CURTAIN) return '#64748B'
    return COLORS.primary
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
