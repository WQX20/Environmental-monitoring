// ============================================================
// 环境指标行 — 状态圆标 + 数值 + 进度指示
// ============================================================
import { COLORS, RADIUS, FONTS } from '../data/Constants'

@Component
export struct MetricRow {
  @Prop label: string = ''
  @Prop value: number = 0
  @Prop unit: string = ''
  @Prop icon: string = ''
  @Prop status: string = 'normal'

  build() {
    Row({ space: 14 }) {
      // 图标圆 (带状态边框)
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(44)
          .height(44)
          .fill(this.getStatusBg())
          .border({ width: 2, color: this.getStatusBorder() })
        Text(this.icon).fontSize(20)
      }
      .width(44).height(44)

      // 标签 + 数值
      Column({ space: 2 }) {
        Text(this.label)
          .fontSize(FONTS.caption)
          .fontColor(COLORS.textTertiary)
        Row({ space: 3 }) {
          Text(`${this.value}`)
            .fontSize(FONTS.bodyLg)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getValueColor())
          Text(this.unit)
            .fontSize(10)
            .fontColor(COLORS.textTertiary)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右侧状态指示
      Column({ space: 5 }) {
        Row({ space: 0 }) {
          Progress({ value: this.getProgressValue(), total: 100, type: ProgressType.Linear })
            .width(56)
            .height(6)
            .color(this.getBarColor())
            .style({ strokeWidth: 6 })
        }
        Text(this.getStatusLabel())
          .fontSize(9)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getValueColor())
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding({ top: 14, bottom: 14, left: 16, right: 16 })
    .backgroundColor(COLORS.surface)
    .borderRadius(RADIUS.lg)
    .shadow({ radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 })
    .margin({ bottom: 8 })
  }

  getValueColor(): string {
    if (this.status === 'danger') return COLORS.danger
    if (this.status === 'warning') return COLORS.warning
    return COLORS.success
  }

  getBarColor(): string {
    if (this.status === 'danger') return COLORS.danger
    if (this.status === 'warning') return COLORS.warning
    return COLORS.primaryLight
  }

  getStatusBg(): string {
    if (this.status === 'danger') return '#FEF2F2'
    if (this.status === 'warning') return '#FFFBEB'
    return '#ECFDF5'
  }

  getStatusBorder(): string {
    if (this.status === 'danger') return '#FECACA'
    if (this.status === 'warning') return '#FDE68A'
    return '#A7F3D0'
  }

  getProgressValue(): number {
    if (this.status === 'normal') return 80
    if (this.status === 'warning') return 45
    return 20
  }

  getStatusLabel(): string {
    if (this.status === 'danger') return '需关注'
    if (this.status === 'warning') return '注意'
    return '良好'
  }
}
