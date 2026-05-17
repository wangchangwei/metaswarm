# 文档版本管理系统 - 交互流程

本文档描述文档版本管理系统的完整交互流程。

---

## 1. 整体流程概览

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           文档生命周期                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────┐     ┌─────────────┐     ┌─────────────┐     ┌───────────┐   │
│   │ PRD.md  │────▶│ Plan Review │────▶│Design Review│────▶│ Implementation│ │
│   │ 初始版  │     │    Gate     │     │    Gate     │     │   (4阶段)   │ │
│   └─────────┘     └─────────────┘     └─────────────┘     └───────────┘   │
│        │                  │                   │                   │          │
│        │                  ▼                   ▼                   │          │
│        │           ┌─────────────┐     ┌─────────────┐           │          │
│        │           │ docs/plans/ │     │docs/designs/│           │          │
│        │           │ v{VER}-plan│     │v{VER}-design│           │          │
│        │           └─────────────┘     └─────────────┘           │          │
│        │                  │                   │                   │          │
│        │                  │                   │                   ▼          │
│        │                  │                   │           ┌─────────────┐   │
│        │                  │                   │           │ PR Created  │   │
│        │                  │                   │           └─────────────┘   │
│        │                  │                   │                   │          │
│        │                  │                   │                   ▼          │
│        │                  │                   │           ┌─────────────┐   │
│        │                  │                   │           │PR Shepherd  │   │
│        │                  │                   │           │ (Monitor)   │   │
│        │                  │                   │           └─────────────┘   │
│        │                  │                   │                   │          │
│        │                  │                   │                   ▼          │
│        │                  │                   │           ┌─────────────┐   │
│        │                  │                   │           │   Merge     │   │
│        │                  │                   │           └─────────────┘   │
│        │                  │                   │                   │          │
│        ▼                  ▼                   ▼                   ▼          │
│   ┌─────────────────────────────────────────────────────────────┐         │
│   │                    PR Merge 后更新                            │         │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │         │
│   │  │PRD.md ✅ │  │SPEC.md ✅│  │CHANGELOG │  │ v{VER}.md│  │         │
│   │  │ 实时更新 │  │ 实时更新 │  │   ✅     │  │  新建   │  │         │
│   │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │         │
│   └─────────────────────────────────────────────────────────────┘         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. 文档类型说明

| 文档 | 类型 | 更新方式 | 用途 |
|------|------|----------|------|
| `PRD.md` | 实时文档 | PR merge 后追加 | 业务需求、用户故事、KPIs |
| `SPEC.md` | 实时文档 | PR merge 后追加 | 技术规格、API、数据模型 |
| `docs/plans/v{VER}-plan.md` | 快照 | 新建（不覆盖） | 历史实施计划 |
| `docs/designs/v{VER}-design.md` | 快照 | 新建（不覆盖） | 历史设计文档 |
| `docs/releases/v{VER}.md` | 快照 | 新建（不覆盖） | 版本详情 |
| `docs/releases/CHANGELOG.md` | 追加日志 | 追加 | 变更历史摘要 |

---

## 3. 交互流程详解

### 3.1 需求输入

**输入**：已有 PRD 需求文档

**操作**：
```
1. 将需求文档放到待处理目录（可选）
   docs/pending/your-feature.md

2. 或者直接开始任务
   /start-task 实现 xxx 功能
```

---

### 3.2 Plan Review Gate

**触发时机**：实施计划创建后

**操作**：运行 `/review-design` 或自动触发

**审查内容**：
- Feasibility Reviewer：技术可行性
- Completeness Reviewer：需求完整性
- Scope & Alignment Reviewer：范围一致性

**审查通过后**：
```bash
# 自动落地
docs/plans/v{VERSION}-plan.md  ← 新建快照
```

**关键点**：
- 审查不通过 → 返回修改 → 重新审查
- 最多 3 轮迭代

---

### 3.3 Design Review Gate

**触发时机**：Plan 审查通过后

**审查内容**：
- PM：用户案例验证
- Architect：技术架构
- Designer：UX/UI 设计
- Security：安全威胁建模
- CTO：TDD 就绪度

**审查通过后**：
```bash
# 自动落地
docs/designs/v{VERSION}-design.md  ← 新建快照
```

---

### 3.4 实施阶段（Orchestrated Execution）

**4 阶段循环**：
```
IMPLEMENT → VALIDATE → ADVERSARIAL REVIEW → COMMIT
```

**每阶段说明**：

