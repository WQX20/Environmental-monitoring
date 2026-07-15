// ============================================================
// 首页 — 头部 + 评分卡 + 指标列表 + 联动
// ============================================================
import { AppState, EnvironmentScore } from '../model/DataModels'
import { EnvironmentCard } from '../components/EnvironmentCard'
import { MetricRow } from '../components/MetricRow'
import { LinkagePanel } from '../components/LinkagePanel'
import { calculateEnvironmentScore } from '../service/EnvironmentScore'
import { executeAutoOptimize, getLinkageSuggestions } from '../service/DeviceController'
import { generateMockData } from '../data/MockData'
import { sharedState } from '../data/AppStateManager'
import { COLORS, THRESHOLDS, FONTS, RADIUS, DURATION, ICONS } from '../data/Constants'

@Component
export struct HomePage {
  @Prop uiRevision: number = 0
  @State appState: AppState = sharedState
  @State envScore: EnvironmentScore = calculateEnvironmentScore(this.appState.currentEnv)
  @State linkageActions: string[] = []
  @State showOptimizeResult: boolean = false
  @State optimizeResultText: string = ''
  private timerId: number = -1

  aboutToAppear(): void {
    this.refreshData()
    this.timerId = setInterval(() => {
      this.appState.currentEnv = generateMockData()
      this.refreshData()
    }, 3000)
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) clearInterval(this.timerId)
  }

  refreshData(): void {
    this.envScore = calculateEnvironmentScore(this.appState.currentEnv)
    this.linkageActions = getLinkageSuggestions(this.appState)
  }

  getMetricStatus(value: number, min: number, max: number): string {
    if (value < min || value > max) return 'danger'
    let buffer = (max - min) * 0.15
    if (value < min + buffer || value > max - buffer) return 'warning'
    return 'normal'
  }

  build() {
    Scroll() {
      Column({ space: 0 }) {
        // ═══ 头部 ═══
        Row() {
          Column({ space: 4 }) {
            Text('智慧生活管家')
              .fontSize(FONTS.titleLg)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.textPrimary)
            Text('实时监测 · 智慧响应')
              .fontSize(FONTS.caption)
              .fontColor(COLORS.textTertiary)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Row({ space: 6 }) {
            Text(ICONS.secOutdoor).fontSize(16)
            Text(this.appState.currentEnv.outdoorQuality)
              .fontSize(FONTS.caption)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.textInverse)
          }
          .padding({ top: 6, bottom: 6, left: 12, right: 12 })
          .backgroundColor(this.getOutdoorBadgeColor())
          .borderRadius(RADIUS.full)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 16 })

        // ═══ 评分卡片 ═══
        EnvironmentCard({
          score: this.envScore.score,
          level: this.envScore.level,
          suggestion: this.envScore.suggestion,
          anomalies: this.envScore.anomalies
        })
        .margin({ left: 16, right: 16, bottom: 22 })

        // ═══ 环境指标 ═══
        Row({ space: 8 }) {
          Text(ICONS.secMetrics).fontSize(17)
          Text('环境指标').fontSize(FONTS.titleSm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
        }
        .width('100%')
        .padding({ left: 20, bottom: 10 })

        Column() {
          MetricRow({ label: '温度', value: this.appState.currentEnv.temperature, unit: '°C', icon: ICONS.temp,
            status: this.getMetricStatus(this.appState.currentEnv.temperature, THRESHOLDS.temperature.min, THRESHOLDS.temperature.max) })
          MetricRow({ label: '湿度', value: this.appState.currentEnv.humidity, unit: '%', icon: ICONS.humidity,
            status: this.getMetricStatus(this.appState.currentEnv.humidity, THRESHOLDS.humidity.min, THRESHOLDS.humidity.max) })
          MetricRow({ label: 'PM2.5', value: this.appState.currentEnv.pm25, unit: 'μg/m³', icon: ICONS.pm25,
            status: this.getMetricStatus(this.appState.currentEnv.pm25, 0, THRESHOLDS.pm25.good) })
          MetricRow({ label: 'CO₂', value: this.appState.currentEnv.co2, unit: 'ppm', icon: ICONS.co2,
            status: this.getMetricStatus(this.appState.currentEnv.co2, 0, THRESHOLDS.co2.good) })
          MetricRow({ label: '噪声', value: this.appState.currentEnv.noise, unit: 'dB', icon: ICONS.noise,
            status: this.getMetricStatus(this.appState.currentEnv.noise, 0, THRESHOLDS.noise.quiet) })
          MetricRow({ label: '光照', value: this.appState.currentEnv.light, unit: 'lux', icon: ICONS.light,
            status: this.appState.currentEnv.light >= THRESHOLDS.light.dim ? 'normal' : 'warning' })
        }
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 22 })

        // ═══ 联动面板 ═══
        LinkagePanel({
          panelTitle: '联动面板',
          currentScene: this.appState.currentScene,
          lastOperationMessage: this.appState.lastOperationMessage,
          operationHistory: this.appState.operationHistory,
          onAutoOptimize: (): void => {
            let results = executeAutoOptimize(this.appState)
            this.optimizeResultText = results.join('\n')
            this.showOptimizeResult = true
            setTimeout(() => { this.showOptimizeResult = false }, DURATION.result)
          }
        })
        .margin({ left: 16, right: 16, bottom: 14 })

        // ═══ 优化结果 ═══
        if (this.showOptimizeResult) {
          Row({ space: 8 }) {
            Text(ICONS.check).fontSize(16)
            Text(this.optimizeResultText)
              .fontSize(FONTS.caption).fontColor(COLORS.textInverse).layoutWeight(1)
          }
          .width('90%')
          .padding(14)
          .backgroundColor(COLORS.primary)
          .borderRadius(RADIUS.lg)
          .shadow({ radius: 12, color: 'rgba(13,148,136,0.40)', offsetY: 4 })
          .margin({ bottom: 14 })
        }

        // ═══ 联动建议 ═══
        if (this.linkageActions.length > 0) {
          Column({ space: 4 }) {
            Row({ space: 6 }) {
              Text(ICONS.secSuggestion).fontSize(16)
              Text('联动建议').fontSize(FONTS.bodySm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
            }
            .width('100%')
            .margin({ bottom: 4 })

            ForEach(this.linkageActions, (action: string) => {
              Row({ space: 8 }) {
                Circle().width(6).height(6).fill(COLORS.warning)
                Text(action).fontSize(FONTS.caption).fontColor(COLORS.textSecondary).layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 5, bottom: 5 })
            })
          }
          .width('90%')
          .padding(14)
          .backgroundColor(COLORS.surface)
          .borderRadius(RADIUS.lg)
          .shadow({ radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 })
          .margin({ bottom: 20 })
        }

        Blank().height(16)
      }
      .width('100%')
    }
    .width('100%').height('100%')
    .backgroundColor(COLORS.bgPrimary)
  }

  getOutdoorBadgeColor(): string {
    let q = this.appState.currentEnv.outdoorQuality
    if (q === '优') return COLORS.success
    if (q === '良') return COLORS.info
    if (q.includes('轻度') || q.includes('中度')) return COLORS.warning
    return COLORS.danger
  }
}
