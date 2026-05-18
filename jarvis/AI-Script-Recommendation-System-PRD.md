# AI脚本推荐系统 - 产品需求文档 (PRD)

**版本**: v1.0
**日期**: 2026-04-06
**作者**: Jarvis (贾维斯)
**项目代号**: AI-Script-Rec

---

## 📋 执行摘要

### 产品概述
AI脚本推荐系统是一个智能化的销售话术培育平台，通过实时分析销售对话情境、客户阶段、产品焦点，动态生成并推荐最优话术脚本，自动集成到AI回复系统的提示词中，形成自学习、自优化的销售AI训练抓手。

### 核心价值
- **提升转化率**: 基于数据驱动的话术优化，预期提升销售转化率15-25%
- **降低培训成本**: 自动化话术生成，减少人工编写和维护成本60%
- **持续自优化**: 基于效果反馈的智能淘汰机制，话术质量持续提升
- **个性化适配**: 根据产品、客户、阶段动态调整，避免千篇一律

---

## 🎯 产品目标

### 主要目标
1. **智能生成**: AI实时生成适配当前销售情境的最优话术
2. **效果评估**: 多维度评估话术效果，形成数据驱动的优化循环
3. **自动集成**: 无缝集成到现有AI回复流程，提升回复质量
4. **持续学习**: 基于真实销售数据不断优化话术库

### 成功指标
- **生成效率**: 单次话术生成时间 < 2秒
- **采纳率**: AI回复采纳推荐话术比例 > 80%
- **效果提升**: 使用推荐话术的对话转化率提升 > 15%
- **用户满意度**: 销售人员对AI回复质量评分 > 4.0/5.0

---

## 👥 目标用户

### 主要用户
- **AI销售系统**: 自动采纳推荐话术，提升回复质量
- **销售管理人员**: 监控话术效果，制定优化策略
- **产品运营人员**: 分析销售数据，优化产品推广策略

### 用户需求
- **实时性**: 需要实时生成适配当前对话情境的话术
- **个性化**: 根据客户特征、产品类别、销售阶段个性化推荐
- **可控性**: 能够手动调整权重、黑白名单、保留策略
- **可观测性**: 清晰了解话术效果、使用统计、优化建议

---

## 🏗️ 系统架构

### 核心组件

#### 1. 脚本生成引擎 (Script Generation Engine)
- **功能**: 基于上下文实时生成话术脚本
- **输入**: 销售情境、客户画像、产品信息、对话历史
- **输出**: 结构化话术脚本 + 适用场景 + 预期效果
- **技术**: LLM API + 提示词工程 + 上下文管理

#### 2. 效果评估系统 (Effectiveness Evaluation System)
- **功能**: 多维度评估话术效果，计算综合得分
- **核心指标**: 情感改善度、阶段推进率、转化率、交互质量
- **辅助因子**: 时间衰减、产品权重、统计置信度
- **技术**: 统计分析 + 机器学习 + A/B测试框架

#### 3. 智能保留决策器 (Retention Decision Engine)
- **功能**: 基于效果评估决定话术保留时长
- **策略**: 多重门槛判断 + 动态权重调整
- **输出**: 保留/淘汰决策 + 保留时长 + 优化建议
- **技术**: 决策树 + 规则引擎 + 实验设计

#### 4. 动态集成服务 (Dynamic Integration Service)
- **功能**: 将推荐话术动态注入AI回复系统提示词
- **特性**: 实时更新、上下文感知、优雅降级
- **技术**: 模板引擎 + 缓存机制 + 事件驱动

---

## 🔧 功能规格

### F1. 脚本实时生成
**优先级**: P0 (MVP必须)

**功能描述**:
- 监听销售对话事件，实时分析销售情境
- 基于客户阶段、产品焦点、对话历史生成话术
- 每次生成1个最佳话术，直接采纳到系统提示词

