# 移除 xuan-tiebanshenshu 对 xuan_common 残留依赖 — 执行手册

> **致执行 AI agent**：你是**执行者**，不是设计者。本手册已替你做完所有判断。
> 你要做的只有一件事：**严格逐条照做**。每条任务都给了「精确改法 + 验证命令 + 期望输出」。
> **任何不确定、任何与期望不符 → 立刻停下，报告现象，绝不猜测、绝不自由发挥、绝不"顺手优化"。**

**Goal（一句话）**：把 `xuan-tiebanshenshu` 里所有还在引用废弃包 `xuan_common` 的地方，改成引用 `metaphysics_core` 和本仓已有的 fixture，然后删掉 `xuan_common` 依赖，最终全仓 0 处 `xuan_common`、`flutter analyze` 0 问题、`flutter test` 全绿。

**Architecture（背景，只需知道这些）**：
- 生产代码 `lib/` **已经迁移完成**，并且已有一个**现成的替身**：`lib/dev/dev_fixtures.dart` 里的 `TiebanshenshuDevFixtures.devUsa`。
- 它是旧 `DevConstant.dev_usa` 的**等价重建**（类型一一对应、字段一致），所以你**只是在重定向 import + 换符号名**，**不写任何新逻辑、不写任何新测试**。
- 残留只在 `test/` 和 `example/` 里。

**Tech Stack**：Flutter / Dart。命令用 `flutter` / `dart` / `git`。

---

## 0. 全局铁律（先读完，违反任何一条都判作废）

### ✅ 你**只能**做这些
1. 只在【本手册明确点名的文件】上，做【本手册写明的精确改动】。
2. 运行本手册给出的命令（只读检查命令 / 验证命令 / 最后的提交命令）。
3. 每改完一个文件，立刻跑该任务的「验证命令」，确认期望输出。

### 🛑 你**绝对禁止**做这些（违反即停）
1. 🛑 **禁止修改 `lib/` 下任何文件的内容**。`lib/` 已迁移完成。唯一允许对 `lib/` 做的是 `git add lib/dev/dev_fixtures.dart`（只是纳入跟踪，**不改内容**）。
2. 🛑 **禁止修改 `lib/dev/dev_fixtures.dart` 的内容**（一个字都不许改）。
3. 🛑 **禁止触碰任何兄弟仓库**：`../xuan-common`、`../xuan-metaphysics-core`、`../xuan-storage` 等，全部只读都不需要，更不许改。
4. 🛑 **禁止任何破坏性 git 命令**（仓库里有未提交的成果，一旦执行会永久丢失）：
   `git checkout -- ...`、`git restore ...`、`git reset ...`、`git clean ...`、`git stash`、`git revert`、`git rebase`、`git merge`、`git push`、切分支、建分支 —— **全部禁止**。
5. 🛑 **禁止"顺手优化"**：不重命名、不重排 import 顺序、不改无关格式、不加/删注释、不改代码风格、不动任何与 `xuan_common` 无关的行。
6. 🛑 **禁止新建任何文件**（本手册没让你建的，一个都不许建）。
7. 🛑 **禁止改依赖版本 / `environment` / `dependency_overrides: persistence_core`**。
8. 🛑 **禁止写新测试、禁止改测试断言逻辑**。你只改 import 行和符号名，测试的断言体一律不动。
9. 🛑 **禁止 `flutter clean` 或删除任何目录**。
10. 🛑 **不确定就停**：找不到本手册说的字符串、改完验证不通过、出现没预料到的报错 —— **立即停下并报告**，不要猜路径、不要猜符号、不要试别的写法。

### ⚠️ 并发提醒（非常重要）
- **可能有另一个 agent（Codex）正在并发改同一个仓库。** 本手册的每个任务都设计成**幂等**：
  - 每个任务开头先「检查」。**如果发现某处已经改好了（即已经没有 `xuan_common` 了），就跳过它，继续下一个，这是正常的，不要去"撤销"别人的成果。**
