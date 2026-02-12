# /project - 生成项目AI说明

为项目生成AI友好的说明文件

## 使用方式

```
/project init [项目路径]     # 扫描项目，生成 .claude/project.md
/project update [项目路径]   # 更新项目说明（记录变更）
/project diff [项目路径]     # 查看git变更并更新说明
```

## /project init

1. 扫描项目目录
2. 识别技术栈（package.json, requirements.txt, go.mod等）
3. 分析目录结构
4. 读取README（如有）
5. 读取模板 `../shared/templates/ai-project.md`
6. 生成 `[项目路径]/.claude/project.md`
7. 询问用户补充业务概念和开发规范

## /project update

1. 读取现有 `.claude/project.md`
2. 询问本次变更内容
3. 更新"当前状态"、"进行中的任务"、"变更记录"

## /project diff

1. 运行 `git status` 和 `git log -5 --oneline`
2. 分析变更涉及的模块
3. 自动更新 `.claude/project.md` 中的：
   - 当前状态.最近变更
   - 变更记录

## 生成的文件位置

```
项目根目录/
└── .claude/
    └── project.md    # AI启动时应读取此文件
```

## 重要提示

当用户让你开发某个项目时：
1. 先检查项目是否有 `.claude/project.md`
2. 如果有，先读取它了解项目
3. 如果没有，建议用户执行 `/project init`