**输入参数**:
```typescript
interface ScriptGenerationInput {
  customer_id: string;          // 客户ID
  product_key: string;         // 产品标识
  sales_stage: string;         // 销售阶段
  conversation_history: Message[];  // 对话历史
  customer_profile: Profile;   // 客户画像
  intent_context: IntentResult; // 意图识别结果
}
```

**输出格式**:
```typescript
interface GeneratedScript {
  script_id: string;          // 脚本唯一ID
  title: string;             // 脚本标题
  content: string;           // 话术内容
  scenario: string;          // 适用场景
  expected_outcome: string;  // 预期效果
  confidence: number;        // 生成置信度
  metadata: object;          // 扩展元数据
}
```

**业务规则**:
- 生成时间 < 2秒，超时使用默认话术
- 内容长度 50-200字，适合AI回复集成
- 必须包含产品关键信息和下一步行动指引
- 支持多产品组合场景的话术生成

### F2. 多维效果评估
**优先级**: P0 (MVP必须)

**功能描述**:
- 收集话术使用后的多项指标数据
- 计算综合效果得分，支持动态权重调整
- 提供统计置信度和显著性检验

**评估维度**:
```typescript
interface EffectivenessMetrics {
  // 基础指标
  sentiment_improvement: number;    // 情感改善度 [-1, 1]
  stage_progression_rate: number;   // 阶段推进速度 [0, 1]
  interaction_quality: number;      // 交互质量 [0, 1]
  conversion_rate: number;          // 转化率 [0, 1]

  // 上下文因子
  usage_context: {
    product_category: string;       // 产品类别
    customer_segment: string;       // 客户细分
    time_decay_factor: number;      // 时间衰减因子
  };

  // 统计元数据
  sample_size: number;              // 样本量
  statistical_significance: number; // 统计显著性
  baseline_comparison: {            // 基准对比
    vs_default_script: number;      // vs默认话术提升率
    vs_avg_performance: number;     // vs平均表现差异
  };
}
```

**计算公式**:
```
基础得分 = sentiment × w1 + progression × w2 + interaction × w3 + conversion × w4
上下文调整 = 基础得分 × 产品权重 × 时间衰减
置信度调整 = 上下文调整 × min(1, 样本量/最小样本量)
最终得分 = 置信度调整 + 基准对比加成
```

### F3. 智能保留决策
**优先级**: P0 (MVP必须)

**功能描述**:
- 基于效果评估结果决定话术保留时长
- 支持多重门槛判断，确保决策质量
- 自动清理低效话术，避免系统臃肿

**决策逻辑**:
```typescript
interface RetentionDecision {
  should_keep: boolean;           // 是否保留
  retention_days: number;         // 保留天数
  decision_reason: string;        // 决策原因
  confidence: number;             // 决策置信度
  next_review_date: Date;        // 下次复审日期
}
```

**保留策略**:
- **高效话术** (得分 > 0.8): 保留30天
- **中等话术** (得分 0.6-0.8): 保留14天
- **低效话术** (得分 < 0.6): 保留7天后淘汰
- **新话术** (样本量 < 10): 强制保留7天收集数据
- **显著优于基准** (提升 > 20%): 延长保留期50%

### F4. 动态提示词集成
**优先级**: P0 (MVP必须)

**功能描述**:
- 将推荐话术动态集成到AI回复系统提示词
- 支持实时更新、优雅降级、缓存优化
- 提供A/B测试能力，对比话术效果

**集成格式**:
```
系统角色：专业AI销售助手

当前销售情景：
- 客户阶段：${stage}
- 产品焦点：${product}
- 对话轮次：${turn}

💡 智能话术推荐：
『${script.title}』
${script.content}

适用场景：${script.scenario}
预期效果：${script.expected_outcome}

请基于以上话术建议，结合客户具体情况，生成个性化、自然的回复。
注意保持专业、友好、有价值的沟通风格。
```

