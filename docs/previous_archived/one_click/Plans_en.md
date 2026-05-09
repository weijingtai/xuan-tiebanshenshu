# Unified Divination System - Implementation Plans (v2)

## 1. Vision & Architecture

The goal is to transition from a **Toolbox** model (discrete, isolated tools) to a **Unified Pipeline** model (One-Click Divination). Users provide `EightChars` (and optional context like Gender/Yuan), and the system orchestrates 15+ algorithms to present a comprehensive report.

### 1.1 Core Components

* **`DivinationContext`**: Immutable state container holding:
  * **Input**: `EightChars`, `Gender`, `ThreeYuan`, `BirthAfterZhi`.
  * **Derived State**: `KeFen` (optional), `YuanHuiYunShi` (optional).
  * **Results**: A map of `StrategyID -> DivinationResult` for all executed strategies.
* **`DivinationOrchestrator`**: The workflow engine. It calculates the dependency graph of strategies and executes them. It handles:
  * **Standard Strategies**: Executed automatically in parallel where possible.
  * **Interactive Strategies**: Pauses execution to request user input (e.g., TaiXuanInteractive).
* **`UnifiedDivinationViewModel`**: Manages the UI state, user sessions, and history.

## 2. Algorithm Integration Strategy

Based on the Code Reviews (`docs/alg_code_review_v1/`) and Functional Requirements (`docs/normal_alg/`), the algorithms are categorized by dependency depth.

### Level 1: Foundation (Direct Dependencies)

*Dependencies: EightChars only*

1. **`DayGanZhiGuaStrategy`**: Uses Day Gan/Zhi.
2. **`FourZhuTianGanStrategy`**: Uses 4 Pillars' Gan. Formula: `Month*1000 + Day*100`.
3. **`ShengMingGuaCalculationStrategy`**: Uses Birth Year/Month.
4. **`GuaZhongStrategy`**: Handles "Sum=10" ambiguity with 3 plans.
5. **`BaGuaJiaZeStrategy`**: Standard BaGua JiaZe logic.
6. **`BaGuaGunStrategy`**: Generates 48 strip items.
7. **`SiMenFaStrategy`**: Complex generation of Ben/Hu/Bian/Cuo gua.
8. **`QianHouGuaStrategy`**: Splits 4 pillars into Qian/Hou.
9. **`TaiXuanFourZhuStrategy`** (Standard): Runs both `YearGanYinYang` and `InnerOuterGua` methods automatically.

### Level 2: Advanced (Derived/Complex Dependencies)

*Dependencies: EightChars + Shared Calculations (e.g., YuanTang)*
10. **`YuanTangStrategy`**: The heavyweight core. Calculates:
    *TianDi/XianTian/HouTian Gua.
    *   Dayun (Big Luck) cycles.
    *Strip extensions (+96x4).
11. **`XianHoutianQuShuStrategy`**:
    *   *Current Implementation*: Re-calculates YuanTang logic internally.
    **Target*: Should reuse `YuanTangResult` from the Context to avoid redundant calc.
12. **`LiuYaoGanZhiHeStrategy`**:
    *   *Target*: Should reuse `YuanTangResult` (XianTian/HouTian Gua) from Context.
13. **`XianHoutianJiaZeStrategy`**:
    *   *Target*: Should reuse `YuanTangResult`.
14. **`GuaYaoGanZhiHeStrategy`**: Similar dependency on basic Gua mappings.

### Level 3: Interactive

*Dependencies: User Input*
15. **`TaiXuanFourZhuInteractiveStrategy`**:
    *Allows user to manually correct/select `EightChars` or `Gua` mappings.
    *   *Integration*: The Orchestrator should detect this strategy and present a "Consultation Card" in the UI stream.

## 3. Data Model Standardization

To support the Unified View, all strategies must return results that implement `DivinationResult`.

```dart
abstract class DivinationResult {
  String get strategyId;
  String get title;
  List<DivinationItem> get items; // Unified item for display
}

class DivinationItem {
  final String label;   // e.g. "Year Pillar - Method A"
  final String content; // The strip number or text
  final List<String> tags; // e.g. ["YuanTang", "XianTian"]
  final Map<String, dynamic> metadata; // For drill-down details (Yao details, etc.)
}
```

**Action Item**: We need adapters for the existing `BaseNumberModelResult` (which is diverse) to this unified `DivinationResult`.

## 3.3 Session Management Mechanism

In this project, "Session" is not just a simple variable, but a layered management mechanism designed to support divination needs ranging from simple to complex:

### 3.3.1 InteractiveSession

* **Level**: Lowest level, targeting individual algorithms (e.g., TaiXuan Interactive).
* **Responsibility**: Records steps, user selections, and state transitions (Jump/Undo) within a single algorithm execution.
* **Persistence**: Temporary storage, archived upon completion of divination.

### 3.3.2 DivinationContext

* **Level**: Core level, representing a snapshot of a complete divination calculation state.
* **Responsibility**:
  * Acts as an Immutable Snapshot.
  * **Forking Mechanism**: When users modify conditions (e.g., "Change KeFen"), instead of modifying the current Context, a new forked Context is created based on the current one.
* **Git-like**: Every modification is a Commit, forming a DAG (Directed Acyclic Graph).

### 3.3.3 DivinationSession (Global) *[New Plan]*

* **Level**: Top level, managing the entire application lifecycle.
* **Responsibility**:
  * Holds `List<DivinationContext>` (multi-column divination history).
  * **History**: Allows users to backtrack to the divination state of any node.
  * **Serialization**: Responsible for saving the entire divination workspace as JSON/Database records for restoration upon next opening.

