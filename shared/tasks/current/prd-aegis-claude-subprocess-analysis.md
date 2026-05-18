# PRD: Aegis — claude CLI 子进程 AI 分析

**日期**: 2026-05-12  
**状态**: 待实施  
**作者**: Max (PM)  
**开发**: 贾维斯  
**分支**: feat/prompthooks

---

## 一、背景

Prompt Hook 实验结论（贾维斯已验证）：
- `type: "prompt"` 模型始终返回散文，无法传结构化数据给 command hook
- 两个 hook 并行，结果无法互通

新方向：在 command hook 内部，**review 判定成立后**，直接调 `claude` CLI 子进程做 AI 分析。

**核心优势**：
- 使用 Claude Code 自身认证（API key 或 OAuth 均可）
- 用户零配置
- 结果可直接传给后端，展示在 ApprovalModal

---

## 二、递归保护机制（必须先实现）

hook 调 claude CLI 子进程时，子进程也会触发 PreToolUse hook，形成无限递归。

**解法**：环境变量守卫

```
hook 脚本开头：
  IF process.env.AEGIS_IN_HOOK === '1'
    → 直接 process.exit(0)（放行，不分析）

调 claude CLI 子进程时：
  → 设置环境变量 AEGIS_IN_HOOK=1
  → 子进程的 hook 检测到后立即退出
  → 递归第一层断开
```

---

## 三、数据流

```
claude 执行 bash 命令
    ↓
PreToolUse → universal-hook-v2.js
    ↓ 检查 AEGIS_IN_HOOK（没有 → 继续）
    ↓
POST /api/v1/rules/evaluate
    ↓
规则引擎 → action: review
    ↓
[新增] 调 claude CLI 子进程（带 AEGIS_IN_HOOK=1）
    ├── 超时 5s → 跳过，继续 review 流程
    ├── CLI 不存在 → 跳过
    └── 成功 → 拿到 AIAnalysis JSON
    ↓
POST /api/v1/rules/evaluate（附带 aiAnalysis）
    ↓
后端创建审批记录 + WebSocket 广播（含 aiAnalysis）
    ↓
ApprovalModal 展示 AI 分析区块
```

---

## 四、claude CLI 调用方式

```javascript
const { execSync } = require('child_process');

function callClaudeForAnalysis(command, userInput, matchedRules) {
  const prompt = buildAnalysisPrompt(command, userInput, matchedRules);
  
  try {
    const result = execSync(`claude --print --model claude-haiku-4-5-20251001`, {
      input: prompt,
      env: { ...process.env, AEGIS_IN_HOOK: '1' },
      timeout: 5000,
      encoding: 'utf8',
    });
    return parseAnalysis(result);
  } catch {
    return null; // 超时或报错 → 静默跳过
  }
}
```

**注意**：
- `--print` 参数让 claude CLI 非交互式输出
- `input` 通过 stdin 传 prompt
- `env` 里注入 `AEGIS_IN_HOOK=1` 防递归
- `timeout: 5000` 超时保护

---

## 五、Prompt 设计

```
You are a shell command safety analyzer. Respond ONLY with valid JSON, no markdown.

COMMAND: <command>
USER INTENT: <userInput 前 300 字，若无则 "unknown">
TRIGGERED RULES: <matchedRules.join(', ')>

Analyze and respond with:
{
  "plainText": "1-2 sentences explaining what this command does and why it was flagged",
  "intentMatch": true or false,
  "alerts": ["specific concern 1", "specific concern 2"],
  "recommendation": "approve" | "caution" | "deny"
}
```

---

## 六、后端改动（rules.controller.ts）

evaluate 接口的请求体新增可选字段：

```typescript
interface EvaluateRequest {
  // ... 现有字段
  aiAnalysis?: {
    plainText: string;
    intentMatch: boolean;
    alerts: string[];
    recommendation: 'approve' | 'caution' | 'deny';
  };
}
```

review 路径的 `broadcastApprovalRequest` 里追加 `aiAnalysis` 字段。

---

## 七、前端改动（ApprovalModal.vue）

在 command display 和 details grid 之间插入 AI Analysis 区块（仅当 `currentApproval.aiAnalysis` 存在时渲染）：

```
┌─────────────────────────────────┐
│ 🤖 AI ANALYSIS    [CAUTION]  ⚠  │  ← indigo 主题，recommendation 彩色标签
│                                 │
│ This command will permanently   │  ← plainText
│ delete 4.2GB of project files.  │
│                                 │
│ ⚠ credentials.json detected    │  ← alerts 逐条
│ ⚠ Path outside project scope   │
└─────────────────────────────────┘
```

配色：
- 区块边框：`rgba(129,140,248,0.3)`（indigo）
- `approve` 标签：绿色
- `caution` 标签：amber
- `deny` 标签：红色
- `intentMatch: false` 显示 `⚠ INTENT MISMATCH`

---

## 八、不在本期范围

| 项目 | 原因 |
|------|------|
| 支持非 claude CLI 的 AI 提供商 | 本期专注零配置体验 |
| AI 分析结果持久化到 SQLite | 监控功能，Phase 2 |
| Prompt Hook（type:prompt）继续保留 | 作为 fail-secure 兜底，不做主力 |

---

## 九、开发备注

1. **先跑通递归保护再做其他**：在本地验证 `AEGIS_IN_HOOK=1` 能正确断开递归，这是整个方案的前提

2. **claude CLI 参数需验证**：`--print` 是否支持 stdin 输入、`--model` 参数格式，在当前 Claude Code 版本先确认一下

3. **aiAnalysis 是可选的**：后端和前端都要正确处理 `aiAnalysis` 为 `undefined` 的情况，不能因为 AI 分析失败就影响正常 review 流程

4. **hook 脚本里调 evaluateWithBackend 的时机**：目前 hook 先调 evaluate 拿到 action，再根据 action 决策。改动后变成：拿到 action=review → 调 claude CLI → 再带 aiAnalysis 重新调 evaluate（或者用 PATCH 接口追加分析）。贾维斯自行评估哪种改法更干净
