# 统一排盘系统 - 实施计划 (v2)

## 1. 愿景与架构

目标是将系统从**工具箱**模式（离散、独立的工具）转变为**统一流水线**模式（一键排盘）。用户提供`八字`（以及可选的上下文，如性别/起运），系统协调15+种算法生成一份综合报告。

### 1.1 核心组件

* **`DivinationContext` (排盘上下文)**: 不可变的状态容器，持有：
  * **输入**: `EightChars` (八字), `Gender` (性别), `ThreeYuan` (三元), `BirthAfterZhi` (出生节气).
  * **派生状态**: `KeFen` (刻分 - 可选), `YuanHuiYunShi` (元会运世 - 可选).
  * **结果**: 所有已执行策略的 `StrategyID -> DivinationResult` 映射表。
* **`DivinationOrchestrator` (排盘协调器)**: 工作流引擎。它计算策略的依赖图并执行它们。它处理：
  * **标准策略**: 在可能的情况下自动并行执行。
  * **交互式策略**: 暂停执行以请求用户输入（例如：太玄交互式策略）。
* **`UnifiedDivinationViewModel`**: 管理UI状态、用户会话和历史记录。

## 2. 算法集成策略

基于代码审查 (`docs/alg_code_review_v1/`) 和功能需求 (`docs/normal_alg/`)，算法按依赖深度分类。

### 层级 1: 基础层 (直接依赖)

*依赖: 仅八字*

1. **`DayGanZhiGuaStrategy` (日干支卦)**: 使用日柱干支。
2. **`FourZhuTianGanStrategy` (四柱天干)**: 使用四柱天干。公式: `月*1000 + 日*100`.
3. **`ShengMingGuaCalculationStrategy` (生命卦)**: 使用生年/生月。
4. **`GuaZhongStrategy` (卦中取数)**: 处理"和为10"的歧义，提供3种方案。
5. **`BaGuaJiaZeStrategy` (八卦加则)**: 标准八卦加则逻辑。
6. **`BaGuaGunStrategy` (八卦滚)**: 生成48条滚卦条文。
7. **`SiMenFaStrategy` (四门法)**: 复杂的本/互/变/错卦生成。
8. **`QianHouGuaStrategy` (前后卦)**: 将四柱分为前/后卦。
9. **`TaiXuanFourZhuStrategy` (太玄四柱)** (标准版): 自动运行 `年干阴阳` 和 `传统内外卦` 两种方法。

### 层级 2: 进阶层 (派生/复杂依赖)

*依赖: 八字 + 共享计算 (如元堂卦)*
10. **`YuanTangStrategy` (元堂卦)**: 重型核心组件。计算：
    *天地卦 / 先天卦 / 后天卦。
    *   大运周期。
    *条文扩展 (+96x4)。
11. **`XianHoutianQuShuStrategy` (先后天取数)**:
    *   *当前实现*: 内部重新计算元堂逻辑。
    **目标*: 应重用 Context 中的 `YuanTangResult` 以避免重复计算。
12. **`LiuYaoGanZhiHeStrategy` (六爻干支和)**:
    *   *目标*: 应重用 Context 中的 `YuanTangResult` (先天/后天卦)。
13. **`XianHoutianJiaZeStrategy` (先后天加则)**:
    *   *目标*: 应重用 `YuanTangResult`。
14. **`GuaYaoGanZhiHeStrategy` (卦爻干支和)**: 同样依赖基础卦象映射。

### 层级 3: 交互层

*依赖: 用户输入*
15. **`TaiXuanFourZhuInteractiveStrategy` (太玄交互式)**:
    *允许用户手动修正/选择 `八字` 或 `卦象` 映射。
    *   *集成*: 协调器应检测此策略，并在UI流中展示"咨询卡片"。

## 3. 数据模型标准化

为了支持统一视图，所有策略必须返回实现 `DivinationResult` 的结果。

```dart
abstract class DivinationResult {
  String get strategyId;      // 策略ID
  String get title;           // 标题
  List<DivinationItem> get items; // 用于展示的统一条目
}

class DivinationItem {
  final String label;   // 例如 "年柱 - 方法A"
  final String content; // 条文编号或文本
  final List<String> tags; // 例如 ["元堂", "先天"]
  final Map<String, dynamic> metadata; // 用于下钻详情 (爻详情等)
}
```

