# 一键启动 - 客户管理系统开发

本文档描述如何一键启动客户管理系统的完整开发流程。

---

## 启动命令

```
/start-task 实现一个客户管理系统，采用 Node.js + Express + SQLite 技术栈

需求概述：
- 客户信息的增删改查（CRUD）
- 客户分类和标签管理
- 客户跟进记录
- 客户搜索和筛选
- 数据导出功能

使用完整 metaswarm 编排工作流：
1. Research - 研究技术栈和现有代码模式
2. Plan - 创建实施计划
3. Plan Review Gate - 审查计划
4. Design Review Gate - 审查设计
5. Work Unit Decomposition - 分解工作单元
6. Orchestrated Execution - 4阶段循环执行
7. Final Review - 最终审查
8. PR 创建

仓库地址：https://github.com/wangchangwei/metaswarm.git
```

---

## 完整流程说明

### Step 1: 克隆仓库

```bash
git clone https://github.com/wangchangwei/metaswarm.git
cd metaswarm
```

### Step 2: 一键启动

在 Claude Code 中输入：

```
/start-task 实现一个客户管理系统，采用 Node.js + Express + SQLite 技术栈

需求概述：
- 客户信息的增删改查（CRUD）
- 客户分类和标签管理
- 客户跟进记录
- 客户搜索和筛选
- 数据导出功能

使用完整 metaswarm 编排工作流，要求：
1. 生成完整的 PRD 文档
2. 生成完整的技术规格文档
3. 100% 测试覆盖率
4. 所有文档自动版本化管理

仓库：https://github.com/wangchangwei/metaswarm.git
```

### Step 3: AI 自动完成

AI 会自动执行以下流程：

```
┌─────────────────────────────────────────────────────────────────┐
│                        AI 自动执行                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Research                                                    │
│     ├── 分析技术栈 (Node.js + Express + SQLite)                  │
│     ├── 研究现有代码模式                                          │
│     └── 输出：技术栈确认 + 代码规范                              │
│                                                                 │
│  2. Plan (PRD + 实施计划)                                       │
│     ├── 生成 PRD.md (用户故事、User Flow、KPIs)                  │
│     ├── 生成 SPEC.md (API、数据模型、技术架构)                    │
│     └── 输出：完整需求 + 实施计划                                │
│                                                                 │
│  3. Plan Review Gate (自动审查)                                  │
│     ├── Feasibility Reviewer - 技术可行性                        │
│     ├── Completeness Reviewer - 需求完整性                        │
│     └── Scope & Alignment - 范围一致性                          │
│     └── 3个审查者全部 PASS → 继续                               │
│                                                                 │
│  4. Design Review Gate (自动审查)                               │
│     ├── PM - 用户案例验证                                        │
│     ├── Architect - 技术架构                                      │
│     ├── Designer - UX/UI 设计                                    │
│     ├── Security - 安全威胁建模                                   │
│     └── CTO - TDD 就绪度                                         │
│     └── 5个审查者全部 APPROVE → 继续                           │
│                                                                 │
│  5. Work Unit Decomposition                                      │
│     ├── 分解为多个工作单元                                      │
│     ├── 确定依赖关系                                             │
│     └── 设置检查点                                               │
│                                                                 │
│  6. Orchestrated Execution (每个工作单元)                      │
│     ┌──────────────────────────────────────────────────────┐   │
│     │ IMPLEMENT → VALIDATE → ADVERSARIAL REVIEW → COMMIT  │   │
│     └──────────────────────────────────────────────────────┘   │
│     └── 重复直到所有工作单元完成                                  │
│                                                                 │
│  7. Final Review                                                │
│     ├── 跨单元集成测试                                           │
│     ├── 端到端测试                                              │
│     └── 覆盖率检查 (100%)                                        │
│                                                                 │
│  8. PR 创建                                                     │
│     ├── 自动创建 PR                                              │
│     └── 启动 PR Shepherd 监控                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 你需要提供的输入

### 最小输入（AI 自动推断）

```
/start-task 实现一个客户管理系统
```

AI 会询问：
- 技术栈是什么？
- 有哪些具体需求？
- 仓库地址？

### 推荐输入（减少交互）

```
/start-task 实现一个客户管理系统

技术栈：Node.js + Express + SQLite
前端：React + Vite

需求：
1. 客户 CRUD
2. 客户分类标签
3. 跟进记录
4. 搜索筛选
5. 数据导出 Excel

仓库：https://github.com/xxx/xxx.git

使用完整工作流
```

---

## 交付物

当 AI 完成所有流程后，你会得到：

### 代码
- 完整的客户管理系统源码
- 100% 测试覆盖率的测试用例
- 所有代码符合规范

### 文档
```
docs/
├── PRD.md              # 业务需求文档
├── SPEC.md             # 技术规格文档
├── plans/
│   └── v1.0.0-plan.md # 实施计划快照
├── designs/
│   └── v1.0.0-design.md # 设计文档快照
└── releases/
    ├── v1.0.0.md     # 版本详情
    └── CHANGELOG.md   # 变更日志
```

### PR
- 自动创建的 Pull Request
- 包含所有代码和文档
- PR Shepherd 监控直到合并

---

## 检查点（AI 会暂停等你确认）

| 检查点 | 等待内容 |
|--------|----------|
| 数据库 Schema | 确认数据库设计 |
| API 设计 | 确认接口规范 |
| 外部依赖 | 确认 API Key 等配置 |
| 中期审查 | 确认开发方向 |

**你可以随时回复"继续"或提供反馈**

---

## 常见客户管理系统功能参考

如果你只说"客户管理系统"，AI 会实现以下标准功能：

### 客户管理
- [ ] 客户列表（分页、排序）
- [ ] 客户详情
- [ ] 新建客户
- [ ] 编辑客户
- [ ] 删除客户
- [ ] 客户搜索（按名称、电话、邮箱）

### 分类与标签
- [ ] 客户分类（公司客户、个人客户）
- [ ] 客户标签（VIP、潜在、流失）
- [ ] 分类筛选

### 跟进管理
- [ ] 跟进记录列表
- [ ] 添加跟进记录
- [ ] 跟进类型（电话、面谈、邮件）
- [ ] 跟进提醒

### 数据导出
- [ ] 导出客户列表 Excel
- [ ] 导出跟进记录

### 其他
- [ ] 仪表盘统计
- [ ] 数据导入

---

## 如果你想要自定义功能

只需在需求中说明：

```
/start-task 实现客户管理系统

额外需求：
- 需要微信小程序前端
- 需要邮件通知功能
- 需要销售漏斗统计
- 需要和钉钉集成
```

---

## 注意事项

1. **仓库权限**：确保 GitHub token 有仓库写权限
2. **分支策略**：默认从 main 创建 feature 分支
3. **审查迭代**：如果审查失败，AI 会自动修复并重新提交审查
4. **上下文恢复**：如果 session 中断，从 `.beads/plans/active-plan.md` 恢复

---

## 一句话启动

```
/start-task 实现一个客户管理系统，Node.js + Express + SQLite，仓库：https://github.com/xxx/xxx.git，使用完整工作流
```