- **仓库当前可能处于"半成品/编译不过"的状态**（依赖已被注释掉，但部分文件还在引用它）。**这是预期的**，正是你要修复的目标。所以：**只要求"最后全绿"，不要因为"一开始 analyze/test 报错"而惊慌或乱改。**

### 卡住 / 出错时的标准动作（背下来）
> **停下 → 不做任何破坏性操作 → 用一句话描述"我在第几步、跑了什么命令、看到了什么输出、与期望差在哪" → 把这句话报告给人类，等指示。**

---

## 执行顺序总览
T0 起点确认（只读） → T1 跟踪 fixture → T2 迁移 9 个 dev_constant 文件 → T3 校验 enum（通常无需动作） → T4 删 example 死测试 → T5 清理 root pubspec → T6 改 example pubspec → T7 重装依赖 → T8 分析+格式化 → T9 测试 → T10 终检 → T11 提交

---

## T0 — 起点确认（只读，不许改任何东西）

- [ ] **Step 1：进入仓库，确认分支**

Run:
```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-tiebanshenshu
git branch --show-current
```
Expected：输出 `feat/docs-framework-init`。
> 🛑 如果不是这个分支：**停下报告**，不要自己切分支。

- [ ] **Step 2：确认替身 fixture 存在**

Run:
```bash
test -f lib/dev/dev_fixtures.dart && grep -n "class TiebanshenshuDevFixtures" lib/dev/dev_fixtures.dart
```
Expected：输出形如 `13:class TiebanshenshuDevFixtures {`。
> 🛑 如果文件不存在或没有这个类：**停下报告**。后面所有任务都依赖它，不要自己造。

- [ ] **Step 3：看一眼当前还剩多少残留（记下来，作对照）**

Run:
```bash
grep -rn "xuan_common" . --include="*.dart" --include="*.yaml" | grep -vE "/(\.dart_tool|build|\.git)/"
```
Expected：会列出若干行（test/、example/、可能还有 pubspec）。**这就是你要逐个清掉的清单。** 记住：最终这条命令必须输出为空。

---

## T1 — 把 fixture 文件纳入 git 跟踪

**为什么**：`lib/dev/dev_fixtures.dart` 现在是「未跟踪」状态；不纳入跟踪，别人拉代码会缺这个文件、直接编译失败。

**Files**：
- 纳入跟踪（**不改内容**）：`lib/dev/dev_fixtures.dart`

- [ ] **Step 1：检查是否已被跟踪（幂等）**

Run:
```bash
git status --porcelain lib/dev/dev_fixtures.dart
```
- 若输出 `?? lib/dev/dev_fixtures.dart` → 继续 Step 2。
- 若输出 `A  lib/dev/dev_fixtures.dart` 或**无输出** → 已经加过了，**跳过本任务**。

- [ ] **Step 2：纳入跟踪**

Run:
```bash
git add lib/dev/dev_fixtures.dart
```

- [ ] **Step 3：验证**

Run:
```bash
git status --porcelain lib/dev/dev_fixtures.dart
```
Expected：`A  lib/dev/dev_fixtures.dart`
> 🛑 不要打开编辑这个文件。

---

## T2 — 迁移 9 个引用 `dev_constant.dart` 的文件（核心任务）

**对【下面 9 个文件中每一个】做完全相同的两处替换：**

**替换 A（import 行）**：
- 找到这一行（精确）：
  ```dart
  import 'package:xuan_common/dev_constant.dart';
  ```
- 改成：
  ```dart
  import 'package:tiebanshenshu/dev/dev_fixtures.dart';
  ```

**替换 B（符号，文件里所有出现处）**：
- 把所有 `DevConstant.dev_usa` 改成 `TiebanshenshuDevFixtures.devUsa`
- （例如 `final devData = DevConstant.dev_usa;` → `final devData = TiebanshenshuDevFixtures.devUsa;`）

