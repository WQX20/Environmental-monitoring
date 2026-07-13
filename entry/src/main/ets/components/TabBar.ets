// ============================================================
// 底部导航栏
// ============================================================
import { COLORS } from '../data/Constants'

export interface TabItem {
  title: string
  icon: string
}

@Component
export struct TabBar {
  @Prop tabs: TabItem[] = []
  @Prop currentIndex: number = 0
  onChange?: (index: number) => void

  build() {
    Row() {
      ForEach(this.tabs, (tab: TabItem, index: number) => {
        Column() {
          Text(tab.icon)
            .fontSize(22)
          Text(tab.title)
            .fontSize(10)
            .fontColor(index === this.currentIndex ? COLORS.primary : COLORS.textSecondary)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .padding({ top: 8, bottom: 8 })
        .onClick(() => {
          if (this.onChange) {
            this.onChange(index)
          }
        })
      })
    }
    .width('100%')
    .height(56)
    .backgroundColor(COLORS.white)
    .border({ width: { top: 1 }, color: COLORS.divider })
  }
}
