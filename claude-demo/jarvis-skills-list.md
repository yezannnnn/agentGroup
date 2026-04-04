# Jarvis Skills 详细说明

> 路径：`jarvis/skills/`  
> 更新日期：2026-03-20

---

## 目录结构总览

```
jarvis/skills/
├── token-optimization.md          # Token 优化策略（独立配置文件）
├── claude-simone/                 # Claude Simone — 项目与任务管理系统
└── engineering-team/              # 工程团队技能集合（18 个角色技能）
    ├── CLAUDE.md                  # Claude Code 使用指南
    ├── README.md                  # 工程团队总说明
    ├── START_HERE.md              # 快速上手指引
    ├── TEAM_STRUCTURE_GUIDE.md    # 团队结构指南
    ├── senior-architect/          # 高级架构师
    ├── senior-frontend/           # 高级前端工程师
    ├── senior-backend/            # 高级后端工程师
    ├── senior-fullstack/          # 高级全栈工程师
    ├── senior-qa/                 # 高级 QA 测试工程师
    ├── senior-devops/             # 高级 DevOps 工程师
    ├── senior-secops/             # 高级 SecOps 安全运营工程师
    ├── code-reviewer/             # 代码审查员
    ├── senior-security/           # 高级安全工程师
    ├── aws-solution-architect/    # AWS 解决方案架构师
    ├── ms365-tenant-manager/      # Microsoft 365 租户管理员
    ├── tdd-guide/                 # 测试驱动开发指南
    ├── tech-stack-evaluator/      # 技术栈评估师
    ├── senior-data-scientist/     # 高级数据科学家
    ├── senior-data-engineer/      # 高级数据工程师
    ├── senior-ml-engineer/        # 高级机器学习工程师
    ├── senior-prompt-engineer/    # 高级 Prompt 工程师
    └── senior-computer-vision/    # 高级计算机视觉工程师
```

每个技能目录的标准结构：
```
skill-name/
├── SKILL.md              # 主技能文档（触发词、工具、工作流、参考指南）
├── references/           # 3 份详细参考指南
│   ├── *_patterns.md
│   ├── *_guide.md
│   └── *_practices.md
└── scripts/              # 3 个 Python 自动化脚本
    ├── *_generator.py
    ├── *_analyzer.py
    └── *_scaffolder.py
```

---

## 一、独立配置文件

### `token-optimization.md` — Token 优化策略

**版本**：v1.2 | **作者**：贾维斯 (Jarvis)  
**目标**：开发过程 Token 使用量减少 60% 以上

包含十个优化策略模块：

| 模块                     | 节省比例 | 核心策略                                               |
| ------------------------ | -------- | ------------------------------------------------------ |
| 智能文件读取             | ~35%     | 先 Grep 定位，再用 offset/limit 精准读取，避免全文读取 |
| 减少冗余说明             | ~25%     | 只保留技术实现要点、错误处理逻辑、代码修改确认         |
| 工具使用优化             | ~20%     | 用 Glob 代替 `ls`，用 Grep 精准搜索，跳过重复验证      |
| 批量操作                 | ~15%     | 多个修改合并为一次操作，避免逐步处理                   |
| 响应简化策略             | —        | 必要信息：技术方案 + 关键实现；省略重复确认、过度解释  |
| 质量保证                 | —        | 绝不妥协代码逻辑分析、Bug 验证、边界情况、错误处理     |
| **模型选择策略（v1.2）** | —        | 见下表                                                 |
| Task 多模型优化（v1.2）  | —        | 分阶段任务拆解，合理分配不同模型                       |
| Opus 使用确认机制        | —        | 识别 Opus 场景后先向用户询问，再决策                   |
| 使用指南                 | —        | 简单任务用全部优化，复杂任务保持详细分析               |

**模型选择决策树**：

| 模型   | 使用率 | 适用场景                                      |
| ------ | ------ | --------------------------------------------- |
| Haiku  | 30-40% | 文件操作、文本替换、配置生成、Git 操作        |
| Sonnet | 50-60% | 架构设计、Bug诊断、complex 代码实现、技术评估 |
| Opus   | 5-10%  | 架构重构、深度性能优化、方案评估（需确认）    |

**Task 分解示例**（节省 57% Token）：
```python
Task(model="haiku",  prompt="创建项目目录和基础文件结构")
Task(model="haiku",  prompt="生成配置文件和依赖管理")
Task(model="sonnet", prompt="设计认证架构和实现核心逻辑")
Task(model="haiku",  prompt="验证代码格式和依赖完整性")
```