**9 个文件清单**：
1. `test/features/liuqinkaoke/strategy/liuqinkaoke_calculation_strategy_test.dart`
2. `test/service/strategy/gua_zhong_logic_debug_test.dart`
3. `test/service/strategy/gua_zhong_three_plans_test.dart`
4. `test/service/strategy/liu_yao_debug_test.dart`
5. `test/service/strategy/qian_hou_gua_strategy_debug_test.dart`
6. `test/service/strategy/xian_houtian_qu_shu_debug_test.dart`
7. `test/usecases/gua_zhong_use_case_test.dart`
8. `test/usecases/qian_hou_gua_use_case_test.dart`
9. `example/lib/main.dart`

**逐文件做法（对上面每个文件重复）**：

- [ ] **Step 1：先检查这个文件是否还需要改（幂等）**

Run（把 `<FILE>` 换成当前文件路径）：
```bash
grep -n "xuan_common/dev_constant\|DevConstant" <FILE>
```
- 若**有输出** → 按上面的「替换 A + 替换 B」改这个文件。
- 若**无输出** → 说明已被（并发的 Codex）改好了，**跳过这个文件**，处理下一个。

- [ ] **Step 2：改完立刻验证这个文件**

Run（同一个 `<FILE>`）：
```bash
grep -n "xuan_common\|DevConstant" <FILE>
```
Expected：**无任何输出**（这个文件已经没有 `xuan_common`、也没有旧符号 `DevConstant` 了）。
> 🛑 如果还有输出：说明你漏改或改错了，**只在这个文件内**修正；修不好就**停下报告**。
> ⚠️ 注意：`gua_zhong_logic_debug_test.dart` 之前已被并发改过 enum 那一行，但它**仍有** `dev_constant` 这一行需要你按本任务改。

- [ ] **Step 3：9 个文件全部处理完后，一次性总验证**

Run:
```bash
grep -rn "xuan_common/dev_constant\|DevConstant" test/ example/lib | grep -vE "/(\.dart_tool|build)/"
```
Expected：**无任何输出**。
> 🛑 还有输出 → 对照清单看哪个文件漏了，补改；补不好就停下报告。

---

## T3 — 校验 enum 迁移（通常已完成，无需动作）

**背景**：`enum_jia_zi` 的 import 之前已由并发 agent 改完。本任务只做核对。

- [ ] **Step 1：检查 enum 残留**

Run:
```bash
grep -rn "xuan_common/enums" . --include="*.dart" | grep -vE "/(\.dart_tool|build|\.git)/"
```
- 若**无输出** → ✅ 已完成，**跳过本任务**。
- 若**有输出**（极少数情况）→ 对命中的每个文件，把这一行：
  ```dart
  import 'package:xuan_common/enums/enum_jia_zi.dart';
  ```
  改成：
  ```dart
  import 'package:metaphysics_core/enums.dart';
  ```
  然后重跑本命令直到无输出。
> 🛑 除了这一行 import，**不要改该文件其它任何内容**。

---

## T4 — 删除 example 的死测试文件

**Files**：
- 删除：`example/test/widget_test.dart`

**为什么**：该文件 `import 'package:xuan_common/main.dart';` 并测试一个**计数器界面 `MyApp`**——那是 `xuan_common` 演示 app 的东西，**本项目根本没有 `MyApp`**（本 example 的真正入口是 `TieBanShenShuExampleApp`）。这个测试对本项目无意义，直接删。

- [ ] **Step 1：检查是否还在（幂等）**

Run:
```bash
test -f example/test/widget_test.dart && echo "EXISTS" || echo "ALREADY GONE"
```
- `ALREADY GONE` → 跳过本任务。
- `EXISTS` → 继续 Step 2。

- [ ] **Step 2：删除它**

Run:
```bash
git rm example/test/widget_test.dart 2>/dev/null || rm example/test/widget_test.dart
```