**行动项**: 我们需要为现有的 `BaseNumberModelResult`（其类型各异）编写适配器，将其转换为统一的 `DivinationResult`。

## 3.3 会话管理机制 (Session Management)

在该项目中，"Session" 并不单指一个简单的变量，而是一个分层的管理机制，用于支持由简入繁的排盘需求：

### 3.3.1 交互会话 (`InteractiveSession`)

* **层级**: 最底层，针对单个算法（如太玄交互式）。
* **职责**: 记录单次算法内部的步骤（Step）、用户选择（Selection）和状态跳转（Jump/Undo）。
* **持久化**: 临时存储，随排盘结束归档。

### 3.3.2 排盘上下文 (`DivinationContext`)

* **层级**: 核心层，代表一次完整的排盘计算状态。
* **职责**:
  * 作为不可变快照（Immutable Snapshot）。
  * **分叉机制 (Forking)**: 当用户修改条件（如"更换刻分"）时，不是修改当前Context，而是基于当前Context创建一个新的分叉Context。
* **类似Git**: 每次修改都是一次Commit，形成一个DAG（有向无环图）。

### 3.3.3 全局排盘会话 (`DivinationSession`) *[新规划]*

* **层级**: 最顶层，管理整个应用生命周期。
* **职责**:
  * 持有 `List<DivinationContext>`（多列排盘历史）。
  * **历史记录**: 允许用户回溯到任意节点的排盘状态。
  * **序列化**: 负责将整个排盘工作区保存为 JSON/数据库记录，以便下次打开恢复。

### 3.3.4 [待定] 分支对比机制 (Branching & Comparison [Pending])

*注: 此功能暂列为待定，将在核心流程稳定后考虑实施。*

为了实现用户提出的"对比"需求（如皇极经世中"1111"与"2222"的对比），我们采用**分支（Forking）**模型：

1. **节点分叉 (Node Forking)**:
    * 当排盘流程遇到需要用户决策的节点（如：输入皇极数、选择刻分）时，系统记录当前状态快照。
    * 用户选择"1111" -> 生成 **Branch A**。
    * 用户希望对比"2222" -> 系统基于决策前的快照分叉，生成 **Branch B**。
2. **根条件对比 (Root Comparison)**:
    * 如果用户修改了八字（根条件），这相当于在根节点进行了分叉。
3. **UI表现 - 平行宇宙视图 (Parallel Universe View)**:
    * UI将不再是单列流，而是**多列横向滚动容器**。
    * **Column 1**: 展示 "Branch A (1111)" 的完整推演流。
    * **Column 2**: 展示 "Branch B (2222)" 的完整推演流。
    * **同步滚动**: 支持锁定滚动，方便用户比对同一行（同一算法）的输出差异。

## 4. 执行计划

### 阶段 1: Context 与 协调器设置

1. **定义 `DivinationContext`**: 创建不可变容器。
2. **实现 `DivinationOrchestrator`**:
    * 依赖注入所有16个策略。
    * `execute(Context)` 方法运行层级 1 策略。

### 阶段 2: 适配器实现

1. **创建适配器**: 为16个策略中的每一个编写适配器，将其 `BaseNumberModel` 输出转换为 `DivinationResult`。
    * *挑战*: `YuanTangBaseNumberModel` 和 `TaiXuanBaseNumberModel` 包含非常丰富的数据（大运、爻详情）。适配器需要合理地将其扁平化以用于摘要视图，同时将原始数据保留在 `metadata` 中用于"详情视图"。

### 阶段 3: UI 实现 (`UnifiedPage`)

1. **`UnifiedDivinationPage`**: 新的顶层页面。
2. **`ResultStream` Widget**: 垂直列表，随着结果完成而异步显示。
3. **基础卡片**:
    * `SummaryCard`: 显示目前找到的所有条文编号摘要。
    * `DetailCard`: 每个策略的可展开卡片。

### 阶段 4: 优化 (重构层级 2)

