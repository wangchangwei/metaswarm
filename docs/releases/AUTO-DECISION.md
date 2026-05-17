# 智能阈值决策系统

当 AI 提供多个选项时，对每个选项进行打分。如果推荐选项的分数 >= 阈值（默认 8/10），则自动执行，不再询问用户。

---

## 1. 评分体系

### 评分维度

| 维度 | 权重 | 说明 |
|------|------|------|
| **安全性** | 30% | 风险越低分数越高（已测试、无破坏性） |
| **复杂性** | 20% | 越简单分数越高 |
| **效率** | 20% | 时间/资源消耗越少分数越高 |
| **用户匹配度** | 20% | 基于历史选择的学习 |
| **推荐优先级** | 10% | AI 的原始推荐程度 |

### 分数计算

```
最终分数 = Σ(维度分数 × 权重)
```

### 分数等级

| 分数 | 等级 | 行为 |
|------|------|------|
| 9-10 | 强烈推荐 | 自动执行 |
| 7-8 | 推荐 | 自动执行 |
| 5-6 | 中立 | 询问确认 |
| 3-4 | 不推荐 | 询问确认 |
| 1-2 | 强烈不推荐 | 强烈建议询问 |

---

## 2. 选项展示格式

### 当前格式（无评分）

```
请选择执行方式：
1. Orchestrated Execution
2. Subagent Development
3. Parallel Session
```

### 新格式（带评分）

```
请选择执行方式：

┌─────────────────────────────────────────────────────────────┐
│  1. Orchestrated Execution                          [8.5] │
│     ✓ 经过验证的流程  ✓ 100%覆盖率  ✓ 完整审查     自动执行 │
│     预估时间: 2-3小时                                       │
├─────────────────────────────────────────────────────────────┤
│  2. Subagent Development                            [7.2] │
│     ✓ 速度快  ✓ 灵活度高  ✗ 覆盖率略低             建议执行 │
│     预估时间: 1-2小时                                       │
├─────────────────────────────────────────────────────────────┤
│  3. Parallel Session                                 [6.1] │
│     ✓ 隔离性好  ✗ 协调复杂  ✗ 上下文丢失风险       询问确认 │
│     预估时间: 2-3小时                                       │
└─────────────────────────────────────────────────────────────┘

推荐选项: 1 (8.5分 ≥ 阈值8分)
状态: ⏩ 自动执行中...
```

---

## 3. 交互流程

### 场景 1：分数 >= 阈值

```
AI: 推荐选项 1 (8.5分 ≥ 阈值8分)
系统: 自动执行，不询问
```

### 场景 2：分数 < 阈值

```
AI: 推荐选项 3 (6.1分 < 阈值8分)
系统: 请选择:
[1] 选项1 (手动选择)
[2] 选项2 (手动选择)
[3] 选项3 (手动选择)
[4] 接受推荐 (即使分数较低)
>
```

### 场景 3：用户自定义选择

```
AI: 推荐选项 2 (7.2分)
系统: 请选择:
[1] 选项1 (分数: 8.5)
[2] 选项2 (分数: 7.2) ← 接受推荐
[3] 选项3 (分数: 6.1)
>
> 2
系统: 您选择了选项2
```

---

## 4. 阈值配置

### 默认配置

```yaml
# .metaswarm/config.yaml
decision:
  threshold: 8.0              # 默认阈值 8/10
  auto_execute_above_threshold: true  # 高于阈值自动执行
  show_detailed_scores: true         # 显示详细分数
  learning_enabled: true             # 启用学习
```

### 用户自定义阈值

```
# 设置阈值为 9
/set-threshold 9

# 查看当前阈值
/show-threshold
当前阈值: 9.0
```

---

## 5. 学习机制

### 记录用户选择

系统会记录用户的历史选择：

```json
{
  "user_choices": [
    {"option": "orchestrated", "score": 8.5, "chosen": true},
    {"option": "subagent", "score": 7.2, "chosen": false},
    {"option": "parallel", "score": 6.1, "chosen": false}
  ],
  "pattern": "user_always_chooses_orchestrated"
}
```

### 调整分数

如果用户总是选择某个选项，即使分数较低：

```
用户历史: 80% 选择 Orchestrated
调整: Orchestrated 分数 +0.5（用户匹配度提高）
```

### 学习规则

| 行为 | 调整 |
|------|------|
| 用户总选 A | A 的用户匹配度分数 +0.5 |
| 用户从不选 B | B 的用户匹配度分数 -0.3 |
| 用户跳过推荐选其他 | 推荐分数阈值提高 0.5 |

---

## 6. 实现代码

### 评分函数

