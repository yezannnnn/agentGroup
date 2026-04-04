# Agent-Group V2 迁移计划总览

> 基于 `agent_group_simp.md` 改造方案，从 `agent-group/` 重建至 `agent-group-v2/`

## 迁移策略

**不是原地修改，而是在 `agent-group-v2/` 全新构建**，确保：
- 旧系统 `agent-group/` 保持可用，随时可回退
- 新系统经过验证后再正式切换
- 每个子计划可独立执行、独立验证

## 子计划清单

| 编号 | 子计划名称 | 核心内容 | 依赖 | 状态 |
|------|-----------|---------|------|------|
| 01 | 目录骨架与基础设施 | 创建 v2 完整目录结构、.claude/skills、shared/specs、shared/handoff、protocols、scripts | 无 | ⏳ 待执行 |
| 02 | 公共协议与模板 | 第一性约束模板、mandatory-flow 强制流程、Git安全规则、Token监控、Cross-Tag 模板 | 01 | ⏳ 待执行 |
| 03 | Max 角色重建 | CLAUDE.md + PERSONA.md + skills 迁移，集成 openspec 驱动的需求管理 | 01, 02 | ⏳ 待执行 |
| 04 | Ella 角色重建 | CLAUDE.md + PERSONA.md + skills 迁移，集成 openspec 提案的设计工作流 | 01, 02 | ⏳ 待执行 |
| 05 | Jarvis-FE 角色新建 | CLAUDE.md + PERSONA.md + 前端专属 skills，三层技能体系+前后端联动协作 | 01, 02 | ⏳ 待执行 |
| 06 | Jarvis-BE 角色新建 | CLAUDE.md + PERSONA.md + 后端专属 skills，三层技能体系+前后端联动协作 | 01, 02 | ⏳ 待执行 |
| 07 | Kyle 角色重建 | CLAUDE.md + PERSONA.md + skills 迁移，集成 openspec 验收审查 | 01, 02 | ⏳ 待执行 |
| 08 | Jarvis 弃用桥接 | 保留 jarvis/ 目录，CLAUDE.md 标记弃用指向 jarvis-fe/jarvis-be | 05, 06 | ⏳ 待执行 |
| 09 | openspec 配置迁移 | config.yaml 更新 + changes 目录迁移到 shared/specs/openspec/ | 01 | ⏳ 待执行 |
| 10 | 启动脚本与 README | 更新启动脚本、README.md、skills-distribution.md | 03-08 | ⏳ 待执行 |
| 11 | 集成验证清单 | 端到端验证步骤：Max 提案 → Ella 设计 → Jarvis-FE/BE 开发 → Kyle 审查 | 01-10 | ⏳ 待执行 |

## 架构对比

### 现有架构 (agent-group/)
```
agent-group/
├── .claude/skills/          # openspec skills (共享)
├── max/                     # 项目经理
├── ella/                    # UI/UX设计师
├── jarvis/                  # 全栈开发（前后端合一）
├── kyle/                    # QA工程师
├── shared/                  # 扁平混杂的共享目录
├── openspec/                # openspec 独立目录
└── scripts/                 # 工具脚本
```

### 目标架构 (agent-group-v2/)
```
agent-group-v2/
├── .claude/
│   ├── skills/              # openspec skills (共享)
│   └── settings.local.json
├── max/                     # 项目经理（+openspec驱动）
│   ├── CLAUDE.md            # 含第一性约束 + openspec + 读写契约
│   ├── PERSONA.md
│   └── skills/
├── ella/                    # UI/UX设计师（+handoff契约）
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
├── jarvis-fe/               # 前端开发【新增】
│   ├── CLAUDE.md            # 三层技能体系 + Cross-Tagging
│   ├── PERSONA.md
│   └── skills/
│       ├── react-frontend/
│       ├── senior-frontend/
│       └── superpowers-guide/
├── jarvis-be/               # 后端开发【新增】
│   ├── CLAUDE.md            # 三层技能体系 + Cross-Tagging
│   ├── PERSONA.md
│   └── skills/
│       ├── java-backend/
│       ├── code-reviewer/
│       ├── tdd-guide/
│       └── superpowers-guide/
├── jarvis/                  # 弃用桥接
│   └── CLAUDE.md            # 指向 jarvis-fe 或 jarvis-be
├── kyle/                    # QA工程师（+openspec验收）
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
├── shared/
│   ├── protocols/           # 【新增】公共流程（所有角色引用）
│   │   └── mandatory-flow.md
│   ├── specs/               # 【新增】统一 spec 产出
│   │   └── openspec/
│   │       ├── changes/
│   │       └── config.yaml
│   ├── handoff/             # 【新增】角色间交付物
│   │   ├── ella-to-jarvis/
│   │   ├── jarvis-to-kyle/
│   │   ├── kyle-to-jarvis/
│   │   ├── fe-to-be/
│   │   └── be-to-fe/
│   ├── scripts/
│   ├── templates/
│   ├── status.json
│   └── notifications.json
├── scripts/
└── README.md
```

## 核心改造点总结

1. **Jarvis 拆分**: 全栈 jarvis → jarvis-fe (前端) + jarvis-be (后端)
2. **第一性约束**: 所有角色 CLAUDE.md 顶部注入不可绕过约束
3. **三层技能体系**: openspec(做什么) → superpowers(怎么做) → 自定义skill(怎么写)
4. **读写契约**: 每个角色明确声明 shared/ 下的读取/写入/禁写范围
5. **Cross-Tagging**: 前后端双向标注协作，不依赖 Max 做完美拆分
6. **公共流程提取**: 强制检查点序列从各角色剥离，统一放 shared/protocols/
7. **openspec 迁移**: 从 agent-group/openspec/ 迁移到 shared/specs/openspec/
8. **handoff 目录**: 取代散落的 designs/、reviews/，实现结构化交付

## 执行原则

- **实事求是**: 基于实际文件内容改造，不凭空编造
- **增量验证**: 每个子计划执行完毕后验证，再继续下一个
- **向后兼容**: 旧系统不受影响，过渡期可并行使用
- **最小变更**: 能复用的内容直接复制，只改造需要改的部分
