// ============================================================
// 联动面板 — 场景状态 + 操作历史 + 双操作按钮
// ============================================================
import { COLORS, RADIUS, FONTS, ICONS } from '../data/Constants'

@Component
export struct LinkagePanel {
  @Prop panelTitle: string = '联动面板'
  @Prop currentScene: string = ''
  @Prop lastOperationMessage: string = ''
  @Prop operationHistory: string[] = []
  @Prop refreshSeed: number = 0
  onAutoOptimize?: () => void
  onAllOff?: () => void

  build() {
    Column({ space: 0 }) {
      // ═══ 标题 ═══
      Row({ space: 8 }) {
        Text(ICONS.secLink).fontSize(16)
        Text(this.panelTitle)
          .fontSize(FONTS.bodySm)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.textPrimary)
      }
      .width('100%')
      .margin({ bottom: 14 })

      // ═══ 当前场景 ═══
      Row({ space: 8 }) {
        Text('当前').fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
        Text(this.currentScene === '' ? '—' : this.currentScene)
          .fontSize(FONTS.caption)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.primary)
          .padding({ top: 4, bottom: 4, left: 12, right: 12 })
          .backgroundColor(COLORS.primarySoft)
          .borderRadius(RADIUS.full)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // ═══ 最近结果 ═══
      if (this.lastOperationMessage !== '') {
        Column({ space: 6 }) {
          Text('最近结果').fontSize(10).fontColor(COLORS.textTertiary)
          Text(this.lastOperationMessage)
            .fontSize(FONTS.caption)
            .fontColor(COLORS.textSecondary)
            .padding(10)
            .backgroundColor(COLORS.bgPrimary)
            .borderRadius(RADIUS.sm)
            .width('100%')
        }
        .width('100%')
        .margin({ bottom: 14 })
      }

      // ═══ 操作历史 ═══
      if (this.operationHistory.length > 0) {
        Column({ space: 6 }) {
          Text('操作历史').fontSize(10).fontColor(COLORS.textTertiary)
          Column({ space: 2 }) {
            ForEach(this.operationHistory.slice(0, 5), (item: string) => {
              Row({ space: 8 }) {
                Circle().width(5).height(5).fill(COLORS.primaryLight)
                Text(item)
                  .fontSize(10)
                  .fontColor(COLORS.textSecondary)
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .padding({ top: 4, bottom: 4 })
            })
          }
        }
        .width('100%')
        .margin({ bottom: 14 })
      }

      // ═══ 按钮组 ═══
      if (this.onAutoOptimize || this.onAllOff) {
        Row({ space: 12 }) {
          if (this.onAutoOptimize) {
            Button() {
              Row({ space: 6 }) {
                Text(ICONS.optimize).fontSize(15)
                Text('一键优化').fontSize(FONTS.caption).fontWeight(FontWeight.Bold)
              }
            }
            .height(42)
            .layoutWeight(1)
            .backgroundColor(COLORS.primary)
            .fontColor(COLORS.textInverse)
            .borderRadius(RADIUS.lg)
            .shadow({ radius: 8, color: 'rgba(13,148,136,0.30)', offsetY: 2 })
            .onClick(() => { if (this.onAutoOptimize) this.onAutoOptimize() })
          }
          if (this.onAllOff) {
            Button() {
              Row({ space: 6 }) {
                Text(ICONS.powerOff).fontSize(16)
                Text('一键全关').fontSize(FONTS.caption).fontWeight(FontWeight.Bold)
              }
            }
            .height(42)
            .layoutWeight(1)
            .backgroundColor(COLORS.surface)
            .fontColor(COLORS.danger)
            .borderRadius(RADIUS.lg)
            .border({ width: 1.5, color: '#FECACA' })
            .onClick(() => { if (this.onAllOff) this.onAllOff() })
          }
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(COLORS.surface)
    .borderRadius(RADIUS.xl)
    .shadow({ radius: 8, color: 'rgba(15,23,42,0.08)', offsetY: 2 })
  }
}
