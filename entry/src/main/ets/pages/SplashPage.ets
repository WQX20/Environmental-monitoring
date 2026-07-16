// ============================================================
// 闪屏页 — EIL品牌展示 → 2.2秒跳转登录
// ============================================================
import { router } from '@kit.ArkUI'
import { COLORS, FONTS } from '../data/Constants'
import { EilLogo } from '../components/EilLogo'

@Entry
@Component
struct SplashPage {
  @State fadeOpacity: number = 0

  aboutToAppear(): void {
    setTimeout(() => { this.fadeOpacity = 1 }, 100)
    setTimeout(() => { router.replaceUrl({ url: 'pages/LoginPage' }) }, 2200)
  }

  build() {
    Column({ space: 0 }) {
      // EIL Logo
      Column() {
        EilLogo({ logoSize: 130, logoColor: COLORS.primary })
      }
      .opacity(this.fadeOpacity)
      .scale({ x: this.fadeOpacity, y: this.fadeOpacity })
      .animation({ duration: 600, curve: Curve.EaseOut })
      .margin({ top: 80, bottom: 30 })

      Text('智慧生活管家')
        .fontSize(28).fontWeight(FontWeight.Bold).fontColor(COLORS.primary)
        .opacity(this.fadeOpacity).animation({ duration: 800, curve: Curve.EaseOut })
        .margin({ bottom: 6 })

      Text('Environment · Intelligent · Life')
        .fontSize(12).fontColor(COLORS.textTertiary).letterSpacing(2)
        .opacity(this.fadeOpacity).animation({ duration: 800, curve: Curve.EaseOut })

      Blank()

      Column({ space: 8 }) {
        LoadingProgress().width(28).height(28).color(COLORS.primary)
        Text('正在加载...').fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
      }
      .margin({ bottom: 60 })
      .opacity(this.fadeOpacity).animation({ duration: 1200, curve: Curve.EaseOut })
    }
    .width('100%').height('100%')
    .backgroundColor('#FFFFFF')
  }
}
