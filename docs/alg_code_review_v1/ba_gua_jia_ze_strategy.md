# 八卦加则取数法 (BaGuaJiaZeStrategy) 算法审查

## 1. 算法概述

**名称**：八卦加则取数法
**类名**：`BaGuaJiaZeStrategy`
**文件路径**：`lib/service/strategy/ba_gua_jia_ze_strategy.dart`
**描述**：排四柱天干地支分别配卦，装配六爻地支，通过特定公式（上卦数×1000 + 总数 - 下卦数）计算条文数。每柱采用两种方法（爻序法、纳甲法）计算，共产生8个结果。

## 2. 输入参数

该算法需要以下参数（通过 `BaGuaJiaZeStrategyParams` 传入）：

* `eightChars` (`EightChars`): 四柱信息。

## 3. 计算流程

1. **排四柱**：遍历年、月、日、时四柱。
2. **干支配卦**：
    * 天干 -> 上卦 (`Constants.tianGanGuaMapper`)。
    * 地支 -> 下卦 (`Constants.diZhiGuaMapper`)。
3. **计算分支**：每柱分别执行"爻序法"和"纳甲法"。
    * **分支A：爻序法**
        * 阳爻依次配：子、寅、辰、午、申、戌。
        * 阴爻依次配：丑、卯、巳、未、酉、亥。
    * **分支B：纳甲法**
        * 使用传统六爻纳甲规则（不区分年干阴阳）。
        * 下卦纳支：初、二、三爻。
        * 上卦纳支：四、五、上爻。
4. **六爻配数**：
    * 将每爻配到的地支转化为数字 (`Constants.yaoDiZhiNumberMapper`) 并求和 (`sum`)。
5. **计算基础数**：
    * `upperNum`: 上卦后天数 (`Constants.houGuaNumberMapper`)。
    * `lowerNum`: 下卦后天数 (`Constants.houGuaNumberMapper`)。
    * *公式*：`baseNumber = upperNum * 1000 + sum - lowerNum`。
6. **生成条文列表**：
    * 不扩展，直接返回基础数。

## 4. 关键逻辑代码

```dart
// 核心计算公式
final baseNumber = upperNum * 1000 + sum - lowerNum;

// 爻序法配地支逻辑
if (yao.yinYang == YinYang.YANG) {
  diZhi = yangDiZhi[yangIndex++];
} else {
  diZhi = yinDiZhi[yinIndex++];
}
```

## 5. 依赖数据

* `Constants.yaoDiZhiNumberMapper`: 地支 -> 数字 (子1, 丑2...)
* `Constants.houGuaNumberMapper`: 后天卦数

## 6. 公式/资源管理

* **公式类型**：硬编码逻辑。
* **资源文件**：无外部 JSON 依赖。

## 7. 审查结论

* **多策略并行**：在同一策略类中同时实现了两种不同的取数分支（爻序/纳甲），并合并输出。
* **公式独特性**：使用了独特的三段式公式 `A*1000 + B - C`。
* **数据丰富性**：结果模型 (`BaGuaJiaZeBaseNumberModel`) 包含了详细的中间数据（爻的和、公式字符串等），便于UI展示。
