# 先后天八卦加则法 (XianHoutianJiaZeStrategy) 算法审查

## 1. 算法概述

**名称**：先后天八卦加则法
**类名**：`XianHoutianJiaZeStrategy`
**文件路径**：`lib/service/strategy/xian_houtian_jia_ze_strategy.dart`
**描述**：基于元堂卦的先天卦和后天卦，分别使用加则法计算基础数，并进行递增/递减扩展。

## 2. 输入参数

该算法需要以下参数（通过 `XianHoutianJiaZeStrategyParams` 传入）：

* `eightChars`, `gender`, `threeYuan` 等：用于计算或复用元堂卦信息。
* `yuanTangInfo`: 可选，复用元堂卦结果。

## 3. 计算流程

1. **获取元堂卦信息**：
    * 复用传入的 `yuanTangInfo` 或者重新计算。
2. **提取双卦**：
    * 提取**先天卦** (`getXiantianGua`)。
    * 提取**后天卦** (`getHoutianGua`)。
3. **计算基础数**：
    * **先天卦加则法**：调用 `TiaowenCalculator.getTiaowenNumberByJiaZe(xiantianGua)`。
    * **后天卦加则法**：调用 `TiaowenCalculator.getTiaowenNumberByJiaZe(houtianGua)`。
4. **生成条文列表**：
    * **先天卦**：递增96四次 (`+0, +96, +192, +288, +384`)。
    * **后天卦**：递减96四次 (`-0, -96, -192, -288, -384`)。

## 4. 关键逻辑代码

```dart
// 加则法计算
final xiantianBaseNumber = TiaowenCalculator.getTiaowenNumberByJiaZe(xiantianGua);
final houtianBaseNumber = TiaowenCalculator.getTiaowenNumberByJiaZe(houtianGua);

// 条文扩展
final xiantianConfig = GenericTiaoWenCalculationConfig.increment96x4();
final houtianConfig = GenericTiaoWenCalculationConfig.decrement96x4();
```

## 5. 依赖数据

* `YuanTangCalculator`: 核心依赖。
* `TiaowenCalculator`: 提供通用的加则法计算。

## 6. 公式/资源管理

* **公式类型**：标准加则法（`上卦*1000 + 爻支和 - 下卦`） + 固定的递增减策略。
* **资源文件**：无外部 JSON 依赖。

## 7. 审查结论

* **组合策略**：又一个基于元堂卦的变体策略。与 `XianHoutianQuShuStrategy`（四位拼接）和 `LiuYaoGanZhiHeStrategy`（六爻干支和）相比，本策略使用的是最经典的"加则法"来处理元堂卦生成的先天/后天卦。
* **扩展对称性**：先天递增、后天递减的对称设计，与 `QianHouGuaStrategy` 的扩展逻辑一致。
