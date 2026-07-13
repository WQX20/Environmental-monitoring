// ============================================================
// AI 建议气泡
// ============================================================
import { Suggestion, SuggestionCategory } from '../model/DataModels'
import { COLORS } from '../data/Constants'

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
    Row() {
      // 左侧图标
      Column() {
        Text(this.sugIcon)
          .fontSize(24)
      }
      .width(44)
      .height(44)
      .borderRadius(22)
      .backgroundColor(this.getCategoryBg())
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 中间内容
      Column() {
        Row() {
          Text(this.sugTitle)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(COLORS.text)
            .layoutWeight(1)
          Text(this.getTimeAgo())
            .fontSize(11)
            .fontColor(COLORS.textHint)
        }
        .width('100%')

        Text(this.sugDetail)
          .fontSize(13)
          .fontColor(COLORS.textSecondary)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .margin({ left: 10 })

      // 右侧操作按钮
      if (this.sugActionType !== 'none') {
        Button(this.sugActionLabel)
          .fontSize(11)
          .height(28)
          .backgroundColor(COLORS.primary)
          .fontColor(COLORS.white)
          .borderRadius(14)
          .padding({ left: 10, right: 10 })
          .onClick(() => {
            if (this.onSuggestionAction) {
              this.onSuggestionAction()
            }
          })
          .margin({ left: 6 })
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(COLORS.white)
    .borderRadius(14)
    .border({ width: 1, color: COLORS.divider })
    .margin({ bottom: 8 })
  }

  getCategoryBg(): string {
    if (this.sugCategory === SuggestionCategory.ENV) return COLORS.info + '20'
    if (this.sugCategory === SuggestionCategory.HEALTH) return COLORS.danger + '20'
    if (this.sugCategory === SuggestionCategory.STUDY) return COLORS.accent + '20'
    if (this.sugCategory === SuggestionCategory.ENERGY) return COLORS.warning + '20'
    return COLORS.darkOverlay
  }

  getTimeAgo(): string {
    let diff = Date.now() - this.sugTimestamp
    let minutes = Math.floor(diff / 60000)
    if (minutes < 1) return '刚刚'
    if (minutes < 60) return `${minutes}分钟前`
    let hours = Math.floor(minutes / 60)
    return `${hours}小时前`
  }
}
