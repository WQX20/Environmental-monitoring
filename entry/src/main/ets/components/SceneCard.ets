// ============================================================
// 场景卡片 — 场景专属色 + 激活态光效
// ============================================================
import { COLORS, RADIUS, FONTS, SCENE_COLORS, DURATION } from '../data/Constants'

@Component
export struct SceneCard {
  @Prop icon: string = '🏠'
  @Prop title: string = ''
  @Prop description: string = ''
  @Prop isActive: boolean = false
  @Prop color: string = '#E8F5E9'
  onToggle?: () => void

  build() {
    Column({ space: 0 }) {
      // ── 主内容区 ──
      Row({ space: 12 }) {
        // 图标圆
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(48).height(48)
            .fill(this.isActive ? 'rgba(255,255,255,0.25)' : COLORS.bgPrimary)
          Text(this.icon).fontSize(26)
        }
        .width(48).height(48)

        // 标题 + 描述
        Column({ space: 4 }) {
          Text(this.title)
            .fontSize(FONTS.body)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isActive ? COLORS.textInverse : COLORS.textPrimary)
          Text(this.description)
            .fontSize(FONTS.caption)
            .fontColor(this.isActive ? 'rgba(255,255,255,0.80)' : COLORS.textTertiary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .lineHeight(15)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      // ── 状态标签行 ──
      Row() {
        if (this.isActive) {
          Row({ space: 6 }) {
            Circle().width(6).height(6).fill('#FFFFFF')
            Text('运行中')
              .fontSize(FONTS.caption)
              .fontWeight(FontWeight.Medium)
              .fontColor(COLORS.textInverse)
          }
          .padding({ top: 5, bottom: 5, left: 12, right: 12 })
          .backgroundColor('rgba(255,255,255,0.20)')
          .borderRadius(RADIUS.full)
        } else {
          Text('点击激活')
            .fontSize(FONTS.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor(COLORS.primary)
            .padding({ top: 5, bottom: 5, left: 12, right: 12 })
            .backgroundColor(COLORS.primarySoft)
            .borderRadius(RADIUS.full)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .margin({ top: 14 })
    }
    .width('100%')
    .padding(16)
    .constraintSize({ minHeight: 140 })
    .backgroundColor(this.isActive ? (SCENE_COLORS[this.title] || COLORS.primary) : COLORS.surface)
    .borderRadius(RADIUS.xl)
    .border({ width: this.isActive ? 0 : 1, color: COLORS.borderLight })
    .shadow(this.isActive ?
      { radius: 20, color: 'rgba(13,148,136,0.25)', offsetY: 0 } :
      { radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 })
    .scale(this.isActive ? { x: 1.03, y: 1.03 } : { x: 1.0, y: 1.0 })
    .animation({ duration: DURATION.normal, curve: Curve.EaseOut })
    .onClick(() => { if (this.onToggle) this.onToggle() })
  }
}
