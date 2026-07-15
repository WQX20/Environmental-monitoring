// ============================================================
// 智慧环境生活管家 — 根入口 (现代导航容器)
// ============================================================
import { HomePage } from './HomePage'
import { ScenePage } from './ScenePage'
import { DevicePage } from './DevicePage'
import { AiAdvicePage } from './AiAdvicePage'
import { COLORS, RADIUS, FONTS, DURATION, ICONS } from '../data/Constants'
import { subscribeStateChange } from '../service/DeviceController'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  @State uiRevision: number = 0
  private tabTitles: string[] = ['首页', '场景', '设备', 'AI']
  private tabIcons: string[] = [ICONS.navHome, ICONS.navScene, ICONS.navDevice, ICONS.navAi]
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
    Column() {
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
      .barHeight(68)
      .barBackgroundColor('#FFFFFF')
      .animationDuration(DURATION.normal)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .fadingEdge(false)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.bgPrimary)
  }

  @Builder
  buildTabBar(index: number): void {
    Column() {
      // 图标
      Text(this.tabIcons[index])
        .fontSize(24)
        .scale(this.currentIndex === index ? { x: 1.2, y: 1.2 } : { x: 1.0, y: 1.0 })
        .animation({ duration: DURATION.normal, curve: Curve.EaseOut })

      // 标题
      Text(this.tabTitles[index])
        .fontSize(FONTS.caption)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? COLORS.primary : COLORS.textTertiary)
        .margin({ top: 3 })

      // 激活指示器
      if (this.currentIndex === index) {
        Circle()
          .width(5)
          .height(5)
          .fill(COLORS.primary)
          .margin({ top: 5 })
      } else {
        Circle()
          .width(5)
          .height(5)
          .fill('transparent')
          .margin({ top: 5 })
      }
    }
    .padding({ top: 8, bottom: 6 })
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
