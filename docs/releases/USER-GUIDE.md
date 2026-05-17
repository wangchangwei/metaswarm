# 用户指南 - 文档版本管理系统

本文档帮助你快速上手文档版本管理系统。

---

## 快速索引

| 场景 | 去哪里 |
|------|--------|
| 我是新人，第一步做什么 | → [第 1 节：首次使用](#1-首次使用) |
| 我要开始一个新功能 | → [第 2 节：开始新功能](#2-开始新功能) |
| 我要查看当前产品需求 | → [第 3 节：查看文档](#3-查看文档) |
| 我的 PR 合并了，接下来做什么 | → [第 4 节：pr-merge-后续操作](#4-pr-merge-后续操作) |
| 我想了解版本号规则 | → [第 5 节：版本号管理](#5-版本号管理) |
| 遇到问题了 | → [第 6 节：常见问题](#6-常见问题) |

---

## 1. 首次使用

### 第一步：检查当前状态

```bash
# 查看当前文档
cat docs/PRD.md      # 业务需求
cat docs/SPEC.md     # 技术规格

# 查看当前版本
grep "Current Version" docs/PRD.md
grep "Current Version" docs/SPEC.md

# 查看变更历史
cat docs/releases/CHANGELOG.md
```

### 第二步：了解项目结构

```
docs/
├── PRD.md              # 业务需求（你在这里找需求）
├── SPEC.md             # 技术规格（你在这里找技术细节）
├── plans/              # 历史实施计划
├── designs/            # 历史设计文档
└── releases/
    ├── CHANGELOG.md   # 变更日志
    ├── DOCUMENT-FLOW.md # 本文档
    └── VERSION-GUIDE.md # 版本管理指南
```

### 第三步：如果是新项目

```bash
# 1. 初始化版本
echo "v0.1.0" > version.txt

# 2. 更新 PRD.md
./scripts/update-prd.sh v0.1.0 --feature "初始功能"

# 3. 更新 SPEC.md
./scripts/update-spec.sh v0.1.0 --feature "初始功能"

# 4. 提交
git add .
git commit -m "docs: initialize v0.1.0"
```

---

## 2. 开始新功能

### 场景 A：我有需求文档

```
1. 把需求文档放到 docs/pending/your-feature.md

2. 开始任务
   /start-task 实现 xxx 功能

3. 系统会自动：
   - 创建 Plan → Plan Review Gate 审查
   - 审查通过后落地到 docs/plans/v{VERSION}-plan.md
   - 创建 Design → Design Review Gate 审查
   - 审查通过后落地到 docs/designs/v{VERSION}-design.md
   - 开始实施
   - PR 创建后由 PR Shepherd 监控

4. PR 合并后（见第 4 节）
```

### 场景 B：我有 GitHub Issue

```
1. 开始任务
   /start-task #123

2. 系统会加载 Issue 内容

3. 后续流程同场景 A
```

### 场景 C：我想直接开始

```
1. 描述你想要的功能
   /start-task 实现用户登录功能，包括注册、登录、登出

2. 系统会引导你完成后续流程
```

---

## 3. 查看文档

### 查看当前产品需求

```bash
# 查看完整 PRD
cat docs/PRD.md

# 查看特定部分
grep -A 10 "## 4. User Stories" docs/PRD.md
```

### 查看当前技术规格

```bash
# 查看完整 SPEC
cat docs/SPEC.md

# 查看特定部分
grep -A 10 "## API Reference" docs/SPEC.md
```

### 查看某个版本的历史

```bash
# 查看 v1.2.0 的计划
cat docs/plans/v1.2.0-plan.md

# 查看 v1.2.0 的设计
cat docs/designs/v1.2.0-design.md

# 查看 v1.2.0 的详情
cat docs/releases/v1.2.0.md
```

### 查看变更历史

```bash
# 查看所有变更
cat docs/releases/CHANGELOG.md

# 查看特定版本的变更
grep -A 5 "## \[v1.2.0\]" docs/releases/CHANGELOG.md
```

---

## 4. PR Merge 后续操作

**重要：PR 合并后，必须执行以下操作**

### 第一步：确定版本号

```bash
# 询问：这次变更是什么类型？
# - 大版本 (破坏性变更): ./scripts/next-version.sh major  → v2.0.0
# - 小版本 (新功能):   ./scripts/next-version.sh minor  → v1.2.0
# - 补丁版本 (Bug修复): ./scripts/next-version.sh patch  → v1.1.1
```

### 第二步：更新文档

```bash
# 1. 创建版本详情
./scripts/create-version-doc.sh v1.2.0

# 2. 更新 PRD（业务文档）
./scripts/update-prd.sh v1.2.0 --feature "新功能A" --feature "新功能B"

# 3. 更新 SPEC（技术文档）
./scripts/update-spec.sh v1.2.0 --feature "新功能A"

# 4. 更新变更日志
./scripts/update-changelog.sh v1.2.0 \
  --added "新功能A" \
  --added "新功能B" \
  --fixed "Bug X"
```

### 第三步：提交更改

```bash
git add .
git commit -m "docs: update version docs for v1.2.0"
git push
```

### 检查清单

- [ ] 版本号已确定
- [ ] `docs/releases/v{VERSION}.md` 已创建
- [ ] `docs/PRD.md` 已更新
- [ ] `docs/SPEC.md` 已更新
- [ ] `docs/releases/CHANGELOG.md` 已更新
- [ ] 所有更改已提交

---

## 5. 版本号管理

### 版本号规则 (Semver)

| 格式 | 说明 | 例子 |
|------|------|------|
| `vMAJOR.MINOR.PATCH` | 主版本.次版本.补丁版本 | v1.2.3 |

| 版本类型 | 何时使用 | 例子 |
|----------|----------|------|
| **Major** | 破坏性变更 | v1.2.3 → v2.0.0 |
| **Minor** | 新功能（向后兼容） | v1.2.3 → v1.3.0 |
| **Patch** | Bug 修复（向后兼容） | v1.2.3 → v1.2.4 |

### 快速命令

```bash
# 获取下一个版本号
./scripts/next-version.sh minor   # 假设当前 v1.1.0 → 输出 v1.2.0
./scripts/next-version.sh patch   # 假设当前 v1.1.0 → 输出 v1.1.1
./scripts/next-version.sh major   # 假设当前 v1.1.0 → 输出 v2.0.0

# 创建版本文档
./scripts/create-version-doc.sh v1.2.0

# 更新 PRD
./scripts/update-prd.sh v1.2.0 --feature "功能名"

# 更新 SPEC
./scripts/update-spec.sh v1.2.0 --feature "功能名"

# 更新 CHANGELOG
./scripts/update-changelog.sh v1.2.0 --added "功能" --fixed "修复"
```

---

## 6. 常见问题

### Q1: PRD.md 和 SPEC.md 有什么区别？

| 文档 | 内容 | 受众 |
|------|------|------|
| **PRD.md** | 用户故事、业务目标、KPIs、User Flow | 产品经理、业务方 |
| **SPEC.md** | API、数据模型、架构、环境变量 | 开发者、架构师 |

### Q2: 为什么有的是快照，有的是实时更新？

| 类型 | 文档 | 说明 |
|------|------|------|
| **实时更新** | PRD.md, SPEC.md | PR 合并后追加，始终代表最新状态 |
| **快照** | plans/v{VER}-*.md, designs/v{VER}-*.md, releases/v{VER}.md | 每个版本一个文件，保留历史 |

### Q3: 我能修改历史快照吗？

**不建议**。快照保留历史，用于追溯。修改实时文档（PRD.md, SPEC.md）即可影响当前状态。

### Q4: 如果我忘了在 PR 合并后更新文档怎么办？

```bash
# 随时可以补更新
./scripts/update-prd.sh v1.2.0 --feature "功能名"
./scripts/update-spec.sh v1.2.0 --feature "功能名"
./scripts/update-changelog.sh v1.2.0 --added "功能"

git add .
git commit -m "docs: update missed version docs for v1.2.0"
```

### Q5: 如何查看某个功能是哪个版本添加的？

```bash
# 方法 1: 查看 PRD 的变更历史
grep "功能名" docs/PRD.md

# 方法 2: 查看 CHANGELOG
grep "功能名" docs/releases/CHANGELOG.md

# 方法 3: 查看特定版本
grep -r "功能名" docs/plans/
grep -r "功能名" docs/designs/
```

### Q6: 多个 PR 同时合并，版本号怎么定？

```bash
# 方案 1: 分别版本（各自独立）
./scripts/next-version.sh minor  # PR1 → v1.2.0
./scripts/next-version.sh minor  # PR2 → v1.3.0

# 方案 2: 合并后一起发版
# 先合并的 PR 用小版本，后合并的用大版本
```

---

## 7. 速查表

### 日常操作

| 操作 | 命令 |
|------|------|
| 查看当前 PRD | `cat docs/PRD.md` |
| 查看当前 SPEC | `cat docs/SPEC.md` |
| 查看当前版本 | `grep "Current Version" docs/PRD.md` |
| 查看变更历史 | `cat docs/releases/CHANGELOG.md` |
| 开始新功能 | `/start-task 实现 xxx` |
| 审查设计 | `/review-design docs/plans/xxx.md` |
| 监控 PR | `/pr-shepherd <PR号>` |

### 版本操作

| 操作 | 命令 |
|------|------|
| 下一个 Minor 版本 | `./scripts/next-version.sh minor` |
| 下一个 Patch 版本 | `./scripts/next-version.sh patch` |
| 下一个 Major 版本 | `./scripts/next-version.sh major` |
| 创建版本文档 | `./scripts/create-version-doc.sh v1.2.0` |
| 更新 PRD | `./scripts/update-prd.sh v1.2.0 --feature "xxx"` |
| 更新 SPEC | `./scripts/update-spec.sh v1.2.0 --feature "xxx"` |
| 更新 CHANGELOG | `./scripts/update-changelog.sh v1.2.0 --added "xxx"` |

---

## 8. 相关文档

| 文档 | 说明 |
|------|------|
| `docs/releases/DOCUMENT-FLOW.md` | 完整交互流程图 |
| `docs/releases/VERSION-GUIDE.md` | 版本管理详细指南 |
| `docs/releases/CHANGELOG.md` | 变更日志 |
| `docs/PRD.md` | 当前业务需求 |
| `docs/SPEC.md` | 当前技术规格 |
