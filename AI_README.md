# AI_README — xuan-tiebanshenshu 协同开发宪法入口

> **版本：1.0.0** · 创建日期：2026-05-09 · 维护者：wjt
>
> AI MUST NOT 修改本文件未经 SPEC Coding 流程批准。
> 本文件是项目所有 AI 工具的"宪法入口"。第一次接入项目时必须完整阅读本文件 + `docs/ai/` 下全部 12 个模块。

---

## 项目特定背景

- **项目类型**：Flutter 应用（Dart SDK，pubspec.yaml 为权威）
- **代码语言**：Dart；面向 AI 的注释/文档/提交信息一律使用中文
- **协同框架**：基于 [`weijingtai/docs`](https://github.com/weijingtai/docs) 的 SPEC-Driven Development 协同规范
- **文档源约束**：`docs/` 目录是 weijingtai/docs 的本地 vendor 镜像
  - **MUST NOT 手编 `docs/` 内任何文件**（手编会被下次同步覆盖）
  - 项目专属覆写写入 `docs-overrides/`（路径与 docs/ 对齐），由 `scripts/sync-docs.sh` 在同步时叠加
  - 旧文档归档于 `docs/previous_archived/`（由 sync 脚本保留，不参与上游同步）
  - 同步：`bash scripts/sync-docs.sh` → `git diff --stat docs/` → 提交

---

## 一、7 条核心原则（不可协商）

完整定义见 [`docs/ai/principles.md`](docs/ai/principles.md)。

| # | 原则 | 一句话 |
|---|------|-------|
| 1 | **SPEC First** | 非平凡改动 MUST 先有已批准 SPEC，否则禁止编码 |
| 2 | **Think Before Coding** | 不假设、不暗中选择、有疑问就停下 |
| 3 | **Simplicity First** | 最小代码、不写推测性抽象、200 行能精简到 50 行就重写 |
| 4 | **Surgical Changes** | 只改必须改的，diff 每一行都能追溯到用户需求 |
| 5 | **Goal-Driven** | 任务先转化为可验证目标，循环直到验证通过 |
| 6 | **Chinese-First** | 注释、文档、提交信息用中文；代码标识符用英文 |
| 7 | **Context-Aware** | 必须从实际文件读上下文，禁止根据训练数据猜测 |

---

## 二、SPEC Coding 工作流（A1–A4 → B1–B3）

完整定义见 [`docs/ai/phases.md`](docs/ai/phases.md)。

```
Part A: SPEC 生命周期 (规格驱动)             Part B: 交付生命周期
┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐    ┌──────┐   ┌──────┐   ┌──────┐
│  A1  │ → │  A2  │ → │  A3  │ → │  A4  │ →  │  B1  │ → │  B2  │ → │  B3  │
│启动框架│   │内容填充│   │评审批准│   │SPEC锁定│    │代码实现│   │SPEC验收│   │SPEC归档│
└──────┘   └──────┘   └──────┘   └──────┘    └──────┘   └──────┘   └──────┘
```

- **A1 启动框架**：确认非平凡改动，搭建 10 节 SPEC 骨架
- **A2 内容填充**：填充架构/数据流/技术决策/验收条件
- **A3 评审批准**：用户审阅 → 提出修改 → 直至批准
- **A4 SPEC 锁定**：状态 → "已锁定"，进入 B 阶段（锁定后禁止单方面修改）
- **B1 代码实现**：在分支内严格按 SPEC 编码
- **B2 SPEC 验收**：逐项勾选验收条件
- **B3 SPEC 归档**：合并 main 后 SPEC 标记为"已归档"

SPEC 文件位置：`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`

---

## 三、代码交付流水线（5 步）

完整定义见 [`docs/ai/delivery-pipeline.md`](docs/ai/delivery-pipeline.md)。

```
Step 1: 分支就绪  →  Step 2: 代码开发  →  Step 3: 自测验证  →  Step 4: 提交就绪  →  Step 5: 合并归档
```

| 步 | 关键准出条件 |
|----|-------------|
| 1 分支就绪 | 分支从最新 main 派生；分支名匹配 `^(feat\|fix\|refactor\|doc\|chore)/[a-z][a-z0-9-]+[a-z0-9]$` |
| 2 代码开发 | `flutter analyze` 0 issue；`dart format --set-exit-if-changed lib/ test/` 通过；diff 在 SPEC 范围内 |
| 3 自测验证 | `flutter test` 全通过；新增公开方法有镜像测试；UI 改动经手动确认 |
| 4 提交就绪 | 提交信息：`<type>: <中文简述>`，type ∈ {add, fix, update, refactor, remove, init}；一个 commit = 一个逻辑变更 |
| 5 合并归档 | merge 无冲突；架构变更已同步 `docs/Plans.md`；远端开发分支已删除 |

---

## 四、平凡改动豁免

可跳过 A1–A4，直接进入 B1：

- 错别字 / 单行修复 / `dart format` 自动格式化
- 用户明确指定且 ≤ 5 行的微调
- 测试用例数据更新

任何涉及逻辑变更、新增文件、结构调整、超过 5 行的改动 MUST 走完整 SPEC Coding。

---

## 五、快速违规自检清单（10 项，每次改动前对照）

```
[ ] 1. 本次改动是否为"非平凡"？是 → 是否已有已批准的 SPEC？
[ ] 2. 我是否已完整读完 AI_README.md + docs/ai/ 下 12 个模块？
[ ] 3. 我是否已读相关源文件、其直接 import、对应 test 文件？
[ ] 4. 分支是否从最新 main 派生？分支名是否符合 <type>/<short-description>？
[ ] 5. 我的 diff 是否每一行都能追溯到用户需求或 SPEC 范围？
[ ] 6. flutter analyze 是否 0 error/0 warning？
[ ] 7. flutter test 是否全通过？新增公开方法是否有对应测试？
[ ] 8. 提交信息是否符合 <type>: <中文简述> 格式？
[ ] 9. diff 是否只含必要文件（无 .DS_Store / build/ / .dart_tool / 个人 IDE 配置）？
[ ] 10. 文档与代码是否一致？发现矛盾时是否已停下询问，而非自选一边？
```

任一项打 × → MUST 停止，先解决再继续。

---

## 六、模块索引（`docs/ai/` 下 12 个模块）

| 模块 | 一句话用途 |
|------|-----------|
| [CONSTITUTION.md](docs/ai/CONSTITUTION.md) | 12 模块版本矩阵与修订历史 |
| [principles.md](docs/ai/principles.md) | 7 条核心原则（SPEC First / Simplicity / Surgical / ...） |
| [phases.md](docs/ai/phases.md) | SPEC Coding 阶段定义（A1–A4 → B1–B3） |
| [delivery-pipeline.md](docs/ai/delivery-pipeline.md) | 代码交付 5 步流水线（分支 → 开发 → 测试 → 提交 → 合并） |
| [board-protocol.md](docs/ai/board-protocol.md) | 看板使用协议 + W1–W5 写入通道 + 权限矩阵 |
| [glossary.md](docs/ai/glossary.md) | 协同方法论术语精确定义（SPEC / Brainstorm / MUST / 准入 / ...） |
| [code-style.md](docs/ai/code-style.md) | Dart/Flutter 代码规范（命名、注释、import 顺序） |
| [directory-structure.md](docs/ai/directory-structure.md) | 项目目录结构（**已覆写**为 xuan-tiebanshenshu 实际结构） |
| [doc-standards.md](docs/ai/doc-standards.md) | 文档格式与命名规则 |
| [git-rules.md](docs/ai/git-rules.md) | Git 分支命名 + 提交规范 |
| [toolchain.md](docs/ai/toolchain.md) | Flutter SDK / 依赖管理 / 开发前检查清单 |
| [project-context-guide.md](docs/ai/project-context-guide.md) | AI 首次接入必读清单 + 任务前必读流程 |

---

## 七、AI 接入新会话的指令

```
请先阅读 AI_README.md 和 docs/ai/ 下全部 12 个模块，然后开始工作。
任何非平凡改动必须先创建 SPEC（docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md）并经我批准后才能编码。
docs/ 是 weijingtai/docs 的本地 vendor 镜像，禁止手编；项目专属覆写在 docs-overrides/。
```

---

## 八、规范语言（RFC 2119 风格）

| 关键词 | 含义 | 违反后果 |
|--------|------|---------|
| **MUST** | 绝对要求 | 提交无效 / 需重写 |
| **MUST NOT** | 绝对禁止 | 同上 |
| **SHOULD** | 强烈建议 | 不遵守需注明理由 |
| **MAY** | 可选 | AI 自主判断 |

完整术语见 [`docs/ai/glossary.md`](docs/ai/glossary.md)。
