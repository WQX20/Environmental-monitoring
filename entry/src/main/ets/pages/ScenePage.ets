// ============================================================
// 场景页 — 2列网格 + 场景建议列表
// ============================================================
import { AppState, SceneMode } from '../model/DataModels'
import { SceneCard } from '../components/SceneCard'
import { LinkagePanel } from '../components/LinkagePanel'
import { getSceneRecommendations, SceneRecommendation } from '../service/SceneAdvisor'
import { applySceneAutomation, executeAutoOptimize } from '../service/DeviceController'
import { COLORS, SCENE_DESCRIPTIONS, SCENE_ICONS, FONTS, RADIUS, DURATION, ICONS } from '../data/Constants'
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
    if (this.timerId !== -1) clearInterval(this.timerId)
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
    setTimeout(() => { this.showSceneResult = false }, 2500)
  }

  build() {
    Scroll() {
      Column({ space: 0 }) {
        // ═══ 头部 ═══
        Row() {
          Column({ space: 4 }) {
            Text('场景助手').fontSize(FONTS.titleLg).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
            Text('一键切换 · 智能联动').fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Row({ space: 4 }) {
            Text(SCENE_ICONS[this.appState.currentScene] || '🏠').fontSize(14)
            Text(this.appState.currentScene).fontSize(FONTS.caption).fontWeight(FontWeight.Bold).fontColor(COLORS.primary)
          }
          .padding({ top: 6, bottom: 6, left: 12, right: 12 })
          .backgroundColor(COLORS.primarySoft)
          .borderRadius(RADIUS.full)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 16 })

        // ═══ 场景网格 ═══
        Text('选择场景模式')
          .fontSize(FONTS.bodySm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
          .width('100%')
          .padding({ left: 20, bottom: 10 })

        Grid() {
          GridItem() { SceneCard({ icon: SCENE_ICONS['睡眠模式'], title: '睡眠模式', description: SCENE_DESCRIPTIONS['睡眠模式'], isActive: this.appState.currentScene === SceneMode.SLEEP, onToggle: (): void => { this.activateScene(SceneMode.SLEEP) } }) }
          GridItem() { SceneCard({ icon: SCENE_ICONS['学习模式'], title: '学习模式', description: SCENE_DESCRIPTIONS['学习模式'], isActive: this.appState.currentScene === SceneMode.STUDY, onToggle: (): void => { this.activateScene(SceneMode.STUDY) } }) }
          GridItem() { SceneCard({ icon: SCENE_ICONS['儿童模式'], title: '儿童模式', description: SCENE_DESCRIPTIONS['儿童模式'], isActive: this.appState.currentScene === SceneMode.CHILD, onToggle: (): void => { this.activateScene(SceneMode.CHILD) } }) }
          GridItem() { SceneCard({ icon: SCENE_ICONS['老人模式'], title: '老人模式', description: SCENE_DESCRIPTIONS['老人模式'], isActive: this.appState.currentScene === SceneMode.ELDERLY, onToggle: (): void => { this.activateScene(SceneMode.ELDERLY) } }) }
          GridItem() { SceneCard({ icon: SCENE_ICONS['离家模式'], title: '离家模式', description: SCENE_DESCRIPTIONS['离家模式'], isActive: this.appState.currentScene === SceneMode.AWAY, onToggle: (): void => { this.activateScene(SceneMode.AWAY) } }) }
          GridItem() { SceneCard({ icon: SCENE_ICONS['普通模式'], title: '普通模式', description: SCENE_DESCRIPTIONS['普通模式'], isActive: this.appState.currentScene === SceneMode.NORMAL, onToggle: (): void => { this.activateScene(SceneMode.NORMAL) } }) }
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(10).rowsGap(10)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 18 })

        // ═══ 场景切换结果 ═══
        if (this.showSceneResult) {
          Row({ space: 8 }) {
            Text(ICONS.refresh).fontSize(16)
            Text(this.sceneResultText).fontSize(FONTS.caption).fontColor(COLORS.textInverse).layoutWeight(1)
          }
          .width('90%')
          .padding(14)
          .backgroundColor(COLORS.primary)
          .borderRadius(RADIUS.lg)
          .shadow({ radius: 12, color: 'rgba(13,148,136,0.40)', offsetY: 4 })
          .margin({ bottom: 14 })
        }

        // ═══ 联动面板 ═══
        LinkagePanel({
          panelTitle: '联动面板',
          currentScene: this.appState.currentScene,
          lastOperationMessage: this.appState.lastOperationMessage,
          operationHistory: this.appState.operationHistory,
          onAutoOptimize: (): void => { executeAutoOptimize(this.appState) }
        })
        .margin({ left: 16, right: 16, bottom: 18 })

        // ═══ 场景建议 ═══
        Row({ space: 6 }) {
          Text(ICONS.secRecommend).fontSize(18)
          Text('当前场景建议').fontSize(FONTS.titleSm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
        }
        .width('100%')
        .padding({ left: 20, bottom: 10 })

        List() {
          ForEach(this.recommendations, (rec: SceneRecommendation) => {
            ListItem() {
              Row({ space: 12 }) {
                Stack({ alignContent: Alignment.Center }) {
                  Circle().width(42).height(42).fill(COLORS.primarySoft)
                  Text(rec.icon).fontSize(20)
                }
                .width(42).height(42)

                Column({ space: 3 }) {
                  Text(rec.title).fontSize(FONTS.bodySm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
                  Text(rec.detail).fontSize(FONTS.caption).fontColor(COLORS.textSecondary).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text(`P${rec.priority}`)
                  .fontSize(9).fontWeight(FontWeight.Bold)
                  .fontColor(rec.priority === 1 ? COLORS.danger : rec.priority === 2 ? COLORS.warning : COLORS.textTertiary)
                  .padding({ top: 2, bottom: 2, left: 6, right: 6 })
                  .backgroundColor(rec.priority === 1 ? '#FEF2F2' : rec.priority === 2 ? '#FFFBEB' : COLORS.bgPrimary)
                  .borderRadius(RADIUS.sm)
              }
              .width('100%')
              .padding(14)
              .backgroundColor(COLORS.surface)
              .borderRadius(RADIUS.lg)
              .shadow({ radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 })
            }
            .margin({ bottom: 8 })
          })
        }
        .width('90%')
        .margin({ bottom: 20 })

        Blank().height(8)
      }
      .width('100%')
    }
    .width('100%').height('100%')
    .backgroundColor(COLORS.bgPrimary)
  }
}
