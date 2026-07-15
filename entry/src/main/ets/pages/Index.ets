// ============================================================
// 智慧环境生活管家 — 根入口 (对齐Tab导航)
// ============================================================
import { HomePage } from './HomePage'
import { ScenePage } from './ScenePage'
import { DevicePage } from './DevicePage'
import { AiAdvicePage } from './AiAdvicePage'
import { ProfilePage } from './ProfilePage'
import { COLORS, FONTS, DURATION, ICONS, THEME_PRESETS } from '../data/Constants'
import { subscribeStateChange } from '../service/DeviceController'
import { sharedState } from '../data/AppStateManager'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  @State uiRevision: number = 0
  private tabTitles: string[] = ['首页', '场景', '设备', 'AI', '我的']
  private unsubscribeStateChange: (() => void) | undefined = undefined

  getThemePrimary(): string {
    return THEME_PRESETS[sharedState.currentThemeKey]?.primary || COLORS.primary
  }

  aboutToAppear(): void {
    this.unsubscribeStateChange = subscribeStateChange(() => { this.uiRevision++ })
  }
  aboutToDisappear(): void {
    if (this.unsubscribeStateChange) { this.unsubscribeStateChange(); this.unsubscribeStateChange = undefined }
  }

  build() {
    Column() {
      Tabs({ index: $$this.currentIndex }) {
        TabContent() { HomePage({ uiRevision: this.uiRevision }) }
        .tabBar(this.tabIcon(0, ICONS.navHome))

        TabContent() { ScenePage({ uiRevision: this.uiRevision }) }
        .tabBar(this.tabIcon(1, ICONS.navScene))

        TabContent() { DevicePage({ uiRevision: this.uiRevision }) }
        .tabBar(this.tabIcon(2, ICONS.navDevice))

        TabContent() { AiAdvicePage({ uiRevision: this.uiRevision }) }
        .tabBar(this.tabIcon(3, ICONS.navAi))

        TabContent() { ProfilePage({ uiRevision: this.uiRevision }) }
        .tabBar(this.buildPersonTab(4))
      }
      .barPosition(BarPosition.End)
      .barHeight(66)
      .barBackgroundColor('#FFFFFF')
      .animationDuration(DURATION.normal)
      .onChange((index: number) => { this.currentIndex = index })
      .fadingEdge(false)
    }
    .width('100%').height('100%')
    .backgroundColor(COLORS.bgPrimary)
  }

  // ── 普通图标 Tab ──
  @Builder
  tabIcon(index: number, icon: string): void {
    Column() {
      Text(icon)
        .fontSize(this.currentIndex === index ? 24 : 22)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .animation({ duration: DURATION.normal, curve: Curve.EaseOut })
        .margin({ bottom: 4 })

      Text(this.tabTitles[index])
        .fontSize(9)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? this.getThemePrimary() : COLORS.textTertiary)
        .margin({ bottom: 3 })

      Circle()
        .width(4).height(4)
        .fill(this.currentIndex === index ? this.getThemePrimary() : 'transparent')
    }
    .padding({ top: 5, bottom: 7 })
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  // ── 个人中心 Tab (圆头+梯形身 简笔小人) ──
  @Builder
  buildPersonTab(index: number): void {
    Column() {
      Column({ space: -2 }) {
        Circle()
          .width(10).height(10)
          .fill(this.currentIndex === index ? this.getThemePrimary() : COLORS.textTertiary)
        Polygon()
          .points([[3, 0], [17, 0], [20, 12], [0, 12]])
          .width(20).height(12)
          .fill(this.currentIndex === index ? this.getThemePrimary() : COLORS.textTertiary)
      }
      .width(22).alignItems(HorizontalAlign.Center)
      .scale(this.currentIndex === index ? { x: 1.1, y: 1.1 } : { x: 1.0, y: 1.0 })
      .animation({ duration: DURATION.normal, curve: Curve.EaseOut })
      .margin({ bottom: 4 })

      Text(this.tabTitles[index])
        .fontSize(9)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? this.getThemePrimary() : COLORS.textTertiary)
        .margin({ bottom: 3 })

      Circle()
        .width(4).height(4)
        .fill(this.currentIndex === index ? this.getThemePrimary() : 'transparent')
    }
    .padding({ top: 5, bottom: 7 })
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
