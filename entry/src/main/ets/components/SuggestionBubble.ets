// ============================================================
// AI 建议气泡 — 左色条 + 分类图标 + 时间/操作区
// ============================================================
import { SuggestionCategory } from '../model/DataModels'
import { COLORS, RADIUS, FONTS } from '../data/Constants'

@Component
export struct SuggestionBubble {
  @Prop sugId: string = ''
  @Prop sugTimestamp: number = 0
  @Prop sugCategory: SuggestionCategory = SuggestionCategory.ENV
  @Prop sugTitle: string = ''
  @Prop sugDetail: string = ''
  @Prop sugActionLabel: string = ''
  @Prop sugActionType: string = ''
  @Prop sugIcon: string = ''
  onSuggestionAction?: () => void

  build() {
    Row({ space: 12 }) {
      // 图标圆
      Stack({ alignContent: Alignment.Center }) {
        Circle().width(40).height(40).fill(this.getCategoryBg())
        Text(this.sugIcon).fontSize(18)
      }
      .width(40).height(40)

      // 内容
      Column({ space: 0 }) {
        // 标题 + 分类标签
        Row({ space: 8 }) {
          Text(this.sugTitle)
            .fontSize(FONTS.bodySm)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.textPrimary)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.getCategoryLabel())
            .fontSize(9)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCategoryAccent())
            .padding({ top: 2, bottom: 2, left: 6, right: 6 })
            .backgroundColor(this.getCategoryBg())
            .borderRadius(RADIUS.full)
        }
        .width('100%')
        .margin({ bottom: 6 })

        // 详情
        Text(this.sugDetail)
          .fontSize(FONTS.caption)
          .fontColor(COLORS.textSecondary)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(17)
          .margin({ bottom: 8 })

        // 底部：时间 + 操作按钮
        Row({ space: 8 }) {
          Text(this.getTimeAgo())
            .fontSize(10)
            .fontColor(COLORS.textTertiary)

          Blank()

          if (this.sugActionType !== 'none') {
            Button() {
              Row({ space: 3 }) {
                Text(this.sugActionLabel).fontSize(11).fontWeight(FontWeight.Medium)
                Text('→').fontSize(11)
              }
            }
            .height(28)
            .fontSize(11)
            .backgroundColor(this.getCategoryAccent())
            .fontColor(COLORS.textInverse)
            .borderRadius(RADIUS.full)
            .padding({ left: 12, right: 10 })
            .onClick(() => { if (this.onSuggestionAction) this.onSuggestionAction() })
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 14, bottom: 14, left: 16, right: 16 })
    .backgroundColor(COLORS.surface)
    .borderRadius(RADIUS.lg)
    .border({ width: { left: 3 }, color: this.getCategoryAccent() })
    .shadow({ radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 })
    .margin({ bottom: 8 })
  }

  getCategoryAccent(): string {
    if (this.sugCategory === SuggestionCategory.ENV) return COLORS.info
    if (this.sugCategory === SuggestionCategory.HEALTH) return COLORS.danger
    if (this.sugCategory === SuggestionCategory.STUDY) return '#8B5CF6'
    if (this.sugCategory === SuggestionCategory.ENERGY) return COLORS.warning
    return COLORS.primary
  }

  getCategoryBg(): string {
    if (this.sugCategory === SuggestionCategory.ENV) return '#EFF6FF'
    if (this.sugCategory === SuggestionCategory.HEALTH) return '#FEF2F2'
    if (this.sugCategory === SuggestionCategory.STUDY) return '#F5F3FF'
    if (this.sugCategory === SuggestionCategory.ENERGY) return '#FFFBEB'
    return COLORS.primarySoft
  }

  getCategoryLabel(): string {
    if (this.sugCategory === SuggestionCategory.ENV) return '环境'
    if (this.sugCategory === SuggestionCategory.HEALTH) return '健康'
    if (this.sugCategory === SuggestionCategory.STUDY) return '学习'
    if (this.sugCategory === SuggestionCategory.ENERGY) return '节能'
    return '建议'
  }

  getTimeAgo(): string {
    let diff = Date.now() - this.sugTimestamp
    let minutes = Math.floor(diff / 60000)
    if (minutes < 1) return '刚刚'
    if (minutes < 60) return `${minutes}分钟前`
    return `${Math.floor(minutes / 60)}小时前`
  }
}