```typescript
interface Option {
  id: string
  name: string
  safety: number      // 1-10
  complexity: number   // 1-10 (inverse: 简单=高分)
  efficiency: number   // 1-10
  ai_priority: number // 1-10
  user_match: number  // 1-10 (learned)
}

const WEIGHTS = {
  safety: 0.30,
  complexity: 0.20,
  efficiency: 0.20,
  user_match: 0.20,
  ai_priority: 0.10
}

function calculateScore(option: Option): number {
  const complexityScore = 11 - option.complexity // Inverse

  return (
    option.safety * WEIGHTS.safety +
    complexityScore * WEIGHTS.complexity +
    option.efficiency * WEIGHTS.efficiency +
    option.user_match * WEIGHTS.user_match +
    option.ai_priority * WEIGHTS.ai_priority
  )
}

function shouldAutoExecute(score: number, threshold: number): boolean {
  return score >= threshold
}
```

### 格式化输出

```typescript
function formatOptions(options: Option[], scores: Map<string, number>, threshold: number) {
  const bestOption = scores.entries()
    .sort((a, b) => b[1] - a[1])
    .next().value

  let output = "请选择执行方式：\n\n"

  for (const option of options) {
    const score = scores.get(option.id)
    const status = score >= threshold ? "✅ 自动执行" : "⏸ 询问确认"
    const badge = getScoreBadge(score)

    output += `┌─────────────────────────────────────────────────────────────┐\n`
    output += `│  ${option.id}. ${option.name.padEnd(50)} [${score.toFixed(1)}] │\n`
    output += `│     ${option.pros.join("  ")}     ${status}\n`
    output += `│     ${option.cons.join("  ")}\n`
    output += `│     预估时间: ${option.estimate}\n`
    output += `└─────────────────────────────────────────────────────────────┘\n`
  }

  output += `\n推荐选项: ${bestOption[0]} (${bestOption[1].toFixed(1)}分 ${bestOption[1] >= threshold ? "≥" : "<"} 阈值${threshold}分)\n`

  return output
}
```

---

## 7. 配置示例

### .metaswarm/config.yaml

```yaml
decision:
  # 阈值配置
  threshold: 8.0
  auto_execute_above_threshold: true

  # 显示配置
  show_detailed_scores: true
  show_reasoning: true

  # 学习配置
  learning_enabled: true
  learning_decay: 0.95  # 历史权重衰减

  # 调试
  verbose_logging: false
```

### 环境变量

```bash
export METASWARM_THRESHOLD=8.0
export METASWARM_AUTO_EXECUTE=true
```

---

## 8. 命令

| 命令 | 说明 |
|------|------|
| `/set-threshold 9` | 设置阈值为 9 |
| `/show-threshold` | 查看当前阈值 |
| `/show-scores` | 显示最近评分详情 |
| `/reset-learning` | 重置学习历史 |
| `/decision-config` | 查看决策配置 |

---

## 9. 示例场景

### 场景 1：Plan Review Gate 通过

```
┌─────────────────────────────────────────────────────────────┐
│  Plan Review Gate                                    [9.2] │
│     ✓ 3/3 审查者通过  ✓ 无阻塞问题  ✓ 范围清晰   自动执行 │
│     审查迭代: 1次                                          │
├─────────────────────────────────────────────────────────────┤
│  继续执行                                                [7.5] │
│     优点: 直接继续                                        │
│     缺点: 跳过用户确认                                    │
└─────────────────────────────────────────────────────────────┘

推荐选项: 1 (9.2分 ≥ 阈值8分)
状态: ⏩ 自动继续到 Design Review Gate...
```

### 场景 2：Human Checkpoint

```
┌─────────────────────────────────────────────────────────────┐
│  数据库 Schema 设计完成                              [8.3] │
│     ✓ 遵循现有模式  ✓ 类型安全  ⚠ 涉及迁移       建议执行 │
│     预估时间: 5分钟                                        │
├─────────────────────────────────────────────────────────────┤
│  暂停确认                                              [6.0] │
│     优点: 确保方向正确                                    │
│     缺点: 需等待人工确认                                  │
└─────────────────────────────────────────────────────────────┘

推荐选项: 1 (8.3分 ≥ 阈值8分)
状态: ⏩ 自动继续实现...
```

---

## 10. 阈值建议

| 使用场景 | 推荐阈值 |
|----------|----------|
| 高风险生产环境 | 9.0+ |
| 标准开发 | 8.0 |
| 快速原型 | 7.0 |
| 实验性项目 | 6.0 |

---

## 11. 注意事项

1. **安全性优先**：低于 5 分的选项永远询问
2. **可覆盖**：用户可以随时强制选择低分选项
3. **透明性**：始终显示分数和原因
4. **学习**：尊重用户习惯，但不盲从