- [ ] **Step 3：验证**

Run:
```bash
test -f example/test/widget_test.dart && echo "STILL HERE(BAD)" || echo "DELETED(OK)"
```
Expected：`DELETED(OK)`
> 🛑 不要试图"改好"这个测试，也不要新建替代测试。就是删。

---

## T5 — 清理 root `pubspec.yaml` 里 xuan_common 的死注释

**背景**：并发 agent 已把 root 依赖**注释掉**了（依赖其实已移除）。本任务把这两行**死注释删干净**。

**Files**：
- Modify：`pubspec.yaml`

- [ ] **Step 1：检查当前状态（幂等）**

Run:
```bash
grep -n "xuan_common" pubspec.yaml
```
- 若**无输出** → 已清理干净，**跳过本任务**。
- 若看到（约在 46–47 行）：
  ```
    # xuan_common:
    #   path: ../xuan-common
  ```
  → 继续 Step 2，把这两行**整行删除**。
- 若看到的是**没有 `#` 的真实依赖**（`  xuan_common:` 和 `    path: ../xuan-common`）→ 同样把这两行整行删除。

- [ ] **Step 2：删除这两行**

精确删除以下两行（连同行首空格/`#`）：
```
  # xuan_common:
  #   path: ../xuan-common
```
> 删除后，上一行应是 `    sdk: flutter`（属于 `flutter_localizations`），下一行应是 `dev_dependencies:`。
> 🛑 不要动 `flutter_localizations`、`dev_dependencies`、`dependency_overrides` 等任何其它行。

- [ ] **Step 3：验证**

Run:
```bash
grep -n "xuan_common" pubspec.yaml || echo "CLEAN(OK)"
```
Expected：`CLEAN(OK)`

---

## T6 — 移除 example/`pubspec.yaml` 的 xuan_common 依赖

**Files**：
- Modify：`example/pubspec.yaml`

- [ ] **Step 1：检查（幂等）**

Run:
```bash
grep -n "xuan_common" example/pubspec.yaml || echo "ALREADY CLEAN"
```
- `ALREADY CLEAN` → 跳过本任务。
- 否则会看到（约 17–18 行）：
  ```
    xuan_common:
      path: ../../xuan-common
  ```
  → 继续 Step 2。

- [ ] **Step 2：删除这两行**

精确删除以下两行：
```
  xuan_common:
    path: ../../xuan-common
```
> 删除后，上一行应仍是 `    path: ../`（属于 `tiebanshenshu:` 依赖），下一行应是空行或 `dev_dependencies:`。
> 🛑 不要删 `tiebanshenshu:` / `path: ../` 这两行——那是 example 依赖主包的关键，删了就崩。

- [ ] **Step 3：验证**

Run:
```bash
grep -n "xuan_common" example/pubspec.yaml || echo "CLEAN(OK)"
```
Expected：`CLEAN(OK)`

---

## T7 — 重新解析依赖

- [ ] **Step 1：主包 pub get**

Run:
```bash
flutter pub get
```
Expected：以 `Got dependencies!` 之类成功信息结束，**无 error**。

- [ ] **Step 2：example pub get**

Run:
```bash
cd example && flutter pub get; cd ..
```
Expected：同上，成功、无 error。

> ⚠️ 如果报错信息里出现 `xuan_common`（比如 "Target of URI doesn't exist: 'package:xuan_common/...'"）：说明**还有某个文件在引用它**。回到 T2/T3/T4 把漏网的那个文件清掉，再重跑本任务。
> 🛑 其它任何报错（版本冲突、网络等）→ **停下报告**，不要乱改 pubspec 版本号。

---

## T8 — 静态分析 + 格式化

- [ ] **Step 1：分析**