---

## 二、claude-simone — 项目与任务管理系统

**来源**：[claude-simone](https://github.com/Helmi/claude-simone)  
**功能**：专为 AI 辅助开发工作流设计的项目和任务管理系统

### 两个实现版本

#### 🏗️ Legacy System（原始版本，`legacy/`）
- 目录式任务管理系统
- 功能较完整，已在实际项目中使用

#### 🚀 MCP Server（早期访问，`mcp-server/`）
基于 Model Context Protocol 的新版实现，提供：
- 结构化 Prompt 管理
- 活动追踪
- 多工具集成

**`hello-simone/`**：通用安装器，支持 Legacy 和 MCP 两个版本

### 主要文件说明

| 文件/目录        | 说明                                                   |
| ---------------- | ------------------------------------------------------ |
| `CLAUDE.md`      | Claude Code 中使用 Simone 的配置说明                   |
| `documentation/` | Docusaurus 文档网站（含架构、安装、工作流说明）        |
| `versions/`      | 版本管理工具和版本清单                                 |
| `hello-simone/`  | 通用安装脚本（`install-mcp.js` / `install-legacy.js`） |
| `mcp-server/`    | MCP 服务端完整实现（含 TypeScript 源码、模板、测试）   |

### 核心文档（`documentation/`）

| 文档                  | 内容                      |
| --------------------- | ------------------------- |
| `introduction.md`     | Simone 系统概述与设计理念 |
| `initialize.md`       | 项目初始化步骤            |
| `do_task.md`          | 执行任务的详细工作流      |
| `mcp-architecture.md` | MCP 版本架构说明          |
| `mcp-workflow.md`     | MCP 工作流详解            |
| `mcp-installation.md` | MCP 安装步骤              |
| `prompt-reference.md` | Prompt 完整参考手册       |

---

## 三、engineering-team — 工程团队技能集合

### 说明文件

| 文件                      | 说明                                            |
| ------------------------- | ----------------------------------------------- |
| `CLAUDE.md`               | 18 个技能 + 30+ 工具的 Claude Code 综合使用指南 |
| `README.md`               | 9 个核心工程角色的详细说明和用法                |
| `START_HERE.md`           | 快速上手指南，含团队规模推荐和使用场景          |
| `TEAM_STRUCTURE_GUIDE.md` | 从 Startup 到 Enterprise 的完整团队结构指南     |

**技术栈支持**：
- **前端**：React 18+、Next.js 14+、TypeScript、Tailwind CSS、React Native、Flutter
- **后端**：Node.js 20+、Express、GraphQL (Apollo)、Go、Python (FastAPI)
- **数据库**：PostgreSQL 16+、Prisma ORM、NeonDB、Supabase
- **移动端**：Swift (iOS)、Kotlin (Android)、React Native、Flutter
- **DevOps**：Docker、Kubernetes、Terraform、GitHub Actions、AWS/GCP/Azure

---

### 工程核心技能（9 个）

---

#### 1. `senior-architect` — 高级软件架构师

**触发场景**：系统架构设计、技术栈决策、架构图生成、依赖分析、数据库选型、可扩展性规划、架构评审

**三大工具**：

| 工具                                | 功能                               | 命令示例                                                                                       |
| ----------------------------------- | ---------------------------------- | ---------------------------------------------------------------------------------------------- |
| `architecture_diagram_generator.py` | 生成 Mermaid/PlantUML/ASCII 架构图 | `python scripts/architecture_diagram_generator.py ./project --format mermaid --type component` |
| `dependency_analyzer.py`            | 分析依赖耦合度和循环依赖           | `python scripts/dependency_analyzer.py ./project --check circular --verbose`                   |
| `project_architect.py`              | 检测架构模式、代码组织问题         | `python scripts/project_architect.py ./project --verbose`                                      |

**决策工作流**：
- **数据库选型**：按数据特性 → 规模需求 → 一致性要求 → ADR 文档化
- **架构模式选择**：按团队规模 → 部署需求 → 数据边界 → 匹配模式
- **单体 vs 微服务**：团队 <10 人、领域边界不清晰、快速迭代优先 → 单体；独立部署、差异化扩缩容 → 微服务

**参考文档**：`architecture_patterns.md`（9种架构模式）、`system_design_workflows.md`（6个设计流程）、`tech_decision_guide.md`（选型决策矩阵）

**支持技术栈**：TypeScript、Python、Go、Rust；React、Next.js、Vue；Node.js、FastAPI；PostgreSQL、MongoDB、Redis、DynamoDB；Docker、Kubernetes、Terraform

---

#### 2. `senior-frontend` — 高级前端工程师

**触发场景**：React 组件开发、Next.js 性能优化、Bundle 大小分析、前端项目脚手架、无障碍访问、前端代码质量审查

**三大工具**：

| 工具                     | 功能                                 | 模板/选项                                                      |
| ------------------------ | ------------------------------------ | -------------------------------------------------------------- |
| `frontend_scaffolder.py` | 生成 Next.js / React+Vite 项目       | `--template nextjs/react`，`--features auth,api,forms,testing` |
| `component_generator.py` | 生成 React 组件（含测试、Storybook） | `--type client/server/hook`，`--with-test --with-story`        |
| `bundle_analyzer.py`     | 分析 Bundle 重量依赖                 | 识别 moment(290KB)、lodash(71KB) 等，推荐轻量替代              |

**关键知识要点**：

- **Server vs Client 组件**：默认用 Server Component；需要事件处理、useState、useEffect、浏览器 API 时才加 `'use client'`
- **Next.js 图片优化**：首屏图片加 `priority`；响应式图用 `fill` + `sizes`
- **数据获取**：并行用 `Promise.all()`；部分阻塞用 `<Suspense>` 流式渲染
- **无障碍检查清单**：语义 HTML、键盘导航、ARIA 标签、颜色对比度 ≥4.5:1、焦点指示

**Bundle 优化参考**：

| 依赖          | 大小  | 轻量替代                     |
| ------------- | ----- | ---------------------------- |
| moment        | 290KB | date-fns(12KB) 或 dayjs(2KB) |
| lodash        | 71KB  | lodash-es + tree-shaking     |
| axios         | 14KB  | 原生 fetch 或 ky(3KB)        |
| @mui/material | 大    | shadcn/ui 或 Radix UI        |

**参考文档**：`react_patterns.md`、`nextjs_optimization_guide.md`、`frontend_best_practices.md`

---

#### 3. `senior-backend` — 高级后端工程师

**触发场景**：REST/GraphQL API 设计、数据库查询优化、身份认证实现、微服务构建、后端代码审查

**三大工具**：

| 工具                         | 功能                                                | 命令示例                                                                                         |
| ---------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `api_scaffolder.py`          | 从 OpenAPI spec 生成路由处理器、验证中间件、TS 类型 | `python scripts/api_scaffolder.py openapi.yaml --framework express --output src/routes/`         |
| `database_migration_tool.py` | 分析数据库 Schema，生成迁移文件                     | `python scripts/database_migration_tool.py --connection $DB_URL --analyze`                       |
| `api_load_tester.py`         | HTTP 压力测试，输出延迟分布和吞吐量                 | `python scripts/api_load_tester.py https://api.example.com/users --concurrency 50 --duration 30` |

**三大工作流**：
1. **API 设计**：定义 OpenAPI → 生成脚手架 → 实现业务逻辑 → 添加验证中间件 → 生成最新 spec
2. **数据库优化**：分析 → 识别慢查询 → 生成索引迁移 → dry-run 测试 → 应用验证
3. **安全加固**：复查 JWT 配置 → 添加限流中间件 → Zod 输入验证 → 压力测试 → Helmet 安全头

**索引策略速查**：
```sql
-- 单列（等值查找）
CREATE INDEX idx_users_email ON users(email);
-- 复合（多列查询）
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
-- 部分索引（条件过滤）
CREATE INDEX idx_orders_active ON orders(created_at) WHERE status = 'active';
-- 覆盖索引（避免回表）
CREATE INDEX idx_users_email_name ON users(email) INCLUDE (name);
```

**参考文档**：`api_design_patterns.md`（REST vs GraphQL、版本管理、错误处理）、`database_optimization_guide.md`、`backend_security_practices.md`（OWASP Top 10）

---

#### 4. `senior-fullstack` — 高级全栈工程师

**触发场景**：搭建新项目、代码质量分析、全栈架构、前后端集成、测试策略、部署工作流

**三大工具**：

| 工具                       | 功能                                            | 支持模板                                          |
| -------------------------- | ----------------------------------------------- | ------------------------------------------------- |
| `project_scaffolder.py`    | 生成完整项目结构（含 Docker、CI/CD、.env 模板） | `nextjs`、`fastapi-react`、`mern`、`django-react` |
| `code_quality_analyzer.py` | 分析安全漏洞、复杂度指标、依赖健康度            | 输出 0-100 评分 + 字母等级 + 优先建议             |
| `fullstack_scaffolder.py`  | 快速全栈应用脚手架                              | `nextjs-graphql`、`react-rest-mongodb` 等         |

**栈选型矩阵**：

| 需求           | 推荐技术栈          |
| -------------- | ------------------- |
| SEO 关键站点   | Next.js with SSR    |
| 内部 Dashboard | React + Vite        |
| API 优先后端   | FastAPI 或 Fastify  |
| 企业级规模     | NestJS + PostgreSQL |
| 快速原型       | Next.js API routes  |

**代码质量分析输出示例**：
```
Overall Score: 75/100 (Grade: C)
Security:      Critical: 1, High: 2, Medium: 5
Complexity:    Average: 8.5, High-Complexity Files: 3
Recommendations:
[P0] Remove hardcoded secret at line 42
```

**参考文档**：`tech_stack_guide.md`、`architecture_patterns.md`（前后端架构）、`development_workflows.md`（Git、CI/CD、测试、部署）

---

#### 5. `senior-qa` — 高级 QA 测试工程师

**触发场景**：生成单元测试、测试覆盖率分析、E2E 测试脚手架、Playwright 配置、Jest 配置、测试策略

**测试框架支持**：Jest + React Testing Library（单元/集成）、Playwright（E2E）、Istanbul/NYC（覆盖率）、MSW（API Mock）

**三大工具**：

| 工具                      | 功能                                                      | 命令示例                                                                                    |
| ------------------------- | --------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `test_suite_generator.py` | 扫描 React 组件，生成 Jest + RTL 测试桩（含无障碍断言）   | `python scripts/test_suite_generator.py src/components/ --output __tests__/ --include-a11y` |
| `coverage_analyzer.py`    | 解析 Istanbul/LCOV 报告，识别关键路径覆盖盲点             | `python scripts/coverage_analyzer.py coverage/coverage-final.json --threshold 80`           |
| `e2e_test_scaffolder.py`  | 扫描 Next.js 路由，生成 Playwright Page Object Model 测试 | `python scripts/e2e_test_scaffolder.py src/app/ --output e2e/ --include-pom`                |

**三大工作流**：
1. **单元测试生成**：扫描 → 生成桩代码 → 补充业务逻辑 → 运行覆盖率检查
2. **覆盖率分析**：生成报告 → 识别缺口 → 找关键路径 → 补充测试 → 验证提升
3. **E2E 测试搭建**：初始化 Playwright → 路由脚手架 → 配置认证夹具 → 运行测试 → 集成 CI

**覆盖率阈值配置（`jest.config.js`）**：
```javascript
coverageThreshold: {
  global: { branches: 80, functions: 80, lines: 80, statements: 80 }
}
```

**参考文档**：`testing_strategies.md`（测试金字塔、覆盖率目标）、`test_automation_patterns.md`（POM、Mock、夹具、异步测试）、`qa_best_practices.md`（测试命名、隔离性、Flaky 测试调试）

---

#### 6. `senior-devops` — 高级 DevOps 工程师

**触发场景**：CI/CD 管道搭建、基础设施自动化、Docker 容器化、Kubernetes 编排、部署自动化、监控配置

**三大工具**：

| 工具                      | 功能                                            |
| ------------------------- | ----------------------------------------------- |
| `pipeline_generator.py`   | 生成 CI/CD 管道配置（GitHub Actions、CircleCI） |
| `terraform_scaffolder.py` | 生成 Terraform IaC 模板                         |
| `deployment_manager.py`   | 管理部署流程（蓝绿、金丝雀）                    |

**技术栈**：Docker、Kubernetes、Terraform、GitHub Actions、CircleCI；AWS、GCP、Azure

**参考文档**：`cicd_pipeline_guide.md`、`infrastructure_as_code.md`、`deployment_strategies.md`（蓝绿/金丝雀部署）

---

#### 7. `senior-secops` — 高级安全运营工程师

**触发场景**（精确触发词）：CVE、CVSS、依赖审计、XSS/CSRF/注入、SOC2/PCI-DSS/HIPAA/GDPR、JWT/OAuth/MFA、SAST/DAST、安全事件、TLS/HSTS/CSP、容器安全

**三大工具**：

| 工具                        | 功能                                                  | 退出码                             |
| --------------------------- | ----------------------------------------------------- | ---------------------------------- |
| `security_scanner.py`       | 扫描硬编码密钥、SQL注入、XSS、命令注入、路径遍历      | 0=无高危，1=高危，2=严重           |
| `vulnerability_assessor.py` | 扫描 npm/Python/Go 依赖 CVE，输出 CVSS 分数和修复版本 | 同上                               |
| `compliance_checker.py`     | 验证 SOC2/PCI-DSS/HIPAA/GDPR 合规控制项               | 0=合规(90%+)，1=不合规，2=严重缺口 |

**四大工作流**：
1. **安全审计**：代码扫描 → 依赖漏洞 → 合规检查 → 综合报告
2. **CI/CD 安全门控**：GitHub Actions 集成，PR 触发自动安全扫描
3. **CVE 分级处置**：评估 → 优先级（Critical 24h / High 7d / Medium 30d / Low 90d）→ 修复 → 验证
4. **安全事件响应**：5阶段（检测识别 → 遏制 → 根除 → 恢复 → 事后复盘）

**OWASP Top 10 快速参考**：

| 排名 | 漏洞         | 防御措施                       |
| ---- | ------------ | ------------------------------ |
| A01  | 失效访问控制 | RBAC、默认拒绝、服务端权限验证 |
| A02  | 加密失败     | TLS 1.2+、AES-256、密钥管理    |
| A03  | 注入         | 参数化查询、输入验证、输出编码 |
| A07  | 认证失败     | MFA、限流、安全密码存储        |
| A10  | SSRF         | URL 验证、白名单目标、网络隔离 |

**参考文档**：`security_standards.md`、`vulnerability_management_guide.md`、`compliance_requirements.md`

---

#### 8. `code-reviewer` — 代码审查员

**支持语言**：Python(`.py`)、TypeScript(`.ts/.tsx`)、JavaScript(`.js/.jsx/.mjs`)、Go(`.go`)、Swift(`.swift`)、Kotlin(`.kt/.kts`)

**三大工具**：

| 工具                         | 功能                                                               | 输出                                                               |
| ---------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------ |
| `pr_analyzer.py`             | 分析 Git diff，识别风险（密钥、SQL注入、debug语句、any类型、TODO） | 复杂度 1-10 分、风险等级、文件优先级排序                           |
| `code_quality_checker.py`    | 检测代码结构问题、代码异味、SOLID原则违反                          | 检测超长函数(>50行)、大文件(>500行)、上帝类(>20方法)、深嵌套(>4层) |
| `review_report_generator.py` | 综合 PR 分析和质量分析，生成结构化审查报告                         | 审查意见（Approve/Request Changes/Block）、0-100分                 |

**审查分数裁定**：

| 分数                    | 意见                       |
| ----------------------- | -------------------------- |
| 90+ 且无高危问题        | ✅ Approve                  |
| 75+ 且至多 2 个高危问题 | 💡 Approve with suggestions |
| 50-74                   | 🔄 Request changes          |
| <50 或有严重问题        | 🚫 Block                    |

**参考文档**：`code_review_checklist.md`（审查清单）、`coding_standards.md`（多语言编码规范）、`common_antipatterns.md`（反模式目录，含修复建议）

---

#### 9. `senior-security` — 高级安全工程师

**触发词**：安全架构、威胁建模、STRIDE 分析、渗透测试、漏洞评估、OWASP、密码学实现、Zero Trust

**五大工作流**：
1. **威胁建模**：STRIDE 方法论 → DREAD 风险评分 → 缓解措施映射
2. **安全架构设计**：防御纵深分层 → Zero Trust 原则（验证每个请求、最小权限、假定已被攻破）→ 加密策略
3. **漏洞评估**：范围定义 → 信息收集 → 自动化扫描(SAST/DAST) → 手动测试 → 分级 → 修复计划
4. **安全代码审查**：自动化分析 → 审查认证/授权 → 数据处理 → 密码学使用 → 记录发现
5. **安全事件响应**：识别分流 → 遏制 → 根除 → 恢复 → 事后复盘 → 改进

**STRIDE 威胁矩阵**：

| 类别             | 安全属性   | 缓解重点           |
| ---------------- | ---------- | ------------------ |
| 欺骗 Spoofing    | 认证       | MFA、证书          |
| 篡改 Tampering   | 完整性     | 签名、校验和       |
| 否认 Repudiation | 不可否认性 | 审计日志、数字签名 |
| 信息泄露         | 机密性     | 加密、访问控制     |
| 拒绝服务 DoS     | 可用性     | 限流、冗余         |
| 权限提升         | 授权       | RBAC、最小权限     |

**推荐加密算法**：

| 用途     | 算法        | 密钥大小 |
| -------- | ----------- | -------- |
| 对称加密 | AES-256-GCM | 256 位   |
| 密码哈希 | Argon2id    | N/A      |
| 消息认证 | HMAC-SHA256 | 256 位   |
| 数字签名 | Ed25519     | 256 位   |
| TLS      | TLS 1.3     | —        |

**脚本工具**：`threat_modeler.py`（STRIDE + DREAD 威胁分析）、`secret_scanner.py`（检测 20+ 类密钥模式）

**参考文档**：`security-architecture-patterns.md`、`threat-modeling-guide.md`、`cryptography-implementation.md`

---

### 开发工具技能（2 个）

---

#### 12. `tdd-guide` — 测试驱动开发指南

**触发词**：生成测试、覆盖率分析、TDD 工作流、Red-Green-Refactor、Jest/Pytest/JUnit 测试、覆盖率报告

**能力矩阵**：

| 能力       | 说明                                             |
| ---------- | ------------------------------------------------ |
| 测试生成   | 将需求或代码转换为结构化测试用例                 |
| 覆盖率分析 | 解析 LCOV/JSON/XML 报告，优先填补关键缺口        |
| TDD 工作流 | 引导 Red-Green-Refactor 循环并验证               |
| 框架适配   | Jest、Pytest、JUnit、Vitest、Mocha               |
| 质量评分   | 评估测试隔离性、断言质量、命名规范、检测测试异味 |
| 夹具生成   | 创建测试数据、Mock 和工厂函数                    |

**八大脚本工具**：

| 脚本                    | 功能                     | 示例                                                                    |
| ----------------------- | ------------------------ | ----------------------------------------------------------------------- |
| `test_generator.py`     | 从代码/需求生成测试      | `python scripts/test_generator.py --input source.py --framework pytest` |
| `coverage_analyzer.py`  | 分析覆盖率报告           | `python scripts/coverage_analyzer.py --report lcov.info --threshold 80` |
| `tdd_workflow.py`       | 引导 Red-Green-Refactor  | `python scripts/tdd_workflow.py --phase red --test test_auth.py`        |
| `framework_adapter.py`  | 不同框架间转换测试       | `python scripts/framework_adapter.py --from jest --to pytest`           |
| `fixture_generator.py`  | 生成测试数据和 Mock      | `python scripts/fixture_generator.py --entity User --count 5`           |
| `metrics_calculator.py` | 计算测试质量指标         | `python scripts/metrics_calculator.py --tests tests/`                   |
| `format_detector.py`    | 检测语言和框架           | `python scripts/format_detector.py --file source.ts`                    |
| `output_formatter.py`   | 格式化为 CLI/CI 友好输出 | `python scripts/output_formatter.py --format markdown`                  |

**三大工作流**：
- **从代码生成测试**：提供源码 → 指定框架 → 运行 `test_generator.py` → 验证覆盖 Happy Path、错误、边界情况
- **覆盖率缺口分析**：生成报告 → `coverage_analyzer.py` 分析 → P0/P1/P2 优先级排序 → 补测 → 验证达标
- **TDD 新功能**：写失败测试（RED）→ 最小代码实现（GREEN）→ 重构保持绿色（REFACTOR）

---

### AI 技能（1 个）

---

#### 14. `senior-prompt-engineer` — 高级 Prompt 工程师

**触发场景**：优化 Prompt、设计 Prompt 模板、评估 LLM 输出、构建 Agent 系统、实现 RAG、创建 Few-Shot 示例、分析 Token 用量

**三大工具**：

| 工具                    | 功能                                               | 输出                                                    |
| ----------------------- | -------------------------------------------------- | ------------------------------------------------------- |
| `prompt_optimizer.py`   | 分析 Prompt Token 效率、清晰度、结构；生成优化版本 | Token 数、成本估算、清晰度评分、具体改进建议            |
| `rag_evaluator.py`      | 评估 RAG 检索质量和生成答案的忠实度                | Context Relevance、Faithfulness、Groundedness、问题诊断 |
| `agent_orchestrator.py` | 解析 Agent 配置，可视化执行流，验证工具            | ASCII 工作流图、Mermaid 图表、安全验证报告              |

**三大工作流**：
1. **Prompt 优化**：建立基线 → 识别问题（冗余、歧义、缺少约束）→ 应用优化模式 → 生成优化版 → 对比验证
2. **Few-Shot 示例设计**：定义任务 → 选择多样化示例（简单/边界/复杂/负面）→ 统一格式 → 验证质量 → 泛化测试
3. **结构化输出设计**：定义 JSON Schema → 在 Prompt 中包含 Schema → 添加格式强制说明 → 校验输出

**5 种核心 Prompt 模式速查**：

| 模式         | 适用场景               | 示例                                 |
| ------------ | ---------------------- | ------------------------------------ |
| Zero-shot    | 简单、定义明确的任务   | 「将此邮件分类为垃圾邮件或正常邮件」 |
| Few-shot     | 复杂任务、需要一致格式 | 提供 3-5 个示例                      |
| 思维链 (CoT) | 推理、数学、多步骤逻辑 | 「一步步思考...」                    |
| 角色扮演     | 需要专业视角           | 「你是一位资深税务顾问...」          |
| 结构化输出   | 需要可解析的 JSON/XML  | 包含 Schema + 格式强制要求           |

**参考文档**：`prompt_engineering_patterns.md`（10 种模式 + 示例）、`llm_evaluation_frameworks.md`（评估指标、A/B 测试）、`agentic_system_design.md`（ReAct、Plan-Execute、工具调用）

---

## 四、技能使用速查表

### 按需求选 Skill

| 需求                    | 推荐 Skill                |
| ----------------------- | ------------------------- |
| 设计系统架构            | `senior-architect`        |
| 构建 React/Next.js 应用 | `senior-frontend`         |
| 设计 REST/GraphQL API   | `senior-backend`          |
| 启动新全栈项目          | `senior-fullstack`        |
| 配置测试和覆盖率        | `senior-qa` + `tdd-guide` |
| 搭建 CI/CD 管道         | `senior-devops`           |
| 安全审计和漏洞管理      | `senior-secops`           |
| 威胁建模和渗透测试      | `senior-security`         |
| 代码审查自动化          | `code-reviewer`           |
| AWS 架构设计            | `aws-solution-architect`  |
| Office 365 管理         | `ms365-tenant-manager`    |
| 选型对比和 TCO 分析     | `tech-stack-evaluator`    |
| A/B 测试和统计分析      | `senior-data-scientist`   |
| ETL/数据湖管道构建      | `senior-data-engineer`    |
| ML 模型生产部署         | `senior-ml-engineer`      |
| LLM Prompt 优化和 RAG   | `senior-prompt-engineer`  |
| 计算机视觉系统          | `senior-computer-vision`  |
| 项目和任务管理          | `claude-simone`           |
| 节省 AI 对话 Token      | `token-optimization.md`   |

### 按团队规模推荐组合

| 团队规模           | 推荐技能组合                                                                                                             |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| Startup (5-10人)   | fullstack × 2 + data-scientist + devops + ml-engineer                                                                    |
| Scale-Up (10-25人) | architect + frontend × 2 + backend × 3 + data-engineer × 2 + data-scientist × 2 + ml-engineer × 2 + qa + devops + secops |
| Enterprise (25+人) | 全部 18 个技能                                                                                                           |

### 常用技能协作组合

| 场景             | 技能组合                                                          |
| ---------------- | ----------------------------------------------------------------- |
| 设计并构建新项目 | `senior-architect` + `senior-fullstack`                           |
| 安全部署         | `senior-devops` + `senior-secops`                                 |
| 构建并测试 API   | `senior-backend` + `senior-qa`                                    |
| 构建高质量 UI    | `senior-frontend` + `code-reviewer`                               |
| AI 功能开发      | `senior-ml-engineer` + `senior-prompt-engineer`                   |
| 计算机视觉产品   | `senior-computer-vision` + `senior-ml-engineer` + `senior-devops` |
| 数据科学基础设施 | `senior-data-engineer` + `senior-data-scientist`                  |
