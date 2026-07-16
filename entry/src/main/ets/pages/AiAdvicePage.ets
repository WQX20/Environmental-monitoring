// ============================================================
// AI 建议页 — 建议流 + 趋势表 + 健康提醒
// ============================================================
import { AppState, Suggestion, TrendPoint, HealthReminder } from '../model/DataModels'
import { SuggestionBubble } from '../components/SuggestionBubble'
import { generateSuggestions, mergeSuggestions } from '../service/AiAdvisor'
import { calculateEnvironmentScore } from '../service/EnvironmentScore'
import { generateMockData } from '../data/MockData'
import { sharedState } from '../data/AppStateManager'
import { COLORS, FONTS, RADIUS, ICONS } from '../data/Constants'
import { publishOperation, subscribeStateChange } from '../service/DeviceController'

@Component
export struct AiAdvicePage {
  @Prop uiRevision: number = 0
  @State appState: AppState = sharedState
  @State localRev: number = 0
  private timerId: number = -1
  private trendTimerId: number = -1
  private usc: (() => void) | undefined = undefined

  aboutToAppear(): void {
    let initial = generateSuggestions(this.appState)
    mergeSuggestions(this.appState, initial)
    this.recordTrend()
    this.timerId = setInterval(() => {
      this.appState.currentEnv = generateMockData()
      let sugs = generateSuggestions(this.appState)
      mergeSuggestions(this.appState, sugs)
    }, 10000)
    this.trendTimerId = setInterval(() => { this.recordTrend() }, 60000)
    this.usc = subscribeStateChange(() => { this.localRev++ })
  }
  aboutToDisappear(): void {
    if (this.timerId !== -1) clearInterval(this.timerId)
    if (this.trendTimerId !== -1) clearInterval(this.trendTimerId)
    if (this.usc) { this.usc(); this.usc = undefined }
  }

