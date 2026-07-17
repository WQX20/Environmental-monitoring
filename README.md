# Environmental-monitoring

一个基于 HarmonyOS/OpenHarmony 的智慧环境生活管家应用，围绕“环境监测、场景联动、设备控制、AI 建议”四条主线展开，面向家庭室内环境的实时感知与智能响应。

## 项目简介

本项目通过首页、场景页、设备页和 AI 建议页，完成对温度、湿度、PM2.5、CO2、噪声、光照等环境指标的监测，并结合场景模式和设备联动规则，提供自动优化、手动控制和操作历史展示等能力。

## 核心功能

- 环境总览与状态评估
- 场景模式切换与联动控制
- 设备开关、目标值调节与一键全关
- AI 建议、历史趋势与健康提醒
- 操作历史与联动结果回传

## 模块分工

- A：环境监测总览 + 状态评估
- B：场景模式 + 页面交互
- C：设备联动 + 业务逻辑
- D：AI 建议 + 历史趋势 + 答辩材料

## 项目特点

- 统一的全局状态管理，页面间联动一致
- 支持场景驱动的自动设备控制
- 支持手动接管，避免自动逻辑覆盖用户操作
- 提供最近操作记录，便于调试和演示

## AI 模型接入说明

当前项目已经保留了本地规则建议，同时预留了一个最小的模型接入入口。你只需要准备一个后端接口，然后修改前端配置即可。

### 1. 前端需要改的地方

- 打开 [entry/src/main/ets/data/Constants.ets](entry/src/main/ets/data/Constants.ets)
- 把 `AI_MODEL_CONFIG.enabled` 改成 `true`
- 把 `AI_MODEL_CONFIG.endpoint` 改成你的后端地址，例如 `https://your-domain.com/ai/advice`

### 2. 后端接口要求

前端会 `POST` 下面这种请求体：

```json
{
	"scene": "学习模式",
	"currentEnv": {
		"temperature": 25,
		"humidity": 50,
		"pm25": 30,
		"co2": 600,
		"noise": 40,
		"light": 300,
		"outdoorTemp": 28,
		"outdoorHumidity": 55,
		"outdoorPm25": 25,
		"outdoorQuality": "良"
	},
	"deviceSummary": ["客厅空调:关闭,目标26°C"],
	"recentOperations": ["12:00 已开启空气净化器"]
}
```

后端返回建议列表即可，格式如下：

```json
{
	"suggestions": [
		{
			"title": "建议开窗通风",
			"detail": "当前 CO2 偏高，适合短时通风",
			"actionLabel": "记录已开窗",
			"actionType": "openWindow",
			"category": "环境",
			"icon": "◫"
		}
	]
}
```

### 3. 接口实现原则

- 接口尽量只负责转发到模型，不要把密钥直接放进前端。
- 如果模型接口失败，前端会自动继续使用本地规则建议，不影响页面展示。
- 返回的数据只要符合上面的字段，就能直接显示到 AI 建议页。

### 4. 最简后端思路

你可以用任意语言做一个代理接口，流程是：

1. 前端把环境数据发给你的后端。
2. 后端拼一个提示词，转发给大模型。
3. 大模型返回结构化建议。
4. 后端把建议原样返回给前端。

如果你想先快速演示，也可以先把后端写成固定返回几条建议的 mock 接口，前端这一套已经能直接接上。

### 5. 现成可跑的本地后端

项目里已经放了一个最小后端在 [backend/server.js](backend/server.js)。它默认先以 mock 模式运行，前端会直接请求 `http://127.0.0.1:3000/ai/advice`。

运行方式：

```bash
cd backend
node server.js
```

Windows 下也可以直接运行 [backend/start.ps1](backend/start.ps1)：

```powershell
cd backend
.\start.ps1
```

如果你想直接双击启动，也可以运行 [backend/run.bat](backend/run.bat)。

如果你后面要切成真实模型，只需要在 `backend/.env.example` 里参考下面这些变量：

- `AI_BACKEND_MODE=proxy`
- `MODEL_API_URL=https://api.deepseek.com/chat/completions`
- `MODEL_API_KEY=你的 DeepSeek API Key`
- `MODEL_NAME=deepseek-chat`

然后把这些环境变量放到实际运行环境里即可。前端不用再改。

### 6. DeepSeek 接入步骤

如果你要直接接 DeepSeek，按这个顺序做就行：

1. 去 DeepSeek 控制台创建 API Key。
2. 在后端设置环境变量：

```bash
AI_BACKEND_MODE=proxy
MODEL_API_URL=https://api.deepseek.com/chat/completions
MODEL_API_KEY=你的Key
MODEL_NAME=deepseek-chat
```

3. 启动后端：

```bash
cd backend
node server.js
```

4. 保持前端这里不变，继续请求 `http://127.0.0.1:3000/ai/advice`。
5. 后端会把前端数据转发给 DeepSeek，再把模型返回的建议转成前端可显示的 `suggestions`。

如果你只想先验证通路，可以先把 `AI_BACKEND_MODE` 留在 `mock`，等页面能正常显示后再切到 `proxy`。
