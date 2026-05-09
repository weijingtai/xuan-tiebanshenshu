# 太玄四柱交互式策略 (TaiXuanFourZhuInteractiveStrategy) 算法审查

## 1. 算法概述

**名称**：太玄四柱交互式策略
**类名**：`TaiXuanFourZhuInteractiveStrategy`
**文件路径**：`lib/service/strategy/tai_xuan_four_zhu_interactive_strategy.dart`
**描述**：这是标准太玄四柱算法的**交互式版本**。它继承自 `BaseInteractiveStrategy`，并通过 `InteractiveSession` 管理用户的多步选择流程（如确认四柱、选择计算方法、选择卦象映射等），最终调用标准的 `TaiXuanFourZhuStrategy` 完成计算。

## 2. 输入参数

该算法需要以下参数（通过 `TaiXuanFourZhuInteractiveStrategyParams` 传入）：

* `eightChars`: 四柱信息。
* `interactiveConfig`: 交互式配置。
* `allowFourZhuModification`: 是否允许修改四柱（默认true）。
* `allowCalculationMethodSelection`: 是否允许选择计算方法（默认true）。
* `allowGuaMappingSelection`: 是否允许选择卦象映射（默认false）。

## 3. 交互流程（Steps）

1. **确认四柱信息** (`four_zhu_confirmation`)：
    * 展示原始四柱，并允许用户从生成的变体中选择（尽管目前变体生成逻辑为空）。
2. **选择计算方法** (`calculation_method`)：
    * 提供"标准太玄取数法"和"增强太玄取数法"供选择（如果允许选择）。
3. **选择卦象映射** (`gua_mapping`)：
    * 提供"标准卦象映射"供选择（如果允许选择）。
4. **完成计算**：
    * 根据用户在前面步骤中的选择，配置并执行最终的计算。

## 4. 关键逻辑代码

```dart
// 启动会话
Future<InteractiveSession> startSession(...) async {
  // 创建会话并添加第一步
  final firstStep = await _createFourZhuConfirmationStep(...);
  // ...
}

// 完成计算
Future<TaiXuanFourZhuInteractiveStrategyResult> completeCalculation(session) async {
  // 提取用户选择
  final selectedEightChars = _extractSelectedEightChars(session);
  // 调用标准策略
  final standardResult = _standardStrategy.calculate(...);
  // 封装结果
  return TaiXuanFourZhuInteractiveStrategyResult(...);
}
```

## 5. 依赖数据

* `TaiXuanFourZhuStrategy`: 核心计算复用了标准策略。
* `InteractiveSession`: 用于管理状态和步骤。

## 6. 特殊机制

* **兼容性**：提供了 `calculate` 方法的非交互式实现，直接使用默认参数调用标准策略，确保了接口的向下兼容性。
* **分页支持**：`getInfiniteList` 方法支持对生成的条文列表进行分页查询。
* **适配器**：`TaiXuanFourZhuInteractiveStrategyResult` 提供了 `toBaseNumberModelResult` 和 `fromBaseNumberModelResult` 方法，方便与系统其他部分（如UI展示）进行数据转换。

## 7. 审查结论

* **交互式架构典范**：这是系统中实现得最完整的交互式策略，展示了如何将一个静态算法包装成一个多步向导。
* **逻辑解耦**：将"交互流程"与"核心计算"完全解耦，核心计算复用了 `TaiXuanFourZhuStrategy`，避免了代码重复。
* **扩展性**：通过 `TiaoWenCandidate` 和 `InteractiveSessionStep`，可以非常方便地添加新的选择步骤或选项。
