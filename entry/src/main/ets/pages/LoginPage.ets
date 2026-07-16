// ============================================================
// 登录/注册页 — 手机号 + 密码 + 游客模式
// ============================================================
import { router } from '@kit.ArkUI'
import { COLORS, FONTS, RADIUS } from '../data/Constants'
import { EilLogo } from '../components/EilLogo'
import { sharedState } from '../data/AppStateManager'

@Entry
@Component
struct LoginPage {
  @State isRegister: boolean = false
  @State phone: string = ''
  @State password: string = ''
  @State confirmPwd: string = ''
  @State showPwd: boolean = false
  @State toastMsg: string = ''
  @State showToast: boolean = false

  toast(msg: string): void {
    this.toastMsg = msg
    this.showToast = true
    setTimeout(() => { this.showToast = false }, 1600)
  }

  resetForm(): void {
    this.phone = ''
    this.password = ''
    this.confirmPwd = ''
    this.showPwd = false
  }

  handleSubmit(): void {
    if (this.phone.trim() === '') {
      this.toast('请输入手机号')
      return
    }
    if (this.phone.trim().length < 11) {
      this.toast('手机号格式不正确')
      return
    }
    if (this.password.length < 6) {
      this.toast('密码至少 6 位')
      return
    }

    if (this.isRegister) {
      // 注册模式 — 校验确认密码
      if (this.confirmPwd === '') {
        this.toast('请确认密码')
        return
      }
      if (this.password !== this.confirmPwd) {
        this.toast('两次密码不一致')
        return
      }
      this.toast('注册成功，请登录')
      this.isRegister = false
      this.resetForm()
    } else {
      // 登录模式
      this.toast('登录成功，欢迎回来')
      setTimeout(() => { router.replaceUrl({ url: 'pages/Index' }) }, 600)
    }
  }

  handleGuest(): void {
    router.replaceUrl({ url: 'pages/Index' })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column({ space: 0 }) {
          // ═══ 头部 ═══
          Column({ space: 0 }) {
            EilLogo({ logoSize: 80, logoColor: this.isRegister ? '#8B5CF6' : COLORS.primary })
            .margin({ bottom: 16 })

            Text(this.isRegister ? '创建账号' : '欢迎使用')
              .fontSize(FONTS.titleLg)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.textPrimary)
              .margin({ bottom: 4 })
            Text('智慧环境生活管家')
              .fontSize(FONTS.bodySm)
              .fontColor(COLORS.textTertiary)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: 70, bottom: 36 })

          // ═══ 表单 ═══
          Column({ space: 14 }) {
            // 手机号
            Row({ space: 10 }) {
              Text('📱').fontSize(18)
              TextInput({ placeholder: '请输入手机号', text: this.phone })
                .type(InputType.PhoneNumber)
                .maxLength(11)
                .fontSize(FONTS.body)
                .height(48)
                .layoutWeight(1)
                .backgroundColor('transparent')
                .onChange((v: string) => { this.phone = v })
            }
            .width('100%')
            .padding({ left: 14, right: 14 })
            .backgroundColor(COLORS.bgPrimary)
            .borderRadius(RADIUS.lg)

            // 密码
            Row({ space: 10 }) {
              Text('🔒').fontSize(18)
              TextInput({ placeholder: '请输入密码（至少6位）', text: this.password })
                .type(this.showPwd ? InputType.Normal : InputType.Password)
                .fontSize(FONTS.body)
                .height(48)
                .layoutWeight(1)
                .backgroundColor('transparent')
                .onChange((v: string) => { this.password = v })
              Text(this.showPwd ? '🙈' : '👁️')
                .fontSize(16)
                .onClick(() => { this.showPwd = !this.showPwd })
            }
            .width('100%')
            .padding({ left: 14, right: 14 })
            .backgroundColor(COLORS.bgPrimary)
            .borderRadius(RADIUS.lg)

            // 注册模式 — 确认密码
            if (this.isRegister) {
              Row({ space: 10 }) {
                Text('✓').fontSize(18).fontColor(COLORS.textTertiary)
                TextInput({ placeholder: '请再次输入密码', text: this.confirmPwd })
                  .type(InputType.Password)
                  .fontSize(FONTS.body)
                  .height(48)
                  .layoutWeight(1)
                  .backgroundColor('transparent')
                  .onChange((v: string) => { this.confirmPwd = v })
              }
              .width('100%')
              .padding({ left: 14, right: 14 })
              .backgroundColor(COLORS.bgPrimary)
              .borderRadius(RADIUS.lg)
            }
          }
          .width('85%')
          .margin({ bottom: 28 })

          // ═══ 提交按钮 ═══
          Button(this.isRegister ? '注  册' : '登  录')
            .fontSize(FONTS.bodyLg)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width('85%')
            .height(50)
            .backgroundColor(this.isRegister ? '#8B5CF6' : sharedState.getThemePrimary())
            .borderRadius(RADIUS.xl)
            .shadow({ radius: 12, color: this.isRegister ? 'rgba(139,92,246,0.35)' : 'rgba(13,148,136,0.35)', offsetY: 4 })
            .onClick(() => { this.handleSubmit() })
            .margin({ bottom: 18 })

          // ═══ 切换登录/注册 ═══
          Row({ space: 4 }) {
            Text(this.isRegister ? '已有账号？' : '没有账号？')
              .fontSize(FONTS.caption)
              .fontColor(COLORS.textTertiary)
            Text(this.isRegister ? '去登录' : '注册账号')
              .fontSize(FONTS.caption)
              .fontColor(this.isRegister ? '#8B5CF6' : COLORS.primary)
              .fontWeight(FontWeight.Medium)
            Text('→')
              .fontSize(FONTS.caption)
              .fontColor(this.isRegister ? '#8B5CF6' : COLORS.primary)
          }
          .onClick(() => {
            this.isRegister = !this.isRegister
            this.resetForm()
          })
          .margin({ bottom: 14 })

          // ═══ 游客模式 ═══
          Text('游客模式进入')
            .fontSize(FONTS.caption)
            .fontColor(COLORS.textTertiary)
            .onClick(() => { this.handleGuest() })
            .margin({ bottom: 16 })

          Text(this.isRegister ? '注册即表示同意《用户协议》和《隐私政策》' : '登录即表示同意《用户协议》和《隐私政策》')
            .fontSize(10)
            .fontColor(COLORS.textTertiary)
        }
        .width('100%')
      }
      .width('100%').height('100%')
      .backgroundColor('#FFFFFF')

      // ═══ Toast ═══
      if (this.showToast) {
        Text(this.toastMsg)
          .fontSize(FONTS.caption).fontColor('#FFF')
          .padding({ top: 12, bottom: 12, left: 20, right: 20 })
          .backgroundColor('#1E293B')
          .borderRadius(RADIUS.lg)
          .shadow({ radius: 16, color: 'rgba(30,41,59,0.50)', offsetY: 6 })
          .margin({ bottom: 80 })
      }
    }
    .width('100%').height('100%')
  }
}