Run:
```bash
flutter analyze
```
Expected：`No issues found!`
> ⚠️ 关于 `example/lib/main.dart` 的 `import 'package:timezone/data/latest.dart' as tz;`：**这一行必须保留**——因为第 14 行有 `tz.initializeTimeZones();` 在用它。所以 analyze **不该**报它 unused；若真报了 unused，说明你误删了第 14 行，去恢复（手动改回，**不要用 git checkout**）。
> 🛑 如果 analyze 报出任何**与本次迁移无关**的旧问题：**停下报告**，不要顺手去修不属于本任务的东西。

- [ ] **Step 2：格式化（只格式化本次涉及的目录）**

Run:
```bash
dart format lib/dev test example/lib
```
Expected：列出被格式化/已是规范的文件，命令成功退出。
> 🛑 不要对整个仓库 `dart format .`，只格式化上面三个范围，避免动到无关文件。

---

## T9 — 运行测试

- [ ] **Step 1：主包测试**

Run:
```bash
flutter test
```
Expected：`All tests passed!`
> ⚠️ 这些测试只是「换了数据来源（fixture）」，断言逻辑没变，所以应当全过。
> 🛑 如果有测试**失败**：**停下报告**失败的测试名和报错。**绝对不要**为了让它过而修改断言或测试逻辑（那是作弊）。

- [ ] **Step 2：example 测试**

Run:
```bash
cd example && flutter test; cd ..
```
Expected：`All tests passed!`，或 `No tests found.`（因为我们在 T4 删了唯一的 example 测试，这是正常的）。两者都算通过。

---

## T10 — 终检：全仓 0 处 xuan_common

- [ ] **Step 1：源码与配置零残留**

Run:
```bash
grep -rn "xuan_common" . --include="*.dart" --include="*.yaml" | grep -vE "/(\.dart_tool|build|\.git)/" || echo "ZERO RESIDUAL (OK)"
```
Expected：`ZERO RESIDUAL (OK)`
> 🛑 还有输出 → 回到对应任务清掉；清不掉就停下报告。

- [ ] **Step 2：lockfile 应已自动重建（不要手改）**

Run:
```bash
grep -rln "xuan_common" . --include="*.lock" | grep -vE "/(\.dart_tool|build|\.git)/" || echo "LOCK CLEAN (OK)"
```
- `LOCK CLEAN (OK)` → 完美。
- 若仍命中 lock 文件 → 重跑 **T7**（`flutter pub get`）让它自动重建。
> 🛑 **绝不手工编辑任何 `.lock` 文件。**

---

## T11 — 提交（仅当 T7–T10 全部通过后；只用下面给的安全命令）

> 前提：T8 `No issues found!`、T9 全过、T10 `ZERO RESIDUAL (OK)`。任一未达标 → **不要提交**，回去修或报告。

- [ ] **Step 1：再确认改动范围**

Run:
```bash
git status --porcelain
```
> 看一眼改动的就是本手册涉及的那些文件（`lib/dev/`、那些 test 文件、`example/`、两个 `pubspec.yaml`、两个 `pubspec.lock`、可能还有之前的 5 个 lib 文件）。
> 🛑 如果看到**完全意料之外**的文件被改 → **停下报告**，不要提交。

- [ ] **Step 2：精确 add（只加相关文件；不要 `git add .` 全加）**