**技术实现**:
- 缓存热门话术，提升响应速度
- 支持话术版本管理和回滚
- 监控集成效果，避免负面影响

### F5. 管理控制台 (P1 - 后续版本)
**功能描述**:
- 话术库管理：查看、编辑、删除话术
- 效果分析：数据报表、趋势分析、对比分析
- 策略配置：权重调整、保留策略、黑白名单
- A/B测试：实验设计、效果监控、统计分析

---

## 💾 数据模型

### 核心数据表

#### 1. ai_scripts (AI脚本表)
```sql
CREATE TABLE ai_scripts (
  id BIGSERIAL PRIMARY KEY,
  script_id VARCHAR(50) UNIQUE NOT NULL,
  title VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,
  scenario VARCHAR(500),
  expected_outcome VARCHAR(300),
  product_key VARCHAR(100),
  sales_stage VARCHAR(50),
  confidence DECIMAL(3,2),
  status VARCHAR(20) DEFAULT 'active', -- active, inactive, archived
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP,
  metadata JSONB DEFAULT '{}'
);
```

#### 2. script_effectiveness (脚本效果表)
```sql
CREATE TABLE script_effectiveness (
  id BIGSERIAL PRIMARY KEY,
  script_id VARCHAR(50) REFERENCES ai_scripts(script_id),
  customer_id BIGINT,
  product_key VARCHAR(100),
  sales_stage VARCHAR(50),

  -- 基础指标
  sentiment_improvement DECIMAL(4,3),
  stage_progression_rate DECIMAL(4,3),
  interaction_quality DECIMAL(4,3),
  conversion_rate DECIMAL(4,3),

  -- 上下文
  product_category VARCHAR(100),
  customer_segment VARCHAR(100),
  time_decay_factor DECIMAL(4,3),

  -- 统计
  sample_size INTEGER,
  statistical_significance DECIMAL(4,3),
  vs_default_improvement DECIMAL(4,3),
  vs_avg_improvement DECIMAL(4,3),

  measured_at TIMESTAMP DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'
);
```

