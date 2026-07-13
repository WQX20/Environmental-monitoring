// ============================================================
// 首页：环境总览 + 场景状态 + 一键联动
// ============================================================
import { AppState, EnvironmentData, EnvironmentScore, SceneMode } from '../model/DataModels'
import { EnvironmentCard } from '../components/EnvironmentCard'
import { MetricRow } from '../components/MetricRow'
import { LinkagePanel } from '../components/LinkagePanel'
import { calculateEnvironmentScore } from '../service/EnvironmentScore'
import { executeAutoOptimize, getLinkageSuggestions } from '../service/DeviceController'
import { generateMockData } from '../data/MockData'
import { sharedState } from '../data/AppStateManager'
import { COLORS, THRESHOLDS } from '../data/Constants'

@Component
export struct HomePage {
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
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
    }
  }

  refreshData(): void {
    this.envScore = calculateEnvironmentScore(this.appState.currentEnv)
    this.linkageActions = getLinkageSuggestions(this.appState)
  }

  getMetricStatus(value: number, min: number, max: number): string {
    if (value < min || value > max) return 'danger'
    let range = max - min
    let buffer = range * 0.15
    if (value < min + buffer || value > max - buffer) return 'warning'
    return 'normal'
  }

  build() {
    Scroll() {
      Column() {
        // 标题栏
        Row() {
          Text('智慧环境生活管家')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.text)
          Blank()
          Text(this.appState.currentEnv.outdoorQuality)
            .fontSize(14)
            .fontColor(COLORS.white)
            .padding({ top: 4, bottom: 4, left: 12, right: 12 })
            .backgroundColor(COLORS.success)
            .borderRadius(12)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 8 })

        // 环境分数卡片
        EnvironmentCard({
          score: this.envScore.score,
          level: this.envScore.level,
          suggestion: this.envScore.suggestion,
          anomalies: this.envScore.anomalies
        })
        .margin({ left: 16, right: 16, bottom: 12 })

        // 环境指标网格
        Text('📊 环境指标')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLORS.text)
          .width('100%')
          .padding({ left: 20, top: 8, bottom: 8 })

        MetricRow({
          label: '温度',
          value: this.appState.currentEnv.temperature,
          unit: '°C',
          icon: '🌡️',
          status: this.getMetricStatus(this.appState.currentEnv.temperature, THRESHOLDS.temperature.min, THRESHOLDS.temperature.max)
        }).margin({ left: 16, right: 16 })

        MetricRow({
          label: '湿度',
          value: this.appState.currentEnv.humidity,
          unit: '%',
          icon: '💧',
          status: this.getMetricStatus(this.appState.currentEnv.humidity, THRESHOLDS.humidity.min, THRESHOLDS.humidity.max)
        }).margin({ left: 16, right: 16 })

        MetricRow({
          label: 'PM2.5',
          value: this.appState.currentEnv.pm25,
          unit: 'μg/m³',
          icon: '🌫️',
          status: this.getMetricStatus(this.appState.currentEnv.pm25, 0, THRESHOLDS.pm25.good)
        }).margin({ left: 16, right: 16 })

        MetricRow({
          label: 'CO2',
          value: this.appState.currentEnv.co2,
          unit: 'ppm',
          icon: '🫧',
          status: this.getMetricStatus(this.appState.currentEnv.co2, 0, THRESHOLDS.co2.good)
        }).margin({ left: 16, right: 16 })

        MetricRow({
          label: '噪声',
          value: this.appState.currentEnv.noise,
          unit: 'dB',
          icon: '🔊',
          status: this.getMetricStatus(this.appState.currentEnv.noise, 0, THRESHOLDS.noise.quiet)
        }).margin({ left: 16, right: 16 })

        MetricRow({
          label: '光照',
          value: this.appState.currentEnv.light,
          unit: 'lux',
          icon: '☀️',
          status: this.appState.currentEnv.light >= THRESHOLDS.light.dim ? 'normal' : 'warning'
        }).margin({ left: 16, right: 16 })

        // 当前场景
        Row() {
          Text('🎯 当前场景：')
            .fontSize(14)
            .fontColor(COLORS.textSecondary)
          Text(this.appState.currentScene)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.primary)
        }
        .width('100%')
        .padding({ left: 20, top: 12, bottom: 4 })

        LinkagePanel({
          panelTitle: '联动面板',
          currentScene: this.appState.currentScene,
          lastOperationMessage: this.appState.lastOperationMessage,
          operationHistory: this.appState.operationHistory,
          onAutoOptimize: (): void => {
            let results = executeAutoOptimize(this.appState)
            this.optimizeResultText = results.join('\n')
            this.showOptimizeResult = true
            setTimeout(() => {
              this.showOptimizeResult = false
            }, 3000)
          }
        })
        .margin({ top: 8, bottom: 12 })

        if (this.showOptimizeResult) {
          Text(this.optimizeResultText)
            .fontSize(13)
            .fontColor(COLORS.white)
            .padding(14)
            .backgroundColor(COLORS.primary)
            .borderRadius(12)
            .width('90%')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 8 })
        }

        // 联动建议
        if (this.linkageActions.length > 0) {
          Column() {
            Text('💡 联动建议')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(COLORS.text)
              .width('100%')
              .padding({ left: 4, bottom: 6 })

            ForEach(this.linkageActions, (action: string) => {
              Row() {
                Text('·')
                  .fontSize(16)
                  .fontColor(COLORS.primary)
                Text(action)
                  .fontSize(12)
                  .fontColor(COLORS.textSecondary)
                  .margin({ left: 6 })
              }
              .width('100%')
              .padding({ top: 4, bottom: 4 })
            })
          }
          .width('90%')
          .padding(14)
          .backgroundColor(COLORS.white)
          .borderRadius(14)
          .margin({ top: 8, bottom: 16 })
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
  }
}
