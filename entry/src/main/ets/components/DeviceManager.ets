// ============================================================
// 设备管理面板 — 添加设备到当前房间 / 删除设备
// ============================================================
import { AppState, Device, DeviceType, Room } from '../model/DataModels'
import { DEVICE_ICONS, COLORS, RADIUS, FONTS, ICONS } from '../data/Constants'
import { sharedState } from '../data/AppStateManager'
import { publishOperation } from '../service/DeviceController'

// 可添加的设备模板
interface DeviceTemplate {
  type: DeviceType
  name: string
  iconKey: string
  defaultTarget: number
  unit: string
  accent: string
}

const TEMPLATES: DeviceTemplate[] = [
  { type: DeviceType.AC, name: '空调', iconKey: 'ac', defaultTarget: 26, unit: '°C', accent: '#3B82F6' },
  { type: DeviceType.PURIFIER, name: '净化器', iconKey: 'purifier', defaultTarget: 0, unit: 'μg/m³', accent: '#8B5CF6' },
  { type: DeviceType.HUMIDIFIER, name: '加湿器', iconKey: 'humidifier', defaultTarget: 50, unit: '%', accent: '#06B6D4' },
  { type: DeviceType.LIGHT, name: '台灯', iconKey: 'light', defaultTarget: 100, unit: '%', accent: '#F59E0B' },
  { type: DeviceType.CURTAIN, name: '窗帘', iconKey: 'curtain', defaultTarget: 100, unit: '%', accent: '#64748B' },
]

@Component
export struct DeviceManager {
  @Prop roomId: string = ''
  @State appState: AppState = sharedState
  @State showAddPanel: boolean = false
  onDeviceChanged?: () => void

  getRoomDevices(): Device[] {
    return this.appState.devices.filter(d => d.roomId === this.roomId)
  }

  getRoomName(): string {
    let room = this.appState.rooms.find(r => r.id === this.roomId)
    return room ? room.name : this.roomId
  }

  addDevice(template: DeviceTemplate): void {
    let idx = this.appState.devices.filter(d => d.type === template.type && d.roomId === this.roomId).length
    let id = `${template.iconKey}_${this.roomId}_${Date.now()}`
    let newDevice: Device = {
      id: id,
      name: `${this.getRoomName()}${template.name}${idx > 0 ? (idx + 1) : ''}`,
      icon: DEVICE_ICONS[template.iconKey] || '◉',
      isOn: false,
      targetValue: template.defaultTarget,
      currentValue: template.defaultTarget,
      unit: template.unit,
      type: template.type,
      roomId: this.roomId
    }
    this.appState.devices.push(newDevice)
    publishOperation(this.appState, `添加设备：${newDevice.name}`)
    if (this.onDeviceChanged) this.onDeviceChanged()
  }

  removeDevice(deviceId: string): void {
    let dev = this.appState.devices.find(d => d.id === deviceId)
    this.appState.devices = this.appState.devices.filter(d => d.id !== deviceId)
    publishOperation(this.appState, `删除设备：${dev?.name || deviceId}`)
    if (this.onDeviceChanged) this.onDeviceChanged()
  }

  build() {
    Column({ space: 0 }) {
      // ── 标题栏 ──
      Row({ space: 8 }) {
        Text(ICONS.navDevice).fontSize(16).fontColor(COLORS.primary)
        Text('设备管理').fontSize(FONTS.titleSm).fontWeight(FontWeight.Bold).fontColor(COLORS.textPrimary)
        Blank()
        Text(`${this.getRoomDevices().length} 台`)
          .fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
          .padding({ top: 3, bottom: 3, left: 10, right: 10 })
          .backgroundColor(COLORS.bgPrimary).borderRadius(RADIUS.full)

        Button() {
          Text(this.showAddPanel ? '收起' : '+ 添加')
            .fontSize(FONTS.caption).fontWeight(FontWeight.Bold)
        }
        .height(32).fontColor('#FFF').backgroundColor(COLORS.primary)
        .borderRadius(RADIUS.full).padding({ left: 14, right: 14 })
        .onClick(() => { this.showAddPanel = !this.showAddPanel })
      }
      .width('100%').margin({ bottom: 14 })

      // ── 添加面板 ──
      if (this.showAddPanel) {
        Text('选择设备类型添加')
          .fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
          .width('100%').margin({ bottom: 8 })

        Row({ space: 8 }) {
          ForEach(TEMPLATES, (t: DeviceTemplate) => {
            Column({ space: 6 }) {
              Stack({ alignContent: Alignment.Center }) {
                Circle().width(42).height(42).fill(t.accent + '20')
                Text(DEVICE_ICONS[t.iconKey] || '◉').fontSize(18).fontColor(t.accent)
              }
              Text(t.name).fontSize(9).fontColor(COLORS.textSecondary)
            }
            .alignItems(HorizontalAlign.Center)
            .onClick(() => { this.addDevice(t) })
          })
        }
        .width('100%')
        .padding({ bottom: 14 })
      }

      // ── 已绑定设备管理列表 ──
      if (this.getRoomDevices().length > 0) {
        Text('已连接设备').fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
          .width('100%').margin({ bottom: 6 })

        ForEach(this.getRoomDevices(), (device: Device) => {
          Row({ space: 10 }) {
            Text(device.icon).fontSize(18)
            Text(device.name).fontSize(FONTS.caption).fontColor(COLORS.textSecondary).layoutWeight(1)
            Text('删除')
              .fontSize(10).fontColor(COLORS.danger)
              .padding({ top: 4, bottom: 4, left: 10, right: 10 })
              .border({ width: 1, color: '#FECACA', radius: RADIUS.full })
              .onClick(() => { this.removeDevice(device.id) })
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .border({ width: { bottom: 0.5 }, color: COLORS.borderLight })
        })
      } else {
        Text('当前房间无设备').fontSize(FONTS.caption).fontColor(COLORS.textTertiary)
          .width('100%').padding({ top: 8, bottom: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(COLORS.surface)
    .borderRadius(RADIUS.xl)
    .shadow({ radius: 8, color: 'rgba(15,23,42,0.08)', offsetY: 2 })
  }
}