### 3.3.4 [Pending] Branching & Comparison Mechanism

*Note: This feature is currently listed as pending and will be considered for implementation after the core flow is stable.*

To realize the user's "Comparison" requirement (e.g., comparing "1111" vs "2222" in HuangJi JingShi), we adopt a **Forking** model:

1. **Node Forking**:
    * When the divination flow encounters a node requiring user decision (e.g., inputting HuangJi number, selecting KeFen), the system records a snapshot of the current state.
    * User selects "1111" -> Generates **Branch A**.
    * User wishes to compare "2222" -> System forks based on the snapshot before the decision, generating **Branch B**.
2. **Root Comparison**:
    * If the user modifies the EightChars (Root condition), this is equivalent to forking at the root node.
3. **UI Representation - Parallel Universe View**:
    * The UI will no longer be a single-column stream, but a **Multi-column Horizontally Scrolling Container**.
    * **Column 1**: Displays the complete deduction flow of "Branch A (1111)".
    * **Column 2**: Displays the complete deduction flow of "Branch B (2222)".
    * **Synchronized Scrolling**: Supports locked scrolling to facilitate user comparison of output differences in the same row (same algorithm).

## 4. Execution Plan

### Phase 1: Context & Orchestrator Setup

1. **Define `DivinationContext`**: Create the immutable container.
2. **Implement `DivinationOrchestrator`**:
    * Dependency Injection of all 16 strategies.
    * `execute(Context)` method that runs Level 1 strategies.

### Phase 2: Adapter Implementation

1. **Create Adaptors**: Write adapters for each of the 16 strategies to convert their `BaseNumberModel` output into `DivinationResult`.
    * *Challenge*: `YuanTangBaseNumberModel` and `TaiXuanBaseNumberModel` have very rich data (Dayun, YaoDetails). The adapter needs to flatten this sensibly for the summary view while keeping the raw data in `metadata` for the "Detail View".

### Phase 3: UI Implementation (`UnifiedPage`)

1. **`UnifiedDivinationPage`**: A new top-level page.
2. **`ResultStream` Widget**: A vertical list showing results as they finish (Async).
3. **Basic Cards**:
    * `SummaryCard`: Shows the summary of strip numbers found so far.
    * `DetailCard`: Expandable card for each strategy.

### Phase 4: Optimization (Refactor Level 2)

1. **Refactor Level 2 Algorithm Calls**:
    * Modify `XianHoutianQuShu`, `LiuYaoGanZhiHe`, etc., to optionally accept a `YuanTangResult` or `Gua` object input, preventing re-calculation of the basic YuanTang logic.

## 5. Specific Algorithm Requirements (from PRD)

* **TaiXuan**: Must display BOTH "YearGanYinYang" and "InnerOuterGua" results side-by-side.
* **YuanTang**: Must visualize the Dayun (Timeline) and clearly label the 8 different strip number derivation methods.
* **Formula Transparency**: The UI must be able to show *how* a number was derived (e.g., "Base 3387 + 96 = 3483").

## 6. Formula Management Update

* *Current Status*: Hardcoded in Dart.
* *Plan*: Keep hardcoded for V1. Move to JSON/External Config only if dynamic updates are required without app store releases.

## 7. Risks & Mitigation

* **Performance**: Running 16 complex algos (including some with heavy loops) on the UI thread might drop frames.
  * *Mitigation*: Use `compute()` isolate for the Orchestrator's heavy lifting.

## 8. UI/UX Design Guidelines

To ensure a premium and professional experience, especially for "Strip Text Display" and "Session Management", we adhere to the following principles:

### 8.1 Strip Text Display (Tiao Wen)

* **Typography & Aesthetics**:
  * **Font Distinction**: Use **Serif fonts (SongTi/KaiTi)** for the poetic verses to evoke traditional charm. Use **Sans-serif** for modern analysis to ensure readability.
  * **Whitespace**: Generous whitespace around the poem to create an "elegant" (Zen) atmosphere.
  * **Orientation**: Primary text should be **horizontal** for mobile readability, with vertical text reserved for titles or decorative elements.
* **Information Hierarchy**:
  * **Anchor**: The Strip Number (e.g., `1234`) is the visual anchor and should be prominent (e.g., large, indigo).
  * **Body**: The poem is the center of attention.
  * **Annotation**: Modern explanations are secondary; display them in lighter text or collapsible sections.
* **Visual Metaphor**: Subtle paper textures or ink wash backgrounds (Shan Shui) to ground the design in culture without skeuomorphic clutter.

### 8.2 Information Management

* **Progressive Disclosure**: Show "Key Conclusions" first (e.g., Good/Bad). Reveal derivation details (YuanTang -> Hexagram) only upon interaction.
* **Parallel Universe Navigation**:
  * Clearly label column headers with the **differentiating condition** (e.g., "KeFen: Zi" vs "KeFen: Chou").
  * **Diff Highlighting**: Visually distinguish rows that differ between branches.

### 8.3 Interactive Feedback

* **Streaming**: Use staggered animations (fade-in, slide-up) for results to simulate the "flow" of calculation.
* **Causality**: Interactive elements should link results back to their source conditions (e.g. tapping a strip highlights the 'Day Pillar' that generated it).

## 9. UI Acceptance Criteria

The UI design delivery and acceptance will be based on the HTML/CSS templates located in the `docs/one_click/gui/` directory. Developers will implement the Flutter components according to these templates.
