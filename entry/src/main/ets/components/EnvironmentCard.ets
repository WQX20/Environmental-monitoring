// ============================================================
// 环境评分卡片 — 双环进度 + 等级表情 + 异常标签列表
// ============================================================
import { EnvironmentScore } from '../model/DataModels'
import { COLORS, RADIUS, FONTS, ICONS } from '../data/Constants'

@Component
export struct EnvironmentCard {
  @Prop score: number = 100
  @Prop level: string = '舒适'
  @Prop suggestion: string = ''
  @Prop anomalies: string[] = []

  build() {
    Column({ space: 0 }) {
      // ═══ 评分环区 ═══
      Stack({ alignContent: Alignment.Center }) {
        // 光晕底
        Circle()
          .width(168)
          .height(168)
          .fill('rgba(94,234,212,0.10)')

        // 底环
        Circle()
          .width(152)
          .height(152)
          .fill(COLORS.surface)
          .stroke('#E2E8F0')
          .strokeWidth(12)

        // 进度环
        Progress({ value: this.score, total: 100, type: ProgressType.Ring })
          .width(152)
          .height(152)
          .color(this.getScoreColor())
          .style({ strokeWidth: 12 })

        // 中心数值组
        Column({ space: 0 }) {
          Text(`${this.score}`)
            .fontSize(FONTS.displayLg)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getScoreColor())
          Text(this.getLevelEmoji())
            .fontSize(18)
            .margin({ top: 2 })
          Text(this.level)
            .fontSize(FONTS.bodySm)
            .fontColor(COLORS.textTertiary)
            .margin({ top: 1 })
        }
        .alignItems(HorizontalAlign.Center)
      }
      .margin({ top: 4, bottom: 20 })

      // ═══ 分割线 ═══
      Divider()
        .width('75%')
        .color(COLORS.borderLight)
        .strokeWidth(0.5)
        .margin({ bottom: 16 })

      // ═══ 建议文案 ═══
      Row({ space: 8 }) {
        Text(ICONS.secSuggestion).fontSize(15)
        Text(this.suggestion)
          .fontSize(FONTS.bodySm)
          .fontColor(COLORS.textPrimary)
          .maxLines(2)
          .textAlign(TextAlign.Start)
          .layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: this.anomalies.length > 0 ? 14 : 0 })

      // ═══ 异常标签 (纵向排列，自然换行) ═══
      if (this.anomalies.length > 0) {
        Column({ space: 8 }) {
          ForEach(this.anomalies, (item: string) => {
            Row({ space: 6 }) {
              Text('!')
                .fontSize(10)
                .fontWeight(FontWeight.Bold)
                .fontColor('#EF4444')
                .width(18)
                .height(18)
                .backgroundColor('#FEE2E2')
                .borderRadius(9)
                .textAlign(TextAlign.Center)
              Text(item)
                .fontSize(FONTS.caption)
                .fontColor('#DC2626')
            }
            .padding({ top: 6, bottom: 6, left: 12, right: 14 })
            .backgroundColor('#FEF2F2')
            .borderRadius(RADIUS.full)
            .border({ width: 1, color: '#FECACA' })
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .padding({ top: 24, bottom: 22, left: 20, right: 20 })
    .backgroundColor(COLORS.surface)
    .borderRadius(RADIUS.xl)
    .shadow({ radius: 16, color: 'rgba(15,23,42,0.10)', offsetY: 4 })
  }

  getScoreColor(): string {
    if (this.score >= 85) return COLORS.success
    if (this.score >= 70) return COLORS.warning
    return COLORS.danger
  }

  getLevelEmoji(): string {
    if (this.score >= 85) return ICONS.levelGreat
    if (this.score >= 70) return ICONS.levelGood
    if (this.score >= 55) return ICONS.levelOkay
    return ICONS.levelBad
  }
}