1. **重构层级 2 算法调用**:
    * 修改 `XianHoutianQuShu`, `LiuYaoGanZhiHe` 等，使其可选接受 `YuanTangResult` 或 `Gua` 对象输入，防止重新计算基础元堂逻辑。

## 5. 特定算法需求 (来自PRD)

* **太玄**: 必须并排显示 "年干阴阳" 和 "传统内外卦" 两种结果。
* **元堂**: 必须可视化大运（时间轴）并清晰标记8种不同的条文推导方法。
* **公式透明度**: UI必须能够显示数字是*如何*推导出来的（例如 "基础数 3387 + 96 = 3483"）。

## 6. 公式管理更新

* *当前状态*: 硬编码在 Dart 中。
* *计划*: V1版本保持硬编码。仅在需要不通过应用商店发布更新即可动态调整时，才迁移到 JSON/外部配置。

## 7. 风险与缓解措施

* **性能**: 在UI线程上运行16个复杂算法（包括一些带有繁重循环的算法）可能会导致掉帧。
  * *缓解*: 使用 `compute()` isolate 进行协调器的繁重计算。

## 8. UI/UX 设计原则 (Design Guidelines)

针对"条文展示"及"会话管理"，我们需要遵循以下设计原则以确保专业感与易用性并存：

### 8.1 条文展示 (Strip Text Display)

* **排版美学**:
  * **字体区分**: 条文诗句使用**衬线体 (宋体/楷体)**以体现传统韵味；分析解释使用**无衬线体**以确保清晰易读。
  * **留白 (Whitespace)**: 诗句周围应有充足留白，营造"雅致"感，避免拥挤。
  * **竖排/横排**: 虽传统为竖排，但考虑到移动端阅读习惯，推荐**主体横排**，但标题或装饰性文字可采用竖排。
* **8.1.1 条文列表容器 (Strip List Container)**:
  * **时间轴集成 (Timeline Integration)**: 对于"元堂大运"等与时间强相关的条文，列表左侧应有一条贯穿的**时间轴**，将条文挂载在具体的年龄段（如"14-23岁"）上。
  * **分组视图 (Grouped View)**: 即使在同一策略下，也应通过轻微的分割线或小标题将条文按来源分组（如"基础数"、"加减数"、"变卦数"）。
  * **视觉韵律 (Visual Rhythm)**: 避免"文字墙"。交替使用**高亮卡片**（针对吉/凶明显的关键条文）和**紧凑行**（针对普通条文），创造阅读的节奏感。
* **信息层级**:
  * **核心**: 条文编号 (如 `1234`) 应作为视觉锚点，高亮显示。
  * **原文**: 诗句应居中或醒目展示。
  * **注解**: 现代文解释应作为二级信息，可默认折叠或以较淡颜色显示。
* **视觉隐喻**: 使用纸张纹理、水墨晕染等微质感背景，但不要干扰文字阅读。

### 8.2 复杂信息管理 (Information Management)

* **渐进式披露 (Progressive Disclosure)**:
  * 默认只显示"核心结论"（如：吉/凶，关键条文）。
  * 用户点击"详情"后，再展开显示具体的推导过程（如：元堂 -> 先天 -> 数序）。
* **平行宇宙导航**:
  * 在多列对比模式下，列头 (Column Header) 必须清晰标示该列的**唯一条件**（如："刻分：子" vs "刻分：丑"）。
  * **差异高亮**: 如果可能，自动高亮两列中**不同**的条文，帮助用户快速聚焦差异。

### 8.3 交互反馈

* **流式加载 (Streaming)**: 算法计算过程应该有视觉反馈（如加载波纹、文字逐行出现），减少等待焦虑，增加"推演"的仪式感。
* **因果关联**: 当用户点击某个条文时，UI应能高亮显示它是**由哪些条件**（如：日柱+元堂）推导出来的，建立数据的透明度。

## 9. UI 验收标准 (UI Acceptance Criteria)

UI 设计的交付与验收将基于 `docs/one_click/gui/` 目录下的 HTML/CSS 模版。开发人员将根据这些模版实现 Flutter 组件。
