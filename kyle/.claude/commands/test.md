# /test - 执行测试

对功能进行测试验证

## 使用方式
/test [功能名称或测试范围]

## 执行步骤

1. 确认测试目标和范围

1.5. **前置清理（有 cleanup 脚本的项目必须执行）**

从触发本次测试的贾维斯通知中读取 `repo` 字段，动态定位并执行该项目的 cleanup 脚本：

```
执行逻辑：
1. 读取 ../shared/notifications.json，找到触发本次测试的通知（from: jarvis, type: review_request）
2. 取出 content.repo 字段（项目本地路径，如 /Users/samhuang/dev/personal/clawborate）
3. 检查 {repo}/scripts/test-cleanup.sh 是否存在
   - 存在 → 执行：bash {repo}/scripts/test-cleanup.sh
   - 不存在 → 跳过，输出提示："项目未提供 cleanup 脚本，跳过前置清理"
```

> 各项目自行维护 `scripts/test-cleanup.sh`，cleanup 内容由项目决定，Kyle 不硬编码任何路径。

2. 设计测试用例：

### 正常流程测试
- 主要功能是否正常工作
- 预期输出是否正确

### 边界测试
- 空输入
- 超长输入
- 特殊字符
- 极限值

### 异常测试
- 网络异常
- 数据异常
- 权限异常
- 并发情况

### 安全测试
- XSS尝试
- SQL注入尝试
- 越权访问
- 敏感信息泄露

3. 执行测试并记录结果

4. 输出测试报告：
```markdown
# 测试报告 - [功能名称]

## 测试概览
| 项目 | 数值 |
|-----|------|
| 总用例 | X |
| 通过 | X |
| 失败 | X |
| 通过率 | X% |

## 失败用例详情
...

## 发现的问题
...
```

5. 存入 `../shared/reviews/` 并询问是否通知贾维斯
