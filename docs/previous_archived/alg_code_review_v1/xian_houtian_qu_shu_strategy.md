# 先后天卦取数法 (XianHoutianQuShuStrategy) 算法审查

## 1. 算法概述

**名称**：先后天卦取数法
**类名**：`XianHoutianQuShuStrategy`
**文件路径**：`lib/service/strategy/xian_houtian_qu_shu_strategy.dart`
**描述**：基于元堂卦的计算结果，重算先天卦和后天卦的基础数，并进行大幅度的倍数扩展。

## 2. 输入参数

该算法需要以下参数（通过 `XianHoutianQuShuStrategyParams` 传入）：

* `eightChars`, `gender`, `threeYuan` 等：用于计算或复用元堂卦信息。
* `yuanTangInfo`: 可选，如果已有元堂卦结果，可直接复用，避免重复计算。

## 3. 计算流程

1. **获取元堂卦信息**：
    * 复用传入的 `yuanTangInfo` 或者重新计算。
2. **提取双卦**：
    * 提取**先天卦** (`getXiantianGua`)。
    * 提取**后天卦** (`getHoutianGua`)。
3. **计算先天基础数**：
    * `thousands`: 上卦先天数 (`xianTianGuaNumberMapper`)。
    * `hundreds`: 下卦先天数。
    * `tens`: 互卦的上卦先天数。
    * `ones`: 互卦的下卦先天数。
    * *公式*：四位拼接法 `千百十个`。
4. **计算后天基础数**：
    * 逻辑同上，但使用**后天数** (`houTianGuaNumberMapper`)。
5. **辅助计算（纳甲参考）**：
    * 尽管主要使用四位拼接法，但代码中也保留了对先天/后天卦进行六爻纳甲、计算干支太玄数之和的逻辑 (`_calculateLiuYaoSum`)，作为参考数据存在。
6. **生成条文列表**：
    * 对先天基础数和后天基础数，分别进行 `±48 × [2, 4, 8, 16]` 的扩展。
    * 即：`±96, ±192, ±384, ±768`。

## 4. 关键逻辑代码

```dart
// 先天数四位拼接
final thousands = constants.xianTianGuaNumberMapper[upper]!;
final hundreds = constants.xianTianGuaNumberMapper[lower]!;
final tens = constants.xianTianGuaNumberMapper[huUpper]!;
final ones = constants.xianTianGuaNumberMapper[huLower]!;
return thousands * 1000 + hundreds * 100 + tens * 10 + ones;
```

## 5. 依赖数据

* `YuanTangCalculator`: 核心依赖。
* `Constants.xianTianGuaNumberMapper`: 先天卦数。
* `Constants.houTianGuaNumberMapper`: 后天卦数。

## 6. 公式/资源管理

* **公式类型**：四位拼接法（不同于元堂策略中的加则法），且包含大范围倍数扩展。
* **资源文件**：无外部 JSON 依赖。

## 7. 审查结论

* **继承与复用**：继承自 `YuanTangBasedStrategy`，有效复用了元堂卦的复杂计算逻辑。
* **策略差异**：虽然源头都是元堂卦，但此策略使用了独特的"四位拼接"取数法，与 `YuanTangStrategy` 中的取数逻辑不同，互为补充。
* **数据完整性**：除了主结果，还计算了六爻纳甲详情作为参考 (`model.xiantianYaoTianGanList` 等)，信息量大。
