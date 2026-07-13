// ============================================================
// 智慧环境生活管家 — 根入口 (Tab 导航容器)
// ============================================================
import { HomePage } from './HomePage'
import { ScenePage } from './ScenePage'
import { DevicePage } from './DevicePage'
import { AiAdvicePage } from './AiAdvicePage'
import { COLORS } from '../data/Constants'
import { subscribeStateChange } from '../service/DeviceController'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  @State uiRevision: number = 0
  private tabTitles: string[] = ['首页', '场景', '设备', 'AI建议']
  private tabIcons: string[] = ['🏠', '🎯', '🔌', '🤖']
  private unsubscribeStateChange: (() => void) | undefined = undefined

  aboutToAppear(): void {
    this.unsubscribeStateChange = subscribeStateChange(() => {
      this.uiRevision++
    })
  }

  aboutToDisappear(): void {
    if (this.unsubscribeStateChange) {
      this.unsubscribeStateChange()
      this.unsubscribeStateChange = undefined
    }
  }

  build() {
    Tabs({ index: $$this.currentIndex }) {
      TabContent() {
        HomePage({ uiRevision: this.uiRevision })
      }
      .tabBar(this.buildTabBar(0))

      TabContent() {
        ScenePage({ uiRevision: this.uiRevision })
      }
      .tabBar(this.buildTabBar(1))

      TabContent() {
        DevicePage({ uiRevision: this.uiRevision })
      }
      .tabBar(this.buildTabBar(2))

      TabContent() {
        AiAdvicePage({ uiRevision: this.uiRevision })
      }
      .tabBar(this.buildTabBar(3))
    }
    .barPosition(BarPosition.End)
    .barHeight(60)
    .barBackgroundColor(COLORS.white)
    .animationDuration(200)
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }

  @Builder
  buildTabBar(index: number): void {
    Column() {
      Text(this.tabIcons[index])
        .fontSize(22)
      Text(this.tabTitles[index])
        .fontSize(10)
        .fontColor(index === this.currentIndex ? COLORS.primary : COLORS.textSecondary)
        .margin({ top: 2 })
    }
    .padding({ top: 6, bottom: 6 })
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