| 阶段 | 操作 | 产出 |
|------|------|------|
| IMPLEMENT | Coder Agent 实现（TDD） | 代码 + 测试 |
| VALIDATE | Orchestrator 独立验证 | tsc/eslint/vitest 结果 |
| ADVERSARIAL REVIEW | 独立审查 Agent | DoD 合规性 |
| COMMIT | 提交到分支 | Git commit |

---

### 3.5 PR 创建与监控

**PR 创建后**：
```bash
/pr-shepherd <PR号>
```

**PR Shepherd 职责**：
- 监控 CI 状态
- 处理审查评论
- 修复 lint/type/测试问题
- 解决讨论线程

---

### 3.6 PR Merge（关键更新节点）

**PR 合并后，必须更新以下文档**：

```bash
# 1. 确定版本号
# 询问：变更类型是什么？
#   - Major (破坏性) → v2.0.0
#   - Minor (新功能) → v1.2.0
#   - Patch (修复) → v1.1.1

# 2. 创建版本详情快照
./scripts/create-version-doc.sh v1.2.0

# 3. 更新业务文档 PRD.md
./scripts/update-prd.sh v1.2.0 --feature "新功能A" --feature "新功能B"

# 4. 更新技术文档 SPEC.md
./scripts/update-spec.sh v1.2.0 --feature "新功能A"

# 5. 更新变更日志
./scripts/update-changelog.sh v1.2.0 --added "新功能A" --added "新功能B" --fixed "Bug X"

# 6. 提交所有更改
git add .
git commit -m "docs: update version docs for v1.2.0"
git push
```

---

## 4. 版本号管理

### 4.1 语义化版本 (Semver)

| 版本类型 | 适用场景 | 示例 |
|----------|----------|------|
| Major | 破坏性 API 变更 | v1.0.0 → v2.0.0 |
| Minor | 新功能（向后兼容） | v1.1.0 → v1.2.0 |
| Patch | Bug 修复（向后兼容） | v1.1.0 → v1.1.1 |

### 4.2 版本号计算

```bash
# 获取下一个 Minor 版本
./scripts/next-version.sh minor   # v1.1.0 → v1.2.0

# 获取下一个 Patch 版本
./scripts/next-version.sh patch   # v1.1.0 → v1.1.1

# 获取下一个 Major 版本
./scripts/next-version.sh major   # v1.1.0 → v2.0.0
```

---

## 5. 文档更新检查清单

### PR Merge 前必须完成

- [ ] 确定版本号
- [ ] `docs/plans/v{VERSION}-plan.md` 存在
- [ ] `docs/designs/v{VERSION}-design.md` 存在
- [ ] `docs/releases/v{VERSION}.md` 已创建
- [ ] `docs/releases/CHANGELOG.md` 已更新
- [ ] `docs/PRD.md` 已更新
- [ ] `docs/SPEC.md` 已更新
- [ ] 所有文档已提交

---

## 6. 文档查找指南

| 需要找什么？ | 去哪里找？ |
|--------------|------------|
| 当前产品需求 | `docs/PRD.md` |
| 当前技术规格 | `docs/SPEC.md` |
| 某个版本的需求 | `docs/plans/v{VERSION}-plan.md` |
| 某个版本的设计 | `docs/designs/v{VERSION}-design.md` |
| 某个版本的详情 | `docs/releases/v{VERSION}.md` |
| 变更历史 | `docs/releases/CHANGELOG.md` |
| 版本管理指南 | `docs/releases/VERSION-GUIDE.md` |

---

## 7. 流程参与者

| 角色 | 操作 |
|------|------|
| **产品经理** | 维护 PRD.md、提供需求 |
| **架构师** | 维护 SPEC.md、参与 Design Review |
| **开发者** | 执行 /start-task、实现功能、更新代码 |
| **审查 Agent** | Plan Review Gate、Design Review Gate |
| **PR Shepherd** | 监控 PR、处理评论、确保文档更新 |
| **系统** | 自动落地文档脚本 |

---

## 8. 常见问题

**Q: 如果我要修改现有功能，流程是什么？**
A: 和新功能一样，/start-task 会创建新的版本文档。

**Q: PRD 和 SPEC 会被覆盖吗？**
A: 不会。PRD 和 SPEC 是追加更新的，旧内容保留。只读不覆盖。

**Q: 如何查看某个版本的完整信息？**
A: `docs/releases/v{VERSION}.md` 包含该版本的所有快照引用。

**Q: 快照文档会越来越多吗？**
A: 是的，这是设计意图。快照保留了每个版本的历史，可追溯。

**Q: 如何清理旧快照？**
A: 目前不支持自动清理。如需清理，可手动归档到 `docs/archive/` 目录。
