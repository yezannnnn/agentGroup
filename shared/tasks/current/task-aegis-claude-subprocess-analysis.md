# 开发任务: Aegis — claude CLI 子进程 AI 分析

## 任务概述

在命令命中 review 时，从 command hook 内部调用 `claude` CLI 子进程进行 AI 安全分析。
使用 Claude Code 当前的认证（API key 或 OAuth 均可），无需用户另行配置。
分析结果通过 Aegis 后端广播给前端 ApprovalModal 展示。

- **分支**: `feat/prompthooks`（在此分支继续开发）
- **项目路径**: `/Users/yuhao/Desktop/yezannnnn/aegis-v2`
- **PRD 文件**: `shared/tasks/current/prd-aegis-claude-subprocess-analysis.md`
- **负责人**: 贾维斯
- **优先级**: 高

---

## 需要修改的文件

| 文件 | 改动类型 | 说明 |
|------|---------|------|
| `hooks/claude-code/universal-hook-v2.js` | 修改 | review 判定后，调 claude CLI 子进程获取分析 |
| `backend/src/modules/rules/rules.controller.ts` | 修改 | evaluate 接口接收 aiAnalysis 字段并广播 |
| `frontend/src/components/ApprovalModal.vue` | 修改 | 展示 aiAnalysis 区块（indigo 主题） |

---

## 交付标准

1. 命中 review 的命令，ApprovalModal 里出现 AI 分析区块
2. AI 分析使用 Claude Code 当前认证（不需要用户配置任何 key）
3. 递归保护有效：`AEGIS_IN_HOOK=1` 环境变量存在时，hook 跳过 AI 分析直接放行
4. 超时保护有效：claude CLI 调用超过 5 秒则跳过，不影响 review 流程
5. claude CLI 不可用时（未安装/报错），静默跳过，review 流程正常继续

---

## 验收方式

```bash
# 1. 触发一条 review 级别命令
# 在 Claude Code 里让 AI 执行：rm -rf /tmp/aegis-test/

# 2. 观察 ApprovalModal 里有没有 AI Analysis 区块
# 区块应显示：意图判断 + 风险级别 + alerts

# 3. 验证递归保护
AEGIS_IN_HOOK=1 node ~/.aegis/universal-hook.js
# 应该直接放行，不调 claude CLI
```
