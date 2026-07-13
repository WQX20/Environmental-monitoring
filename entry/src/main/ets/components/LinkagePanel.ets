// ============================================================
// 联动面板：场景状态 + 最近操作 + 操作历史
// ============================================================
import { COLORS } from '../data/Constants'

@Component
export struct LinkagePanel {
  @Prop panelTitle: string = '联动面板'
  @Prop currentScene: string = ''
  @Prop lastOperationMessage: string = ''
  @Prop operationHistory: string[] = []
  onAutoOptimize?: () => void
  onAllOff?: () => void

  build() {
    Column() {
      Text(this.panelTitle)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLORS.text)
        .width('100%')
        .padding({ bottom: 8 })

      Row() {
        Text('当前场景')
          .fontSize(12)
          .fontColor(COLORS.textSecondary)
        Text(this.currentScene === '' ? '未选择' : this.currentScene)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.primary)
      }
      .width('100%')
      .padding({ bottom: 8 })

      if (this.lastOperationMessage !== '') {
        Text('最近结果')
          .fontSize(12)
          .fontColor(COLORS.textSecondary)
          .width('100%')
        Text(this.lastOperationMessage)
          .fontSize(12)
          .fontColor(COLORS.text)
          .width('100%')
          .padding({ bottom: 8 })
      }

      if (this.operationHistory.length > 0) {
        Text('操作历史')
          .fontSize(12)
          .fontColor(COLORS.textSecondary)
          .width('100%')
          .padding({ bottom: 4 })

        ForEach(this.operationHistory.slice(0, 5), (item: string) => {
          Text(item)
            .fontSize(11)
            .fontColor(COLORS.textSecondary)
            .width('100%')
            .padding({ top: 2, bottom: 2 })
        })
      }

      if (this.onAutoOptimize || this.onAllOff) {
        Row() {
          if (this.onAutoOptimize) {
            Button('一键优化')
              .fontSize(12)
              .height(32)
              .backgroundColor(COLORS.primary)
              .fontColor(COLORS.white)
              .borderRadius(16)
              .layoutWeight(1)
              .onClick(() => {
                if (this.onAutoOptimize) {
                  this.onAutoOptimize()
                }
              })
          }

          if (this.onAllOff) {
            Button('一键全关')
              .fontSize(12)
              .height(32)
              .backgroundColor(COLORS.danger)
              .fontColor(COLORS.white)
              .borderRadius(16)
              .layoutWeight(1)
              .margin({ left: this.onAutoOptimize ? 8 : 0 })
              .onClick(() => {
                if (this.onAllOff) {
                  this.onAllOff()
                }
              })
          }
        }
        .width('100%')
        .margin({ top: 10 })
      }
    }
    .width('90%')
    .padding(14)
    .backgroundColor(COLORS.white)
    .borderRadius(14)
    .border({ width: 1, color: COLORS.divider })
  }
}