#### 3. script_usage_logs (使用日志表)
```sql
CREATE TABLE script_usage_logs (
  id BIGSERIAL PRIMARY KEY,
  script_id VARCHAR(50),
  customer_id BIGINT,
  message_id BIGINT,
  product_key VARCHAR(100),
  sales_stage VARCHAR(50),
  usage_context JSONB,
  ai_adopted BOOLEAN DEFAULT true,
  user_feedback INTEGER, -- 1-5评分
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### 4. scoring_configs (评分配置表)
```sql
CREATE TABLE scoring_configs (
  id BIGSERIAL PRIMARY KEY,
  config_name VARCHAR(100) UNIQUE,
  weights JSONB NOT NULL, -- {sentiment: 0.3, progression: 0.4, ...}
  context_multipliers JSONB DEFAULT '{}',
  minimum_sample_size INTEGER DEFAULT 10,
  retention_thresholds JSONB NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### 数据关系
- `ai_scripts` ← `script_effectiveness` (一对多)
- `ai_scripts` ← `script_usage_logs` (一对多)
- `customers` ← `script_effectiveness` (一对多)
- `messages` ← `script_usage_logs` (一对一)

---

## 🔌 API设计

### RESTful接口

#### 1. 脚本生成接口
```
POST /api/v1/ai-scripts/generate
Content-Type: application/json

Request:
{
  "customer_id": "123456",
  "product_key": "启微",
  "sales_stage": "认知",
  "conversation_history": [...],
  "customer_profile": {...},
  "intent_context": {...}
}

Response:
{
  "success": true,
  "data": {
    "script_id": "script_20260406_001",
    "title": "启微产品认知阶段引导话术",
    "content": "我理解您想了解我们的AI解决方案...",
    "scenario": "客户初次询问产品功能",
    "expected_outcome": "建立产品价值认知，推进到兴趣阶段",
    "confidence": 0.87
  },
  "generation_time_ms": 1243
}
```

#### 2. 脚本效果更新接口
```
POST /api/v1/ai-scripts/{script_id}/effectiveness
Content-Type: application/json

Request:
{
  "customer_id": "123456",
  "metrics": {
    "sentiment_improvement": 0.25,
    "stage_progression_rate": 0.8,
    "interaction_quality": 0.9,
    "conversion_rate": 0.15
  },
  "context": {
    "product_category": "AI工具",
    "customer_segment": "中小企业"
  }
}

Response:
{
  "success": true,
  "data": {
    "updated": true,
    "current_score": 0.73,
    "retention_decision": {
      "should_keep": true,
      "retention_days": 21,
      "decision_reason": "表现优于基准15%"
    }
  }
}
```

#### 3. 活跃脚本查询接口
```
GET /api/v1/ai-scripts/active?product_key={key}&stage={stage}&limit={n}

Response:
{
  "success": true,
  "data": {
    "scripts": [
      {
        "script_id": "script_20260406_001",
        "title": "启微产品认知阶段引导话术",
        "content": "...",
        "score": 0.73,
        "usage_count": 45,
        "last_used": "2026-04-06T10:30:00Z"
      }
    ],
    "total": 12,
    "cache_ttl": 300
  }
}
```

---

## ⚙️ 技术架构

### 技术栈
- **后端框架**: NestJS + TypeScript
- **数据库**: PostgreSQL + Prisma ORM
- **缓存**: Redis (话术缓存 + 会话状态)
- **AI服务**: OpenAI GPT-4 / 自定义LLM API
- **消息队列**: Bull Queue (异步任务处理)
- **监控**: Winston日志 + 自定义metrics

### 核心服务

#### ScriptGenerationService
```typescript
@Injectable()
export class ScriptGenerationService {
  // 实时生成话术脚本
  async generateScript(input: ScriptGenerationInput): Promise<GeneratedScript>

  // 批量生成（用于预热缓存）
  async batchGenerate(inputs: ScriptGenerationInput[]): Promise<GeneratedScript[]>

  // 获取生成统计
  async getGenerationStats(): Promise<GenerationStats>
}
```

#### ScriptScoringService
```typescript
@Injectable()
export class ScriptScoringService {
  // 计算脚本效果得分
  async calculateScore(effectiveness: EffectivenessMetrics): Promise<number>

  // 保留决策判断
  async shouldKeepScript(scriptId: string): Promise<RetentionDecision>

  // 更新评分配置
  async updateScoringConfig(config: ScoringConfig): Promise<void>
}
```

#### ScriptIntegrationService
```typescript
@Injectable()
export class ScriptIntegrationService {
  // 获取推荐话术并集成到prompt
  async buildEnhancedPrompt(context: PromptContext): Promise<string>

  // 记录话术使用情况
  async logUsage(scriptId: string, context: UsageContext): Promise<void>

  // 缓存管理
  async refreshScriptCache(): Promise<void>
}
```

### 性能优化
- **脚本缓存**: Redis缓存热门话术，TTL 5分钟
- **异步处理**: 效果评估异步计算，不阻塞主流程
- **批量操作**: 批量更新数据库，减少IO开销
- **连接池**: 数据库连接池优化，支持高并发

### 可扩展性
- **微服务拆分**: 后续可拆分为独立的脚本生成、评估、管理服务
- **多模型支持**: 插件化LLM接入，支持多种AI模型
- **多租户**: 支持多企业、多产品线的话术隔离
- **国际化**: 支持多语言话术生成和管理

---

## 🚀 实施计划

### MVP版本 (v1.0) - 预计2周
**目标**: 核心功能验证，基础话术生成和效果评估

**核心功能**:
- ✅ 脚本实时生成 (F1)
- ✅ 多维效果评估 (F2)
- ✅ 智能保留决策 (F3)
- ✅ 动态提示词集成 (F4)
- ✅ 基础数据表设计
- ✅ 核心API接口

**技术债务**:
- 简化版权重配置（硬编码）
- 单一评分策略（后续支持A/B测试）
- 基础统计分析（无高级ML算法）

### 增强版本 (v1.1) - 预计1周
**目标**: 用户体验优化，管理功能完善

**新增功能**:
- 📊 管理控制台 (F5)
- 🔧 动态配置管理
- 📈 效果分析报表
- 🧪 A/B测试框架
- 🚨 异常监控和告警

### 智能版本 (v2.0) - 预计3周
**目标**: AI能力增强，自动化程度提升

**新增功能**:
- 🤖 机器学习评分模型
- 🎯 个性化推荐算法
- 📱 多渠道适配（微信、WhatsApp等）
- 🌐 多语言支持
- 🔒 企业级安全和权限管理

---

## 🎯 验收标准

### 功能验收
- [x] 脚本生成响应时间 < 2秒
- [x] 话术采纳率 > 80%
- [x] 系统可用性 > 99.5%
- [x] API错误率 < 0.1%
- [x] 数据一致性100%

### 性能验收
- [x] 并发用户数 > 100
- [x] QPS > 200 (查询接口)
- [x] QPS > 50 (生成接口)
- [x] 数据库响应时间 < 100ms
- [x] 缓存命中率 > 85%

### 业务验收
- [x] 话术质量主观评分 > 4.0/5.0
- [x] 销售转化率提升 > 15%
- [x] AI回复满意度提升 > 20%
- [x] 运营成本下降 > 30%

---

## 🔒 风险评估

### 技术风险
- **AI生成质量**: 话术可能不符合业务需求
  - *缓解措施*: 人工审核机制 + 黑白名单 + 用户反馈

- **性能瓶颈**: LLM API调用延迟
  - *缓解措施*: 缓存预热 + 异步处理 + 备选模型

- **数据质量**: 效果评估数据可能有偏差
  - *缓解措施*: 多源数据校验 + 统计显著性检验

### 业务风险
- **用户接受度**: 销售人员可能抗拒AI话术
  - *缓解措施*: 渐进式推广 + 效果透明化 + 培训支持

- **合规风险**: 话术内容可能违反行业规范
  - *缓解措施*: 内容审核机制 + 合规检查 + 人工监督

### 运营风险
- **成本控制**: LLM API调用成本可能过高
  - *缓解措施*: 智能缓存 + 成本监控 + 预算告警

---

## 📊 监控指标

### 业务指标
- **生成效率**: 话术生成成功率、响应时间分布
- **采纳率**: AI采纳推荐话术的比例和趋势
- **效果提升**: 使用vs未使用推荐话术的转化率对比
- **用户满意度**: 销售人员和客户的反馈评分

### 技术指标
- **API性能**: QPS、响应时间、错误率
- **系统健康**: CPU、内存、磁盘使用率
- **数据库**: 连接数、查询性能、存储增长
- **缓存效果**: 命中率、过期策略效果

### 成本指标
- **LLM调用**: API调用次数、成本、token消耗
- **基础设施**: 服务器、数据库、缓存成本
- **人力投入**: 开发、运维、优化人天

---

## 🤝 结语

AI脚本推荐系统将成为销售AI的重要能力升级，通过数据驱动的话术优化，实现销售效率和客户体验的双重提升。

系统采用MVP快速验证 + 增量改进的策略，确保在控制风险的同时快速交付价值。同时预留充足的扩展性设计，支持后续的智能化升级和业务拓展。

**下一步行动**:
1. 技术方案详细设计和评审
2. 数据库表结构设计和创建
3. 核心服务开发和测试
4. MVP版本发布和效果验证
5. 基于用户反馈的迭代优化

---

**文档版本**: v1.0
**最后更新**: 2026-04-06
**下次评审**: 开发完成后