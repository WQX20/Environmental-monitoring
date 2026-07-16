// ============================================================
// EIL Logo — Environment · Intelligent · Life
// E=三横(环境), I=纵柱(智能), L=直角(生活)
// 三字母组合成抽象房屋轮廓
// ============================================================
import { COLORS } from '../data/Constants'

@Component
export struct EilLogo {
  @Prop logoSize: number = 64
  @Prop logoColor: string = COLORS.primary

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 白底圆角方
      Rect()
        .width(this.logoSize)
        .height(this.logoSize)
        .radius(this.logoSize * 0.22)
        .fill('#FFFFFF')
        .shadow({ radius: this.logoSize * 0.12, color: 'rgba(13,148,136,0.10)', offsetY: this.logoSize * 0.03 })

      // E-I-L 字母组合
      Row({ space: this.logoSize * 0.10 }) {
        // E — 三横 (环境 Environment)
        Column({ space: this.logoSize * 0.08 }) {
          Rect().width(this.logoSize * 0.16).height(this.logoSize * 0.07).radius(1).fill(this.logoColor)
          Rect().width(this.logoSize * 0.16).height(this.logoSize * 0.07).radius(1).fill(this.logoColor)
          Rect().width(this.logoSize * 0.16).height(this.logoSize * 0.07).radius(1).fill(this.logoColor)
        }
        .alignItems(HorizontalAlign.Start)

        // I — 纵柱 (智能 Intelligent)
        Rect()
          .width(this.logoSize * 0.07).height(this.logoSize * 0.56)
          .radius(1).fill(this.logoColor)

        // L — 直角 (生活 Life)
        Column({ space: 0 }) {
          Rect()
            .width(this.logoSize * 0.07).height(this.logoSize * 0.44)
            .radius(1).fill(this.logoColor)
          Rect()
            .width(this.logoSize * 0.16).height(this.logoSize * 0.07)
            .radius(1).fill(this.logoColor)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Bottom)
    }
    .width(this.logoSize)
    .height(this.logoSize)
  }
}