Run（包含本次迁移涉及的全部文件；`example/test/widget_test.dart` 的删除在 T4 已被 `git rm` 暂存，这里无需再管它）：
```bash
git add lib/dev/dev_fixtures.dart \
        lib/main.dart \
        lib/features/liuqinkaoke/usecase/liuqinkaoke_session_manager.dart \
        lib/presentation/pages/four_doors_and_gun_fa_page.dart \
        lib/presentation/pages/strategy_demo_page.dart \
        lib/presentation/pages/tai_xuan_interactive_page.dart \
        pubspec.yaml pubspec.lock \
        example/pubspec.yaml example/pubspec.lock \
        example/lib/main.dart \
        test/features/liuqinkaoke/strategy/liuqinkaoke_calculation_strategy_test.dart \
        test/service/strategy/gua_zhong_logic_debug_test.dart \
        test/service/strategy/gua_zhong_three_plans_test.dart \
        test/service/strategy/liu_yao_debug_test.dart \
        test/service/strategy/qian_hou_gua_strategy_debug_test.dart \
        test/service/strategy/xian_houtian_qu_shu_debug_test.dart \
        test/service/strategy/gua_zhong_human_spec_test.dart \
        test/usecases/gua_zhong_use_case_test.dart \
        test/usecases/qian_hou_gua_use_case_test.dart
```
> 上面前 6 个 `lib/` 文件是并发 agent 先前完成、尚未提交的迁移成果（`lib/dev/dev_fixtures.dart` + 5 个已改 lib 文件）；与本次 test/example 改动同属「移除 xuan_common」一件事，一并提交以保证工作区干净。
> 🛑 不要 `git add -A` / `git add .`。`AGENTS.md` 是否提交由人类决定，**不归你管，别碰它**。
> ⚠️ 如果上面某个 `lib/` 文件 `git add` 报「pathspec did not match」（说明并发方已自行提交过它），忽略该提示继续即可，**不要**改用 `git add .` 去凑。

- [ ] **Step 3：提交（中文提交信息，格式 `<type>: <简述>`）**

Run:
```bash
git commit -m "refactor: lib/测试/示例 全面切换至 metaphysics_core 并移除废弃 xuan_common 依赖"
```
Expected：提交成功，显示改动文件数。

- [ ] **Step 4：报告完成**

向人类报告：「已完成 T0–T11，`flutter analyze` 0 问题、`flutter test` 全过、全仓 0 处 `xuan_common`，已提交（未推送、未合并）。」
> 🛑 **不要 `git push`、不要切回 main、不要合并**——合并由人类来做。

---

## 附录 A：精确字符串对照表（改的时候照抄，别凭记忆）

| 场景 | 找到（OLD） | 改成（NEW） |
|---|---|---|
| dev_constant import | `import 'package:xuan_common/dev_constant.dart';` | `import 'package:tiebanshenshu/dev/dev_fixtures.dart';` |
| dev_usa 符号 | `DevConstant.dev_usa` | `TiebanshenshuDevFixtures.devUsa` |
| enum import（通常已改完） | `import 'package:xuan_common/enums/enum_jia_zi.dart';` | `import 'package:metaphysics_core/enums.dart';` |
| root pubspec（整两行删除） | `  # xuan_common:` + `  #   path: ../xuan-common` | （删除，不留空行残骸） |
| example pubspec（整两行删除） | `  xuan_common:` + `    path: ../../xuan-common` | （删除） |
| example 死测试 | 整个文件 `example/test/widget_test.dart` | （删除文件） |

## 附录 B：本次任务"为什么是安全的"（给执行者吃定心丸）
- 新 fixture `TiebanshenshuDevFixtures.devUsa` 与旧 `DevConstant.dev_usa` 返回**同一套八字/时间数据**（乙巳·甲申·戊寅·庚申、2025-09-06、Nevada/USA、处暑），类型 `DateTimeDetailsBundleLogicModel` 与旧 `DateTimeDetailsBundle` 字段一一对应。
- 所以你只是**换了同一份数据的来源包**，测试断言不需要改、也不许改。
- 唯一已知细微差异：新 fixture 把 `isDST` 固定为 `false`、`removeDSTDatetime` 不减 1 小时。**当前没有任何测试断言这两个字段**，所以不影响。**你不需要为此做任何事**——只是让你知道，别自作主张去"修正"它。

## 附录 C：一句话总结你的边界
> **你只动 import 行、符号名、两个 pubspec 的依赖块、删一个死测试文件。其余一切（业务逻辑、断言、lib 内容、fixture 内容、兄弟仓库、依赖版本、git 历史）一律不许碰。拿不准就停下报告。**