  recordTrend(): void {
    let env = this.appState.currentEnv
    let score = calculateEnvironmentScore(env)
    let now = new Date()
    let timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`
    this.appState.trendHistory.push({
      time: timeStr, temperature: env.temperature, humidity: env.humidity,
      pm25: env.pm25, co2: env.co2, score: score.score
    })
    if (this.appState.trendHistory.length > 24) {
      this.appState.trendHistory = this.appState.trendHistory.slice(-24)
    }
  }

  handleAction(suggestion: Suggestion): void {
    if (suggestion.actionType === 'openWindow') {
      this.appState.currentEnv.co2 = 400
      publishOperation(this.appState, `AI建议：${suggestion.title}`)
    }
  }

  build() {
    Scroll() {
      Column({ space: 0 }) {
        // ═══ 头部 ═══
        Row() {
          Column({ space: 4 }) {
            Text('AI 环境建议').fontSize(FONTS.titleLg).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
            Text('智能分析 · 贴心提醒').fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Text(`${ICONS.navAi} ${this.appState.suggestions.length} 条`)
            .fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 16 })

        // ═══ 建议列表 ═══
        Row({ space: 6 }) {
          Text(ICONS.secSuggestion).fontSize(17)
          Text('最新建议').fontSize(FONTS.titleSm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
        }
        .width('100%')
        .padding({ left: 20, bottom: 10 })

        if (this.appState.suggestions.length === 0) {
          Column({ space: 10 }) {
            Text(ICONS.optimize).fontSize(48)
            Text('暂无建议，环境状况良好').fontSize(FONTS.bodySm).fontColor(COLORS.textTertiary)
            Text('AI 将持续监测环境变化').fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
          }
          .width('80%')
          .padding({ top: 30, bottom: 30 })
          .backgroundColor(COLORS.surface)
          .borderRadius(RADIUS.xl)
          .margin({ bottom: 20 })
        }

        List() {
          ForEach(this.appState.suggestions.slice(0, 10), (sug: Suggestion) => {
            ListItem() {
              SuggestionBubble({
                sugId: sug.id, sugTimestamp: sug.timestamp, sugCategory: sug.category,
                sugTitle: sug.title, sugDetail: sug.detail,
                sugActionLabel: sug.actionLabel, sugActionType: sug.actionType, sugIcon: sug.icon,
                onSuggestionAction: (): void => { this.handleAction(sug) }
              })
            }
          })
        }
        .width('92%')
        .margin({ bottom: 22 })

        // ═══ 历史趋势 ═══
        Row({ space: 6 }) {
          Text(ICONS.secTrend).fontSize(18)
          Text('近24小时趋势').fontSize(FONTS.titleSm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
        }
        .width('100%')
        .padding({ left: 20, bottom: 10 })

        if (this.appState.trendHistory.length > 0) {
          Column() {
            // 表头
            Row() {
              Text('时间').fontSize(10).fontColor(COLORS.textTertiary).width(48).textAlign(TextAlign.Center)
              Text('评分').fontSize(10).fontColor(COLORS.textTertiary).layoutWeight(1).textAlign(TextAlign.Center)
              Text('温度').fontSize(10).fontColor(COLORS.textTertiary).layoutWeight(1).textAlign(TextAlign.Center)
              Text('湿度').fontSize(10).fontColor(COLORS.textTertiary).layoutWeight(1).textAlign(TextAlign.Center)
              Text('PM2.5').fontSize(10).fontColor(COLORS.textTertiary).layoutWeight(1).textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding({ top: 12, bottom: 10 })
            .backgroundColor(COLORS.bgPrimary)
            .borderRadius({ topLeft: RADIUS.lg, topRight: RADIUS.lg })

            // 数据行
            ForEach(this.appState.trendHistory.slice(-12), (point: TrendPoint) => {
              Row() {
                Text(point.time).fontSize(10).fontColor(COLORS.textTertiary).width(48).textAlign(TextAlign.Center)
                Text(`${point.score}`).fontSize(11).fontWeight(FontWeight.Bold)
                  .fontColor(point.score >= 85 ? COLORS.success : point.score >= 70 ? COLORS.warning : COLORS.danger)
                  .layoutWeight(1).textAlign(TextAlign.Center)
                Text(`${point.temperature}°`).fontSize(10).fontColor(COLORS.textSecondary).layoutWeight(1).textAlign(TextAlign.Center)
                Text(`${point.humidity}%`).fontSize(10).fontColor(COLORS.textSecondary).layoutWeight(1).textAlign(TextAlign.Center)
                Text(`${point.pm25}`).fontSize(10).fontColor(COLORS.textSecondary).layoutWeight(1).textAlign(TextAlign.Center)
              }
              .width('100%')
              .padding({ top: 7, bottom: 7 })
              .border({ width: { bottom: 0.5 }, color: COLORS.borderLight })
            })
          }
          .width('90%')
          .backgroundColor(COLORS.surface)
          .borderRadius(RADIUS.lg)
          .shadow({ radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 })
          .margin({ bottom: 22 })
        }

        // ═══ 健康提醒 ═══
        Row({ space: 6 }) {
          Text(ICONS.secHealth).fontSize(18)
          Text('健康提醒').fontSize(FONTS.titleSm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
        }
        .width('100%')
        .padding({ left: 20, bottom: 10 })

        Column({ space: 8 }) {
          ForEach(this.appState.healthReminders, (reminder: HealthReminder) => {
            Row({ space: 12 }) {
              Stack({ alignContent: Alignment.Center }) {
                Circle().width(44).height(44).fill(this.getReminderBg(reminder.type))
                Text(this.getReminderIcon(reminder.type)).fontSize(22)
              }
              .width(44).height(44)

              Column({ space: 3 }) {
                Text(reminder.message).fontSize(FONTS.bodySm).fontColor(COLORS.textPrimary)
                if (reminder.interval > 0) {
                  Text(`每 ${reminder.interval} 分钟提醒一次`).fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(14)
            .backgroundColor(COLORS.surface)
            .borderRadius(RADIUS.lg)
            .shadow({ radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 })
          })
        }
        .width('90%')
        .margin({ bottom: 24 })

        Blank().height(8)
      }
      .width('100%')
    }
    .width('100%').height('100%')
    .backgroundColor(sharedState.getThemeBg())
  }

  getReminderIcon(type: string): string {
    if (type === 'drink') return ICONS.remDrink
    if (type === 'rest') return ICONS.remRest
    if (type === 'sleep') return ICONS.remSleep
    if (type === 'exercise') return ICONS.remExercise
    return ICONS.secHealth
  }

  getReminderBg(type: string): string {
    if (type === 'drink') return '#EFF6FF'
    if (type === 'rest') return '#FEF2F2'
    if (type === 'sleep') return '#F5F3FF'
    if (type === 'exercise') return '#ECFDF5'
    return COLORS.primarySoft
  }
}
