// ============================================================
// 单项环境指标展示行
// ============================================================
import { COLORS, THRESHOLDS } from '../data/Constants'

@Component
export struct MetricRow {
  @Prop label: string = ''
  @Prop value: number = 0
  @Prop unit: string = ''
  @Prop icon: string = ''
  @Prop status: string = 'normal' // 'normal' | 'warning' | 'danger'

  build() {
    Row() {
      // 图标
      Text(this.icon)
        .fontSize(24)
        .width(40)
        .textAlign(TextAlign.Center)

      // 标签和数值
      Column() {
        Text(this.label)
          .fontSize(12)
          .fontColor(COLORS.textSecondary)
        Text(`${this.value} ${this.unit}`)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getValueColor())
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 状态条
      Progress({
        value: this.getProgressValue(),
        total: 100,
        type: ProgressType.Linear
      })
        .width(60)
        .height(4)
        .color(this.getBarColor())
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
    .backgroundColor(COLORS.white)
    .borderRadius(12)
    .margin({ bottom: 6 })
  }

  getValueColor(): string {
    if (this.status === 'danger') return COLORS.danger
    if (this.status === 'warning') return COLORS.warning
    return COLORS.success
  }

  getBarColor(): string {
    if (this.status === 'danger') return COLORS.danger
    if (this.status === 'warning') return COLORS.warning
    return COLORS.success
  }

  getProgressValue(): number {
    // 返回一个基于正常范围的进度值
    return this.status === 'normal' ? 75 : this.status === 'warning' ? 45 : 25
  }
}
