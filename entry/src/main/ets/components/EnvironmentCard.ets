// ============================================================
// 环境状态分数卡片
// ============================================================
import { EnvironmentScore, EnvironmentLevel } from '../model/DataModels'
import { COLORS } from '../data/Constants'

@Component
export struct EnvironmentCard {
  @Prop score: number = 100
  @Prop level: string = '舒适'
  @Prop suggestion: string = ''
  @Prop anomalies: string[] = []

  build() {
    Column() {
      // 分数环形区域
      Stack() {
        // 背景圆环
        Circle()
          .width(140)
          .height(140)
          .fill(COLORS.darkOverlay)
          .stroke(COLORS.primaryLight)
          .strokeWidth(10)

        // 前景进度弧（用 Progress 模拟）
        Progress({
          value: this.score,
          total: 100,
          type: ProgressType.Ring
        })
          .width(140)
          .height(140)
          .color(this.getScoreColor())
          .style({ strokeWidth: 10 })

        Column() {
          Text(`${this.score}`)
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getScoreColor())
          Text(this.level)
            .fontSize(14)
            .fontColor(COLORS.textSecondary)
        }
      }
      .padding({ bottom: 12 })

      // 一句话建议
      Text(this.suggestion)
        .fontSize(14)
        .fontColor(COLORS.text)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .width('90%')

      // 异常项列表
      if (this.anomalies.length > 0) {
        Column() {
          ForEach(this.anomalies, (item: string) => {
            Row() {
              Text('⚠️')
                .fontSize(12)
              Text(item)
                .fontSize(12)
                .fontColor(COLORS.danger)
                .margin({ left: 4 })
            }
            .padding({ top: 4, bottom: 4, left: 12, right: 12 })
            .backgroundColor('#FFEBEE')
            .borderRadius(16)
            .margin({ top: 4 })
          })
        }
        .margin({ top: 8 })
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(COLORS.white)
    .borderRadius(16)
    .shadow({ radius: 8, color: COLORS.darkOverlay, offsetY: 2 })
  }

  getScoreColor(): string {
    if (this.score >= 85) return COLORS.success
    if (this.score >= 70) return COLORS.warning
    return COLORS.danger
  }
}
