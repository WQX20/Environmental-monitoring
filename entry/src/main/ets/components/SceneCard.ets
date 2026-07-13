// ============================================================
// 场景模式卡片
// ============================================================
import { COLORS, SCENE_DESCRIPTIONS } from '../data/Constants'

@Component
export struct SceneCard {
  @Prop icon: string = '🏠'
  @Prop title: string = ''
  @Prop description: string = ''
  @Prop isActive: boolean = false
  @Prop color: string = '#E8F5E9'
  onToggle?: () => void

  build() {
    Column() {
      Row() {
        Text(this.icon)
          .fontSize(32)
        Column() {
          Text(this.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.text)
          Text(this.description)
            .fontSize(11)
            .fontColor(COLORS.textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 10 })
      }
      .width('100%')

      Row() {
        Text(this.isActive ? '已激活' : '点击激活')
          .fontSize(12)
          .fontColor(this.isActive ? COLORS.white : COLORS.primary)
          .padding({ top: 4, bottom: 4, left: 12, right: 12 })
          .backgroundColor(this.isActive ? COLORS.primary : COLORS.primaryLight + '30')
          .borderRadius(12)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .margin({ top: 8 })

      if (this.isActive) {
        Text('✓ 设备已按场景预设调整')
          .fontSize(11)
          .fontColor(COLORS.success)
          .margin({ top: 6 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.isActive ? COLORS.primaryLight + '20' : COLORS.white)
    .borderRadius(14)
    .border({
      width: this.isActive ? 2 : 1,
      color: this.isActive ? COLORS.primary : COLORS.divider
    })
    .onClick(() => {
      if (this.onToggle) {
        this.onToggle()
      }
    })
  }
}
