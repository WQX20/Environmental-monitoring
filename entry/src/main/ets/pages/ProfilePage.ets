// ============================================================
// 个人中心 — 家庭信息 + 房间切换 + 主题色盘 + 设置
// ============================================================
import { AppState, Room } from '../model/DataModels'
import { StatCard } from '../components/StatCard'
import { sharedState } from '../data/AppStateManager'
import { COLORS, FONTS, RADIUS, ICONS, THEME_PRESETS } from '../data/Constants'
import { publishOperation } from '../service/DeviceController'

interface EnvStats { good: number; fair: number; bad: number }

@Component
export struct ProfilePage {
  @Prop uiRevision: number = 0
  @State appState: AppState = sharedState
  @State editingName: boolean = false
  @State editNameText: string = ''
  @State toastMsg: string = ''
  @State showToast: boolean = false

  // ── 主题色 (代理到 AppState) ──
  getTheme(): string { return this.appState.getThemePrimary() }
  getThemeSoft(): string { return this.appState.getThemeSoft() }
  getThemeBg(): string { return this.appState.getThemeBg() }

  toast(msg: string): void { this.toastMsg = msg; this.showToast = true; setTimeout(() => { this.showToast = false }, 1600) }

  // ── 统计 ──
  getEnvStats(): EnvStats {
    let pts = this.appState.trendHistory; let g = 0; let f = 0; let b = 0
    for (let p of pts) { if (p.score >= 85) g++; else if (p.score >= 70) f++; else b++ }
    let r: EnvStats = { good: g, fair: f, bad: b }; return r
  }
  getDeviceRuntime(): string {
    let mins = Math.floor((Date.now() - this.appState.sessionStartTime) / 60000)
    let on = this.appState.devices.filter(d => d.isOn && d.roomId === this.appState.currentRoomId).length
    if (on === 0) return '—'
    return `${on} 台 · ${mins < 60 ? mins + 'min' : Math.floor(mins / 60) + 'h'}`
  }
  getAiRate(): string {
    let t = this.appState.suggestions.length; if (t === 0) return '—'
    return `${Math.round(this.appState.suggestions.filter(s => s.actionType !== 'none').length / t * 100)}%`
  }

  // ── 房间切换 ──
  switchRoom(roomId: string): void {
    this.appState.currentRoomId = roomId
    let room = this.appState.rooms.find(r => r.id === roomId)
    this.toast(`已切换至「${room?.name || roomId}」`)
  }

  // ── 成员数 ──
  changeMember(delta: number): void {
    this.appState.memberCount = Math.max(1, Math.min(10, this.appState.memberCount + delta))
    this.toast(`家庭成员：${this.appState.memberCount} 人`)
  }

  // ── 设置点击 ──
  handleSetting(title: string): void {
    let m: Record<string, string> = {
      '环境偏好': '环境偏好设置 — 即将开放', '场景自定义': '场景自定义编辑 — 即将开放',
      '通知管理': '通知与免打扰 — 即将开放', '数据管理': '数据导出与缓存清理 — 即将开放',
      '关于智慧生活管家': '智慧环境生活管家 v1.0.0 · HarmonyOS',
      '隐私政策与许可': '我们仅收集环境数据用于本地分析',
    }
    this.toast(m[title] || `${title} — 功能开发中`)
  }

