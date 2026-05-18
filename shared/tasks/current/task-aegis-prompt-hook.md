# 功能开发任务: Aegis Prompt Hook AI 分析

## 任务概述

在 Aegis 的 Claude Code hook 安装流程中，新增一个 `type: "prompt"` 的 PreToolUse Hook。
该 Hook 调用 Claude Code 自身模型（无需用户另配 API key）对 bash 命令进行 AI 安全分析，
与现有 command hook（规则引擎）并行运行。

- **分支**: `feat/prompthooks`（已存在，在此分支上开发）
- **项目路径**: `/Users/yuhao/Desktop/yezannnnn/aegis-v2`
- **PRD 文件**: `shared/tasks/current/prd-aegis-prompt-hook.md`
- **负责人**: 贾维斯
- **优先级**: 高

---

## 需要修改的文件

| 文件 | 改动类型 | 说明 |
|------|---------|------|
| `bin/setup-utils.js` | 修改 | `setupClaudeCodeHook()` 内追加 prompt hook entry |
| `bin/setup-utils.js` 顶部 | 新增 | `AEGIS_PROMPT_HOOK` 常量（prompt 模板） |

**不需要改动：**
- `backend/` — 规则引擎不变
- `frontend/` — ApprovalModal 不变
- `hooks/claude-code/universal-hook-v2.js` — command hook 不变

---

## 交付标准

1. `aegis setup` 执行后，`~/.claude/settings.json` 的 `hooks.PreToolUse` 数组中出现两条记录：
   - 原有的 `type: "command"` (universal-hook.js)
   - 新增的 `type: "prompt"` (Aegis AI 分析)

2. Prompt Hook 能正确写入 settings.json，不破坏现有 command hook 配置

3. 对已有 Aegis 安装执行 `aegis setup` 时，旧 prompt hook 条目被正确替换（不重复追加）

4. PRD 中的 prompt 模板经过验证，Claude 能返回合法 JSON（`permissionDecision` + `reason`）

---

## 验收方式

```bash
# 1. 跑 setup（可加 --skip-deps 加速）
aegis setup --skip-deps

# 2. 检查 settings.json 里有 type: prompt 的条目
cat ~/.claude/settings.json | grep -A5 '"type": "prompt"'

# 3. 在 Claude Code 里执行一条危险命令，观察状态栏出现 "🛡️ Aegis AI analyzing..."
rm -rf /tmp/aegis-test-dir
```
