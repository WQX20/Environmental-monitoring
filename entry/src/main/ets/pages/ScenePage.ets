// ============================================================
// 场景页：学习/睡眠/老人/儿童/离家模式
// ============================================================
import { AppState, SceneMode } from '../model/DataModels'
import { SceneCard } from '../components/SceneCard'
import { LinkagePanel } from '../components/LinkagePanel'
import { getSceneRecommendations, SceneRecommendation } from '../service/SceneAdvisor'
import { applySceneAutomation, executeAutoOptimize } from '../service/DeviceController'
import { COLORS, SCENE_DESCRIPTIONS, SCENE_ICONS } from '../data/Constants'
import { generateMockData } from '../data/MockData'
import { sharedState } from '../data/AppStateManager'

@Component
export struct ScenePage {
  @Prop uiRevision: number = 0
  @State appState: AppState = sharedState
  @State recommendations: SceneRecommendation[] = []
  @State sceneResultText: string = ''
  @State showSceneResult: boolean = false
  private timerId: number = -1

  aboutToAppear(): void {
    this.updateRecommendations()
    this.timerId = setInterval(() => {
      this.appState.currentEnv = generateMockData()
      this.updateRecommendations()
    }, 3000)
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
    }
  }

  updateRecommendations(): void {
    this.recommendations = getSceneRecommendations(this.appState.currentScene, this.appState.currentEnv)
  }

  activateScene(scene: SceneMode): void {
    this.appState.currentScene = scene
    this.updateRecommendations()
    let results = applySceneAutomation(this.appState)
    this.sceneResultText = results.join('\n')
    this.showSceneResult = true
    setTimeout(() => {
      this.showSceneResult = false
    }, 2500)
  }

  build() {
    Scroll() {
      Column() {
        // 标题
        Text('🎯 场景助手')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.text)
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 8 })

        // 当前场景状态
        Row() {
          Text('当前场景：')
            .fontSize(14)
            .fontColor(COLORS.textSecondary)
          Text(this.appState.currentScene)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.primary)
            .padding({ top: 4, bottom: 4, left: 12, right: 12 })
            .backgroundColor(COLORS.primary + '20')
            .borderRadius(12)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })

        // 场景卡片网格（2列）
        Grid() {
          GridItem() {
            SceneCard({
              icon: SCENE_ICONS['睡眠模式'],
              title: '睡眠模式',
              description: SCENE_DESCRIPTIONS['睡眠模式'],
              isActive: this.appState.currentScene === SceneMode.SLEEP,
              color: '#E3F2FD',
              onToggle: (): void => { this.activateScene(SceneMode.SLEEP) }
            })
          }

          GridItem() {
            SceneCard({
              icon: SCENE_ICONS['学习模式'],
              title: '学习模式',
              description: SCENE_DESCRIPTIONS['学习模式'],
              isActive: this.appState.currentScene === SceneMode.STUDY,
              color: '#F3E5F5',
              onToggle: (): void => { this.activateScene(SceneMode.STUDY) }
            })
          }

          GridItem() {
            SceneCard({
              icon: SCENE_ICONS['儿童模式'],
              title: '儿童模式',
              description: SCENE_DESCRIPTIONS['儿童模式'],
              isActive: this.appState.currentScene === SceneMode.CHILD,
              color: '#FFF3E0',
              onToggle: (): void => { this.activateScene(SceneMode.CHILD) }
            })
          }

          GridItem() {
            SceneCard({
              icon: SCENE_ICONS['老人模式'],
              title: '老人模式',
              description: SCENE_DESCRIPTIONS['老人模式'],
              isActive: this.appState.currentScene === SceneMode.ELDERLY,
              color: '#E8F5E9',
              onToggle: (): void => { this.activateScene(SceneMode.ELDERLY) }
            })
          }

          GridItem() {
            SceneCard({
              icon: SCENE_ICONS['离家模式'],
              title: '离家模式',
              description: SCENE_DESCRIPTIONS['离家模式'],
              isActive: this.appState.currentScene === SceneMode.AWAY,
              color: '#ECEFF1',
              onToggle: (): void => { this.activateScene(SceneMode.AWAY) }
            })
          }

          GridItem() {
            SceneCard({
              icon: SCENE_ICONS['普通模式'],
              title: '普通模式',
              description: SCENE_DESCRIPTIONS['普通模式'],
              isActive: this.appState.currentScene === SceneMode.NORMAL,
              color: '#F9FBE7',
              onToggle: (): void => { this.activateScene(SceneMode.NORMAL) }
            })
          }
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 16 })

        if (this.showSceneResult) {
          Text(this.sceneResultText)
            .fontSize(13)
            .fontColor(COLORS.white)
            .padding(14)
            .backgroundColor(COLORS.primary)
            .borderRadius(12)
            .width('90%')
            .margin({ bottom: 12 })
        }

        LinkagePanel({
          panelTitle: '联动面板',
          currentScene: this.appState.currentScene,
          lastOperationMessage: this.appState.lastOperationMessage,
          operationHistory: this.appState.operationHistory,
          onAutoOptimize: (): void => {
            executeAutoOptimize(this.appState)
          }
        })
        .margin({ bottom: 12 })

        // 当前场景建议
        Text('📋 当前场景建议')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLORS.text)
          .width('100%')
          .padding({ left: 20, top: 12, bottom: 8 })

        List() {
          ForEach(this.recommendations, (rec: SceneRecommendation) => {
            ListItem() {
              Row() {
                Text(rec.icon)
                  .fontSize(28)
                  .width(44)
                  .textAlign(TextAlign.Center)
                Column() {
                  Text(rec.title)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(COLORS.text)
                  Text(rec.detail)
                    .fontSize(12)
                    .fontColor(COLORS.textSecondary)
                    .maxLines(2)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 8 })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(COLORS.white)
              .borderRadius(12)
            }
            .margin({ bottom: 6 })
          })
        }
        .width('90%')
        .padding({ bottom: 16 })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
  }
}
