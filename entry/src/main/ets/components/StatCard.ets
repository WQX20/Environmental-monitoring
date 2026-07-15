// ============================================================
// 统计卡片 — 图标 + 标题 + 数值 + 描述
// ============================================================
import { COLORS, RADIUS, FONTS } from '../data/Constants'

@Component
export struct StatCard {
  @Prop icon: string = ''
  @Prop label: string = ''
  @Prop value: string = ''
  @Prop subtext: string = ''
  @Prop accent: string = COLORS.primary
  @Prop fullWidth: boolean = false

  build() {
    Column({ space: 0 }) {
      // 图标圆
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(40).height(40)
          .fill(this.accent + '18')
        Text(this.icon)
          .fontSize(18)
          .fontColor(this.accent)
      }
      .width(40).height(40)
      .margin({ bottom: 10 })

      // 数值
      Text(this.value)
        .fontSize(FONTS.title)
        .fontWeight(FontWeight.Bold)
        .fontColor(COLORS.textPrimary)
        .margin({ bottom: 2 })

      // 标题
      Text(this.label)
        .fontSize(FONTS.caption)
        .fontColor(COLORS.textTertiary)
        .margin({ bottom: 2 })

      // 副文本
      if (this.subtext !== '') {
        Text(this.subtext)
          .fontSize(10)
          .fontColor(COLORS.textTertiary)
      }
    }
    .width(this.fullWidth ? '100%' : '48%')
    .padding(16)
    .backgroundColor(COLORS.surface)
    .borderRadius(RADIUS.lg)
    .shadow({ radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 })
    .alignItems(HorizontalAlign.Start)
  }
}
