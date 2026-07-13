// ============================================================
// AI 建议页：环境解读 + 健康提示 + 历史趋势
// ============================================================
import { AppState, Suggestion, TrendPoint, HealthReminder } from '../model/DataModels'
import { SuggestionBubble } from '../components/SuggestionBubble'
import { generateSuggestions, mergeSuggestions } from '../service/AiAdvisor'
import { calculateEnvironmentScore } from '../service/EnvironmentScore'
import { generateMockData } from '../data/MockData'
import { sharedState } from '../data/AppStateManager'
import { COLORS } from '../data/Constants'
import { publishOperation } from '../service/DeviceController'

@Component
export struct AiAdvicePage {
  @State appState: AppState = sharedState
  private timerId: number = -1
  private trendTimerId: number = -1

  aboutToAppear(): void {
    // 生成初始建议
    let initialSugs = generateSuggestions(this.appState)
    mergeSuggestions(this.appState, initialSugs)

    // 记录初始趋势点
    this.recordTrend()

    // 定时刷新 + 生成建议
    this.timerId = setInterval(() => {
      this.appState.currentEnv = generateMockData()
      let sugs = generateSuggestions(this.appState)
      mergeSuggestions(this.appState, sugs)
    }, 10000)

    // 每分钟记录趋势
    this.trendTimerId = setInterval(() => {
      this.recordTrend()
    }, 60000)
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) clearInterval(this.timerId)
    if (this.trendTimerId !== -1) clearInterval(this.trendTimerId)
  }

  recordTrend(): void {
    let env = this.appState.currentEnv
    let score = calculateEnvironmentScore(env)
    let now = new Date()
    let timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`
    let point: TrendPoint = {
      time: timeStr,
      temperature: env.temperature,
      humidity: env.humidity,
      pm25: env.pm25,
      co2: env.co2,
      score: score.score
    }
    this.appState.trendHistory.push(point)
    if (this.appState.trendHistory.length > 24) {
      this.appState.trendHistory = this.appState.trendHistory.slice(-24)
    }
  }

  handleAction(suggestion: Suggestion): void {
    // 处理可执行建议
    if (suggestion.actionType === 'openWindow') {
      // 模拟开窗效果
      this.appState.currentEnv.co2 = 400
      if (this.appState.currentEnv.co2 < 400) {
        this.appState.currentEnv.co2 = 400
      }
      let message = `AI建议：已执行${suggestion.title}`
      publishOperation(this.appState, message)
    }
  }

  build() {
    Scroll() {
      Column() {
        // 标题
        Text('🤖 AI 环境建议')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.text)
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 4 })

        Text('智能分析环境数据，为你提供个性化建议')
          .fontSize(13)
          .fontColor(COLORS.textSecondary)
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 12 })

        // 建议列表
        Text('💡 最新建议')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLORS.text)
          .width('100%')
          .padding({ left: 20, top: 8, bottom: 8 })

        if (this.appState.suggestions.length === 0) {
          Text('暂无建议，环境状况良好 ✨')
            .fontSize(14)
            .fontColor(COLORS.textHint)
            .padding(20)
            .width('100%')
            .textAlign(TextAlign.Center)
        }

        List() {
          ForEach(this.appState.suggestions.slice(0, 10), (sug: Suggestion) => {
            ListItem() {
              SuggestionBubble({
                sugId: sug.id,
                sugTimestamp: sug.timestamp,
                sugCategory: sug.category,
                sugTitle: sug.title,
                sugDetail: sug.detail,
                sugActionLabel: sug.actionLabel,
                sugActionType: sug.actionType,
                sugIcon: sug.icon,
                onSuggestionAction: (): void => { this.handleAction(sug) }
              })
            }
            .margin({ bottom: 4 })
          })
        }
        .width('90%')

        // 历史趋势
        Text('📈 近24小时趋势')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLORS.text)
          .width('100%')
          .padding({ left: 20, top: 20, bottom: 8 })

        if (this.appState.trendHistory.length > 0) {
          Column() {
            Row() {
              Text('时间')
                .fontSize(11)
                .fontColor(COLORS.textHint)
                .width(50)
                .textAlign(TextAlign.Center)
              Text('评分')
                .fontSize(11)
                .fontColor(COLORS.textHint)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
              Text('温度')
                .fontSize(11)
                .fontColor(COLORS.textHint)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
              Text('PM2.5')
                .fontSize(11)
                .fontColor(COLORS.textHint)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })

            ForEach(this.appState.trendHistory, (point: TrendPoint) => {
              Row() {
                Text(point.time)
                  .fontSize(11)
                  .fontColor(COLORS.textSecondary)
                  .width(50)
                  .textAlign(TextAlign.Center)
                Text(`${point.score}`)
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(point.score >= 85 ? COLORS.success : point.score >= 70 ? COLORS.warning : COLORS.danger)
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                Text(`${point.temperature}°C`)
                  .fontSize(11)
                  .fontColor(COLORS.textSecondary)
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                Text(`${point.pm25}`)
                  .fontSize(11)
                  .fontColor(COLORS.textSecondary)
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .padding({ top: 6, bottom: 6 })
              .border({ width: { bottom: 0.5 }, color: COLORS.divider })
            })
          }
          .width('90%')
          .backgroundColor(COLORS.white)
          .borderRadius(12)
          .padding(12)
          .margin({ bottom: 8 })
        }

        if (this.appState.operationHistory.length > 0) {
          Column() {
            Text('🕒 最近操作')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(COLORS.text)
              .width('100%')
              .padding({ bottom: 8 })

            ForEach(this.appState.operationHistory, (item: string) => {
              Text(item)
                .fontSize(12)
                .fontColor(COLORS.textSecondary)
                .width('100%')
                .padding({ top: 4, bottom: 4 })
            })
          }
          .width('90%')
          .padding(14)
          .backgroundColor(COLORS.white)
          .borderRadius(12)
          .margin({ bottom: 8 })
        }

        // 健康提醒
        Text('❤️ 健康提醒')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLORS.text)
          .width('100%')
          .padding({ left: 20, top: 16, bottom: 8 })

        ForEach(this.appState.healthReminders, (reminder: HealthReminder) => {
          Row() {
            Text(this.getReminderIcon(reminder.type))
              .fontSize(24)
              .width(40)
              .textAlign(TextAlign.Center)
            Column() {
              Text(reminder.message)
                .fontSize(13)
                .fontColor(COLORS.text)
              if (reminder.interval > 0) {
                Text(`每${reminder.interval}分钟提醒`)
                  .fontSize(11)
                  .fontColor(COLORS.textHint)
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('90%')
          .padding(12)
          .backgroundColor(COLORS.white)
          .borderRadius(12)
          .margin({ bottom: 6 })
        })

        // 底部间距
        Blank()
          .height(24)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
  }

  getReminderIcon(type: string): string {
    if (type === 'drink') return '🥤'
    if (type === 'rest') return '☕'
    if (type === 'sleep') return '😴'
    if (type === 'exercise') return '🏃'
    return '❤️'
  }
}
