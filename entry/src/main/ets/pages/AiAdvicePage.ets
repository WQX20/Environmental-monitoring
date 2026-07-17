// ============================================================
// AI 建议页 — 建议流 + 趋势表 + 健康提醒
// ============================================================
import { AppState, Suggestion, TrendPoint, HealthReminder } from '../model/DataModels'
import { SuggestionBubble } from '../components/SuggestionBubble'
import { generateSuggestions, mergeSuggestions } from '../service/AiAdvisor'
import { fetchChatAnswer, fetchModelSuggestions } from '../service/AiModelService'
import { calculateEnvironmentScore } from '../service/EnvironmentScore'
import { generateMockData } from '../data/MockData'
import { sharedState } from '../data/AppStateManager'
import { COLORS, FONTS, RADIUS, ICONS, TIMERS } from '../data/Constants'
import { publishOperation, subscribeStateChange } from '../service/DeviceController'

interface ChatMessage {
  id: string
  role: string
  content: string
}

@Component
export struct AiAdvicePage {
  @Prop uiRevision: number = 0
  @State appState: AppState = sharedState
  @State localRev: number = 0
  @State chatMessages: ChatMessage[] = [
    { id: 'chat-welcome', role: 'assistant', content: '你可以直接问我：当前环境要注意什么？我会结合本地环境、设备和场景来回答。' }
  ]
  @State chatInput: string = ''
  @State chatBusy: boolean = false
  private timerId: number = -1
  private trendTimerId: number = -1
  private usc: (() => void) | undefined = undefined

  aboutToAppear(): void {
    this.refreshSuggestions()
    this.recordTrend()
    this.timerId = setInterval(() => {
      this.appState.currentEnv = generateMockData()
      this.refreshSuggestions()
    }, TIMERS.suggestionCheck)
    this.trendTimerId = setInterval(() => { this.recordTrend() }, TIMERS.trendRecord)
    this.usc = subscribeStateChange(() => { this.localRev++ })
  }
  aboutToDisappear(): void {
    if (this.timerId !== -1) clearInterval(this.timerId)
    if (this.trendTimerId !== -1) clearInterval(this.trendTimerId)
    if (this.usc) { this.usc(); this.usc = undefined }
  }

  refreshSuggestions(): void {
    let localSuggestions = generateSuggestions(this.appState)
    mergeSuggestions(this.appState, localSuggestions)
    void fetchModelSuggestions(this.appState).then((modelSuggestions: Suggestion[]) => {
      mergeSuggestions(this.appState, modelSuggestions)
    })
  }

  appendChatMessage(role: string, content: string): void {
    this.chatMessages = [...this.chatMessages, {
      id: `chat-${Date.now()}-${this.chatMessages.length}`,
      role: role,
      content: content
    }]
  }

  sendChatQuestion(): void {
    let question = this.chatInput.trim()
    if (question.length === 0 || this.chatBusy) {
      return
    }

    this.appendChatMessage('user', question)
    this.chatInput = ''
    this.chatBusy = true

    void fetchChatAnswer(this.appState, question).then((answer: string) => {
      this.appendChatMessage('assistant', answer.length > 0 ? answer : '我暂时没有拿到有效回复，请稍后再试。')
    }).catch(() => {
      this.appendChatMessage('assistant', '请求失败了，请确认 backend 已启动，并把 Constants.ets 里的 endpoint 改成电脑局域网 IP。')
    }).finally(() => {
      this.chatBusy = false
    })
  }

  getChatBubbleColor(role: string): string {
    if (role === 'user') return COLORS.primary
    return COLORS.surface
  }

  getChatTextColor(role: string): string {
    if (role === 'user') return COLORS.textInverse
    return COLORS.textPrimary
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

        // ═══ AI 对话 ═══
        Column({ space: 10 }) {
          Row({ space: 6 }) {
            Text('✦').fontSize(18)
            Text('AI 对话').fontSize(FONTS.titleSm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
          }
          .width('100%')

          Text('你可以问“当前环境要注意什么”“现在适合开窗吗”“今天有什么风险”之类的问题。')
            .fontSize(FONTS.caption)
            .fontColor(COLORS.textTertiary)

          Column({ space: 10 }) {
            ForEach(this.chatMessages, (message: ChatMessage) => {
              Row() {
                if (message.role === 'user') {
                  Blank().layoutWeight(1)
                  Column() {
                    Text(message.content)
                      .fontSize(FONTS.bodySm)
                      .fontColor(this.getChatTextColor(message.role))
                      .textAlign(TextAlign.Start)
                  }
                  .width('80%')
                  .padding({ left: 12, right: 12, top: 10, bottom: 10 })
                  .backgroundColor(this.getChatBubbleColor(message.role))
                  .borderRadius({ topLeft: RADIUS.lg, topRight: RADIUS.lg, bottomLeft: RADIUS.lg, bottomRight: 4 })
                } else {
                  Column() {
                    Text(message.content)
                      .fontSize(FONTS.bodySm)
                      .fontColor(this.getChatTextColor(message.role))
                      .textAlign(TextAlign.Start)
                  }
                  .width('80%')
                  .padding({ left: 12, right: 12, top: 10, bottom: 10 })
                  .backgroundColor(this.getChatBubbleColor(message.role))
                  .borderRadius({ topLeft: RADIUS.lg, topRight: RADIUS.lg, bottomRight: RADIUS.lg, bottomLeft: 4 })
                  Blank().layoutWeight(1)
                }
              }
              .width('100%')
            })
          }
          .width('100%')

          Row({ space: 8 }) {
            TextInput({ placeholder: this.chatBusy ? 'AI 正在思考...' : '请输入你的问题', text: this.chatInput })
              .fontSize(FONTS.bodySm)
              .height(44)
              .layoutWeight(1)
              .backgroundColor('transparent')
              .onChange((v: string) => { this.chatInput = v })
            Button(this.chatBusy ? '发送中' : '发送')
              .fontSize(FONTS.bodySm)
              .fontColor(COLORS.textInverse)
              .height(44)
              .padding({ left: 16, right: 16 })
              .backgroundColor(COLORS.primary)
              .borderRadius(RADIUS.lg)
              .onClick(() => { this.sendChatQuestion() })
          }
          .width('100%')

          Row({ space: 8 }) {
            Text('示例：当前环境要注意什么？')
              .fontSize(FONTS.caption)
              .fontColor(COLORS.textTertiary)
              .onClick(() => { this.chatInput = '当前环境要注意什么？' })
            Text('现在适合开窗吗？')
              .fontSize(FONTS.caption)
              .fontColor(COLORS.textTertiary)
              .onClick(() => { this.chatInput = '现在适合开窗吗？' })
          }
          .width('100%')
        }
        .width('90%')
        .padding(14)
        .backgroundColor(COLORS.surface)
        .borderRadius(RADIUS.lg)
        .shadow({ radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 })
        .margin({ bottom: 18 })

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
