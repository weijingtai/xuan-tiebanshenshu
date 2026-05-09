# 设计规格：xuan-tiebanshenshu 集成 weijingtai/docs 框架

- **日期**：2026-05-08
- **作者**：wjt（与 AI 协作）
- **状态**：评审中
- **目标项目**：`xuan-tiebanshenshu`（Flutter 项目）
- **集成对象**：[`weijingtai/docs`](https://github.com/weijingtai/docs) 框架（`master` 分支）

---

## 一、目标

把 weijingtai/docs 这套"AI 协同开发规范框架"作为 vendor 拷贝引入 xuan-tiebanshenshu，满足以下硬约束：

1. **拉取**：从 weijingtai/docs 远程拉到本地
2. **遵循 README + ONBOARDING**：完成开箱即用三步
3. **Pull-only**：本地永远不能 push 到 weijingtai/docs（物理或流程约束）
4. **父 git 跟踪**：docs/ 下的内容由 xuan-tiebanshenshu 自己的 git 实实在在地管理（不是 submodule 指针）
5. **与远程一致**（除明确覆写之外）：本地不"暗中漂移"，每次同步强制重置为上游状态再叠加覆写

## 二、当前状态（前置上下文）

**working tree 状态**（执行前必须知道）：

- `xuan-tiebanshenshu/docs/` **不存在**于磁盘
- `xuan-tiebanshenshu/old_docs/` 存在但未跟踪（`?? old_docs/`），内容与 `git ls-files docs/` 大致重合
- `git status` 显示大量 `D docs/...`（旧 docs 在 working tree 中被删，索引仍持有）

**结论**：之前曾执行过 `mv docs old_docs`（或等价操作），未提交。引入框架不会与 disk 上的现有 docs/ 冲突。但 git 索引层面有遗留，提交时需要明确处理。

**当前分支**：`feature/yunliu`

## 三、架构

```
xuan-tiebanshenshu/
├── docs/                          ← vendor 拷贝（无 .git，物理上无法 push 上游）
│   ├── ONBOARDING.md / README.md / README_zh.md         （from upstream）
│   ├── Plans.md                                         （Step 1 覆写，占位）
│   ├── ai/
│   │   ├── code-style.md / toolchain.md                 （from upstream，Flutter 项目无需替换）
│   │   ├── directory-structure.md                       （Step 1 覆写，占位）
│   │   └── ... (其余 9 个模块 from upstream)
│   ├── board/                                           （from upstream）
│   ├── project/
│   │   ├── README.md                                    （Step 1 覆写，占位）
│   │   └── ... (from upstream)
│   ├── superpowers/                                     （**preserve**：含项目自己的 SPEC + 上游参考 SPEC，整体由 PRESERVE_DIRS 保护）
│   └── previous_archived/                               ← 旧 old_docs/ 内容归档于此（preserve）
├── docs-overrides/                ← 项目专属覆写文件源
│   ├── Plans.md
│   ├── ai/directory-structure.md
│   └── project/README.md
├── scripts/
│   └── sync-docs.sh               ← 同步脚本（含 PRESERVE_DIRS 机制）
├── AI_README.md                   ← Step 2 入口文件（项目根）
└── (old_docs/ 不再存在，已迁入 docs/previous_archived/)
```

## 四、组件职责

### 4.1 `scripts/sync-docs.sh`

**输入**：无（也可加 `--upstream-ref <ref>` 之后再扩展，本期不做）

**行为**（按顺序）：

1. 检查 `docs/` 是否有未跟踪/未提交改动（`git status --porcelain docs/`），若有 → 中止 + 提示用户先 commit / stash
2. 创建临时目录（`mktemp -d`），设置 trap 异常时清理
3. **保留 PRESERVE_DIRS**：把 `docs/<dir>` 移动到 `$TMP/preserved/<dir>`（`previous_archived` 等），不存在则跳过
4. `git clone --depth=1 https://github.com/weijingtai/docs.git $TMP/upstream`
5. 删除临时 clone 中的 `.git/`
6. 删除本地 `docs/` 已有内容（首次同步时 docs/ 不存在）
7. 把 `$TMP/upstream/*`（含点文件如 `.gitignore`，但排除 `.git`）拷贝到 `docs/`
8. **恢复 PRESERVE_DIRS**：把 `$TMP/preserved/<dir>` 移回 `docs/<dir>`
9. 如果 `docs-overrides/` 存在且非空，把 `docs-overrides/*` 叠加到 `docs/`（保持目录层级一致）
10. 清理临时目录
11. 输出提示："同步完成。请运行 `git diff --stat docs/` 检查变更，确认后提交。"

**配置项**（脚本顶部）：

```bash
PRESERVE_DIRS=("previous_archived" "superpowers")
# previous_archived: 旧文档归档
# superpowers:       项目自己的 SPEC / 实现计划（一旦迁入就属于项目，不再受上游影响）
```

**错误处理**：

- 网络失败 → clone 报错 → 脚本 `set -e` 直接退出，不破坏现有 `docs/`
- 临时目录在 trap 中清理
- `docs-overrides/` 不存在或为空 → 跳过覆盖，不报错

**实现要点**：

- 用 bash，`set -euo pipefail`
- 不依赖 rsync（避免环境依赖），用 `cp -r`
- 路径全部相对 `git rev-parse --show-toplevel`，从任意位置可调用

### 4.2 `docs-overrides/`

**职责**：保存项目专属的、需要覆写上游 docs/ 的文件。

**首次内容**（每个文件都是占位骨架，标注 TODO 由用户后续填充）：

- `docs-overrides/Plans.md` — 项目开发计划骨架
- `docs-overrides/ai/directory-structure.md` — xuan-tiebanshenshu 的 lib/ 结构（占位）
- `docs-overrides/project/README.md` — project/ 命名示例占位

**未覆写的 Step 1 候选文件**（保持 upstream 版）：

- `ai/code-style.md`：upstream 已是 Dart/Flutter，本项目同栈，无需覆写
- `ai/toolchain.md`：同上

**约束**：`docs-overrides/` 下文件路径必须严格对应 `docs/` 下的目标路径。

### 4.3 `AI_README.md`（项目根）

**位置**：`xuan-tiebanshenshu/AI_README.md`

**内容骨架**（按 ONBOARDING.md 描述的 5 个要点）：

1. 7 条核心原则摘要（来自 docs/ai/principles.md）
2. SPEC Coding 工作流概览（A1–A4 → B1–B3）
3. 代码交付流水线 5 步
4. 10 项快速自检清单
5. 指向 docs/ai/ 下 12 个模块的索引

**实现策略**：第一版按 ONBOARDING 的描述写概要，详细内容指向 docs/ai/ 各模块，不重复抄写。docs/superpowers/specs/2026-05-08-ai-readme-design.md 中有完整设计规格可参考（拉取 docs/ 之后才能看到）。

### 4.4 `docs/` 下的所有文件

- 由 `sync-docs.sh` 管理
- **不可手动编辑**（手动改了下次同步会被覆盖；要改请放进 `docs-overrides/`）

## 五、数据流

### 5.1 首次初始化

```
1. git checkout -b feat/docs-framework-init
2. 写 docs-overrides/ 下 3 个占位覆写文件
3. 写 scripts/sync-docs.sh
4. bash scripts/sync-docs.sh        ← docs/ 出现，含上游内容 + 覆写
5. mv old_docs docs/previous_archived ← 旧文档归档落位
6. 写 AI_README.md
7. 把本 spec 从 superpowers/specs/ 迁入 docs/superpowers/specs/
8. 删除根级临时 superpowers/ 目录（如果全空）
9. git add -A docs/ docs-overrides/ scripts/sync-docs.sh AI_README.md
   （-A 是关键：要把旧 docs/ 里那些索引中存在但工作树已删的文件标为 deleted）
   （old_docs/ 是 untracked，mv 之后变成 docs/previous_archived/，由 git add docs/ 自然纳入）
10. git commit
```

### 5.2 日常更新

```
1. bash scripts/sync-docs.sh
2. git diff --stat docs/                ← 看变更
3. git add -A docs/                      ← -A 处理上游可能删除文件的情况
4. git commit -m "chore(docs): 同步 weijingtai/docs <commit-short>"
```

### 5.3 添加新覆写

```
1. echo "..." > docs-overrides/<path>
2. bash scripts/sync-docs.sh             ← 让 docs/<path> 同步成覆写后的状态
3. git add -A docs/ docs-overrides/
4. git commit
```

## 六、Pull-only 的实现

三层防御：

1. **物理层**：`docs/` 内无 `.git`，`xuan-tiebanshenshu/.git/config` 中无任何指向 `weijingtai/docs.git` 的 remote
2. **流程层**：`sync-docs.sh` 是单向同步（远程 → 本地），无 push 路径
3. **文档层**：`AI_README.md` + `docs/` 中加注释说明（如 `docs/SYNC_NOTICE.md` 或在 `AI_README.md` 中说明，避免修改上游文件来提示）

> 选择：把"docs/ 是 vendor 镜像、不可手编"的提示写在 **AI_README.md**，而不是新增 `docs/SYNC_NOTICE.md`，避免污染 docs/ 命名空间。

## 七、错误处理 & 边界

| 场景 | 行为 |
|------|------|
| `docs/` 有未提交改动 | sync-docs.sh 中止，提示先 commit/stash |
| `docs-overrides/` 不存在 | sync-docs.sh 跳过覆盖步骤，不报错 |
| 网络失败 | clone 失败 → 脚本退出，原 docs/ 不受损 |
| 临时目录清理失败 | trap 中 best-effort，不阻塞返回码 |
| 用户手编了 docs/ 里的文件 | 下次 sync 中止（git porcelain 检查），用户必须明确处理 |

## 八、验收标准

- [ ] `docs/` 内无 `.git/` 子目录
- [ ] `git remote -v`（在 xuan-tiebanshenshu）无指向 weijingtai/docs 的条目
- [ ] `docs/ai/` 下 12 个模块文件齐全（CONSTITUTION / board-protocol / glossary / principles / phases / delivery-pipeline / code-style / directory-structure / git-rules / doc-standards / toolchain / project-context-guide）
- [ ] `docs/Plans.md` 是 docs-overrides/Plans.md 的内容（不是 upstream 版）
- [ ] `docs/ai/code-style.md` 是 upstream 版本（未覆写）
- [ ] `docs/previous_archived/` 存在，内容来自原 `old_docs/`，文件数不少于原 `old_docs/`
- [ ] `xuan-tiebanshenshu/AI_README.md` 存在，正文符合 ONBOARDING 5 要点
- [ ] `bash scripts/sync-docs.sh` 在干净状态下成功，且 `docs/previous_archived/` 与 `docs/superpowers/specs/<本 spec>` 在同步后仍然完整保留
- [ ] sync-docs.sh 在 `docs/` 有手编改动时正确中止
- [ ] xuan-tiebanshenshu git tree 实实在在包含 docs/* 的所有文件（`git ls-files docs/ | wc -l > 0`）
- [ ] 本 spec 文件落在 `docs/superpowers/specs/2026-05-08-docs-framework-init-design.md`
- [ ] 项目根 `old_docs/` 已不存在

## 九、决策记录（用户已确认）

1. **分支策略**：新建 `feat/docs-framework-init` 进行集成
2. **`old_docs/` 处理**：归档到 `docs/previous_archived/`（必须由 sync-docs.sh 的 PRESERVE_DIRS 保留）
3. **git 索引中旧 `D docs/...` 记录**：合入本次提交（一个原子 commit 完成"清理旧 docs + 引入新框架 + 归档旧文档"）

## 十、不在范围内（YAGNI）

- 自动化 cron / CI 同步（人工触发即可）
- 多上游分支支持（只跟 master）
- 双向同步 / fork & PR 机制（违反 pull-only 约束）
- override 优先级 / 模板渲染（保持简单的"路径对齐覆写"语义）

---

## 附录 A：sync-docs.sh 草稿

```bash
#!/usr/bin/env bash
# 同步 weijingtai/docs 上游到本地 docs/，并叠加 docs-overrides/。
# 详见 docs/superpowers/specs/2026-05-08-docs-framework-init-design.md

set -euo pipefail

UPSTREAM_URL="https://github.com/weijingtai/docs.git"
UPSTREAM_REF="master"
PRESERVE_DIRS=("previous_archived" "superpowers")    # docs/ 下需要在同步中保留的子目录
                                                     # superpowers 含项目自己的 SPEC，不能被上游覆盖

REPO_ROOT="$(git rev-parse --show-toplevel)"
DOCS_DIR="$REPO_ROOT/docs"
OVERRIDES_DIR="$REPO_ROOT/docs-overrides"

# 1. 检查 docs/ 是否干净（包含 untracked，防止手动新建的文件被静默覆盖）
if [ -d "$DOCS_DIR" ]; then
  dirty="$(git -C "$REPO_ROOT" status --porcelain -- "$DOCS_DIR" || true)"
  if [ -n "$dirty" ]; then
    echo "错误：docs/ 有未提交或未跟踪改动。请先 commit 或处理后再同步。" >&2
    echo "$dirty" >&2
    exit 1
  fi
fi

# 2. 临时目录 + trap
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/preserved"

# 3. 保留 PRESERVE_DIRS
for d in "${PRESERVE_DIRS[@]}"; do
  if [ -d "$DOCS_DIR/$d" ]; then
    mv "$DOCS_DIR/$d" "$TMP_DIR/preserved/$d"
    echo "保留 docs/$d"
  fi
done

# 4-5. 浅克隆上游 + 去 .git
echo "克隆 $UPSTREAM_URL ($UPSTREAM_REF) ..."
git clone --depth=1 --branch "$UPSTREAM_REF" "$UPSTREAM_URL" "$TMP_DIR/upstream"
rm -rf "$TMP_DIR/upstream/.git"

# 6-7. 重置本地 docs/，拷贝上游
rm -rf "$DOCS_DIR"
mkdir -p "$DOCS_DIR"
cp -R "$TMP_DIR/upstream/." "$DOCS_DIR/"

# 8. 恢复 PRESERVE_DIRS（先清掉 upstream 创建的同名目录，避免 mv 嵌套）
for d in "${PRESERVE_DIRS[@]}"; do
  if [ -d "$TMP_DIR/preserved/$d" ]; then
    rm -rf "$DOCS_DIR/$d"
    mv "$TMP_DIR/preserved/$d" "$DOCS_DIR/$d"
    echo "恢复 docs/$d"
  fi
done

# 9. 叠加 docs-overrides/
if [ -d "$OVERRIDES_DIR" ] && [ -n "$(ls -A "$OVERRIDES_DIR" 2>/dev/null || true)" ]; then
  echo "叠加 docs-overrides/ ..."
  cp -R "$OVERRIDES_DIR/." "$DOCS_DIR/"
fi

echo "同步完成。请运行 'git diff --stat docs/' 检查变更后提交。"
```
