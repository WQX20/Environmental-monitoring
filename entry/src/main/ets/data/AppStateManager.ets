// ============================================================
// 全局状态管理器 — 单例模式
// ============================================================
import { AppState } from '../model/DataModels'

// 全局唯一实例
export const sharedState: AppState = new AppState()