  private themeKeys: string[] = ['teal', 'sky', 'rose', 'violet', 'amber', 'slate']

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column({ space: 0 }) {
          // ═══ 头部 ═══
          Row() {
            Column({ space: 4 }) {
              Text('个人中心').fontSize(FONTS.titleLg).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
              Text('管理家庭、房间与偏好').fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Stack({ alignContent: Alignment.Center }) {
              Circle().width(44).height(44).fill(this.getThemeSoft())
              Text(ICONS.navHome).fontSize(22).fontColor(this.getTheme())
            }
          }
          .width('100%').padding({ left: 20, right: 20, top: 20, bottom: 18 })

          // ═══════════ 家庭信息卡 ═══════════
          Column({ space: 0 }) {
            Row({ space: 14 }) {
              Stack({ alignContent: Alignment.Center }) {
                Circle().width(64).height(64).fill(this.getTheme())
                Text(ICONS.navHome).fontSize(30).fontColor('#FFF')
              }

              Column({ space: 6 }) {
                // 可编辑家庭名
                if (this.editingName) {
                  Row({ space: 8 }) {
                    TextInput({ text: this.editNameText })
                      .fontSize(FONTS.bodyLg).fontWeight(FontWeight.Bold)
                      .backgroundColor(COLORS.bgPrimary).borderRadius(RADIUS.sm)
                      .height(36).layoutWeight(1)
                      .onChange((v: string) => { this.editNameText = v })
                    Button('保存')
                      .fontSize(FONTS.caption).height(32).backgroundColor(this.getTheme())
                      .fontColor('#FFF').borderRadius(RADIUS.sm).padding({ left: 12, right: 12 })
                      .onClick(() => {
                        if (this.editNameText.trim() !== '') {
                          this.appState.familyName = this.editNameText.trim()
                          this.toast(`家庭名已更新为「${this.appState.familyName}」`)
                        }
                        this.editingName = false
                      })
                    Button('取消')
                      .fontSize(FONTS.caption).height(32).backgroundColor(COLORS.bgPrimary)
                      .fontColor(COLORS.textSecondary).borderRadius(RADIUS.sm).padding({ left: 8, right: 8 })
                      .onClick(() => { this.editingName = false })
                  }
                  .width('100%')
                } else {
                  Row({ space: 6 }) {
                    Text(this.appState.familyName)
                      .fontSize(FONTS.bodyLg).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
                    Text('✎')
                      .fontSize(13).fontColor(this.getTheme())
                      .onClick(() => { this.editNameText = this.appState.familyName; this.editingName = true })
                  }
                }

                // 成员数
                Row({ space: 10 }) {
                  Text(`大 ${this.appState.memberCount} 位成员`)
                    .fontSize(FONTS.caption).fontColor(COLORS.textSecondary)

                  Row({ space: 0 }) {
                    Text('−').fontSize(16).fontWeight(FontWeight.Bold).fontColor(COLORS.textSecondary)
                      .width(28).height(28).textAlign(TextAlign.Center)
                      .backgroundColor(COLORS.bgPrimary).borderRadius({ topLeft: 14, bottomLeft: 14 })
                      .onClick(() => { this.changeMember(-1) })
                    Text(`${this.appState.memberCount}`)
                      .fontSize(FONTS.caption).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
                      .width(28).height(28).textAlign(TextAlign.Center)
                      .backgroundColor(COLORS.bgPrimary)
                    Text('+').fontSize(16).fontWeight(FontWeight.Bold).fontColor(this.getTheme())
                      .width(28).height(28).textAlign(TextAlign.Center)
                      .backgroundColor(COLORS.bgPrimary).borderRadius({ topRight: 14, bottomRight: 14 })
                      .onClick(() => { this.changeMember(1) })
                  }
                }
              }
              .alignItems(HorizontalAlign.Start).layoutWeight(1)
            }
            .width('100%')
          }
          .width('90%').padding(18)
          .backgroundColor(COLORS.surface).borderRadius(RADIUS.xl)
          .shadow({ radius: 8, color: 'rgba(15,23,42,0.08)', offsetY: 2 })
          .margin({ bottom: 22 })

          // ═══════════ 房间选择 ═══════════
          Row({ space: 6 }) {
            Text('◎').fontSize(16).fontColor(this.getTheme())
            Text('房间切换').fontSize(FONTS.titleSm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
            Blank()
            Text(`${this.appState.devices.filter(d => d.roomId === this.appState.currentRoomId).length} 台设备`)
              .fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
              .padding({ top: 3, bottom: 3, left: 10, right: 10 })
              .backgroundColor(COLORS.bgPrimary).borderRadius(RADIUS.full)
          }
          .width('100%').padding({ left: 20, bottom: 10 })

          Row({ space: 8 }) {
            ForEach(this.appState.rooms, (room: Room) => {
              Column({ space: 4 }) {
                Stack({ alignContent: Alignment.Center }) {
                  Circle()
                    .width(50).height(50)
                    .fill(this.appState.currentRoomId === room.id ? this.getTheme() : COLORS.bgPrimary)
                  Text(room.icon).fontSize(22).fontColor(this.appState.currentRoomId === room.id ? '#FFF' : COLORS.textSecondary)
                }
                Text(room.name)
                  .fontSize(10).fontWeight(this.appState.currentRoomId === room.id ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(this.appState.currentRoomId === room.id ? this.getTheme() : COLORS.textTertiary)
              }
              .alignItems(HorizontalAlign.Center)
              .onClick(() => { this.switchRoom(room.id) })
            })
          }
          .width('90%')
          .padding(16).backgroundColor(COLORS.surface).borderRadius(RADIUS.xl)
          .shadow({ radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 })
          .margin({ bottom: 22 })

          // ═══════════ 环境报告 ═══════════
          Row({ space: 6 }) {
            Text(ICONS.secMetrics).fontSize(16).fontColor(this.getTheme())
            Text('环境报告').fontSize(FONTS.titleSm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
            Blank()
            Text('本周').fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
              .padding({ top: 2, bottom: 2, left: 8, right: 8 }).backgroundColor(COLORS.bgPrimary).borderRadius(RADIUS.sm)
          }
          .width('100%').padding({ left: 20, bottom: 12 })

          Column({ space: 0 }) {
            Row({ space: 8 }) {
              this.statCol(`${this.getEnvStats().good}`, '优', COLORS.success, '#ECFDF5')
              this.statCol(`${this.getEnvStats().fair}`, '良', COLORS.warning, '#FFFBEB')
              this.statCol(`${this.getEnvStats().bad}`, '差', COLORS.danger, '#FEF2F2')
            }
            .width('100%').margin({ bottom: 14 })

            Row({ space: 8 }) {
              StatCard({ icon: ICONS.navDevice, label: '设备运行', value: this.getDeviceRuntime(), accent: '#3B82F6', fullWidth: false })
              StatCard({ icon: ICONS.navAi, label: 'AI 采纳', value: this.getAiRate(), accent: '#8B5CF6', fullWidth: false })
            }
            .width('100%').justifyContent(FlexAlign.SpaceBetween)
          }
          .width('90%').padding(18)
          .backgroundColor(COLORS.surface).borderRadius(RADIUS.xl)
          .shadow({ radius: 8, color: 'rgba(15,23,42,0.08)', offsetY: 2 })
          .margin({ bottom: 22 })

          // ═══════════ 主题色盘 ═══════════
          Row({ space: 6 }) {
            Text('☀').fontSize(16).fontColor(this.getTheme())
            Text('主题配色').fontSize(FONTS.titleSm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
            Blank()
            Text(THEME_PRESETS[this.appState.currentThemeKey]?.label || '')
              .fontSize(FONTS.caption).fontWeight(FontWeight.Bold).fontColor(this.getTheme())
              .padding({ top: 3, bottom: 3, left: 10, right: 10 })
              .backgroundColor(this.getThemeSoft()).borderRadius(RADIUS.full)
          }
          .width('100%').padding({ left: 20, bottom: 10 })

          Row({ space: 10 }) {
            ForEach(this.themeKeys, (key: string) => {
              Column({ space: 4 }) {
                Stack({ alignContent: Alignment.Center }) {
                  Circle()
                    .width(44).height(44)
                    .fill(THEME_PRESETS[key]?.primary || '#999')
                  if (this.appState.currentThemeKey === key) {
                    Text('✓').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FFF')
                  }
                }
                Text(THEME_PRESETS[key]?.name || '')
                  .fontSize(10)
                  .fontColor(this.appState.currentThemeKey === key ? (THEME_PRESETS[key]?.primary || '#999') : COLORS.textTertiary)
              }
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                this.appState.currentThemeKey = key
                publishOperation(this.appState, `切换主题：${THEME_PRESETS[key]?.name || key}`)
                let n = THEME_PRESETS[key]?.name || ''
                this.toast(`主题切换为「${n}」`)
              })
            })
          }
          .width('90%')
          .padding(16).backgroundColor(COLORS.surface).borderRadius(RADIUS.xl)
          .shadow({ radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 })
          .margin({ bottom: 22 })

          // ═══════════ 设置 ═══════════
          Row({ space: 6 }) {
            Text(ICONS.navDevice).fontSize(16).fontColor(this.getTheme())
            Text('设置').fontSize(FONTS.titleSm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
          }
          .width('100%').padding({ left: 20, bottom: 10 })

          Column({ space: 8 }) {
            this.settingItem(ICONS.temp, '环境偏好', '温度、湿度、空气质量阈值', COLORS.warning)
            this.settingItem(ICONS.secSuggestion, '场景自定义', '创建与编辑场景联动规则', '#8B5CF6')
            this.settingItem(ICONS.noise, '通知管理', '推送开关与免打扰时段', COLORS.danger)
            this.settingItem(ICONS.secTrend, '数据管理', '导出记录 · 清除缓存', '#64748B')
          }
          .width('90%').margin({ bottom: 18 })

          Column({ space: 8 }) {
            this.settingItem(ICONS.optimize, '关于智慧生活管家', 'v1.0.0 · HarmonyOS', this.getTheme())
            this.settingItem('☘', '隐私政策与许可', '查看数据收集与使用说明', COLORS.textTertiary)
          }
          .width('90%').margin({ bottom: 24 })

          Blank().height(16)
        }
        .width('100%')
      }
      .width('100%').height('100%')
      .backgroundColor(this.getThemeBg())

      if (this.showToast) {
        Text(this.toastMsg)
          .fontSize(FONTS.caption).fontColor('#FFF')
          .padding({ top: 12, bottom: 12, left: 20, right: 20 })
          .backgroundColor('#1E293B').borderRadius(RADIUS.lg)
          .shadow({ radius: 16, color: 'rgba(30,41,59,0.50)', offsetY: 6 })
          .margin({ bottom: 100 })
      }
    }
    .width('100%').height('100%')
  }

  @Builder statCol(val: string, label: string, color: string, bg: string): void {
    Column({ space: 4 }) {
      Text(val).fontSize(FONTS.titleLg).fontWeight(FontWeight.Bold).fontColor(color)
      Text(label).fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
    }
    .layoutWeight(1).alignItems(HorizontalAlign.Center)
    .padding(12).backgroundColor(bg).borderRadius(RADIUS.md)
  }

  @Builder settingItem(icon: string, title: string, desc: string, accent: string): void {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Circle().width(36).height(36).fill(accent + '15')
        Text(icon).fontSize(16).fontColor(accent)
      }
      Column({ space: 2 }) {
        Text(title).fontSize(FONTS.bodySm).fontWeight(FontWeight.Medium).fontColor(COLORS.textPrimary)
        Text(desc).fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text('›').fontSize(22).fontColor(COLORS.textTertiary)
    }
    .width('100%').padding(16)
    .backgroundColor(COLORS.surface).borderRadius(RADIUS.lg)
    .shadow({ radius: 4, color: 'rgba(15,23,42,0.06)', offsetY: 1 })
    .onClick(() => { this.handleSetting(title) })
  }
}
