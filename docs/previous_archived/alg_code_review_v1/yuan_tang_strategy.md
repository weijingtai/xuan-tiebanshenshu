# 元堂卦取数法 (YuanTangStrategy) 算法审查

## 1. 算法概述

**名称**：元堂卦取数法
**类名**：`YuanTangStrategy`
**文件路径**：`lib/service/strategy/yuan_tang_strategy.dart`
**描述**：元堂卦是极其复杂的一套体系，包含天地卦、先天卦、后天卦、互卦的生成，以及通过加则、纳甲太玄、本互等8种方法生成条文，并支持流年流月流日推演。

## 2. 输入参数

该算法需要以下参数（通过 `YuanTangStrategyParams` 传入）：

* `eightChars` (`EightChars`): 四柱信息。
* `gender` (`Gender`): 性别（男/女）。
* `threeYuan` (`YuanYunOrder`): 三元（上/中/下）。
* `birthAfterZhi` (`TwentyFourJieQi`): 出生节气（冬至/夏至）。
* `birthMonth` (`int`): 出生月份（1-12）。
* `monthType` (`YuanTangMonthType`): 月份类型（判定阴阳月）。
* `calanderType` (`CalanderType`): 历法类型。

## 3. 计算流程

1. **天地卦生成** (`YuanTangCalculator.generateTianDiGua`)：
    * 计算四柱天干数和、地支数和。
    * 计算奇数和（天数）、偶数和（地数）。
    * 模运算取余数，配成天卦和地卦。
2. **先天卦定局**：
    * 根据年份阴阳（结合三元）和性别，决定天卦和地卦谁在上谁在下，组成先天卦。
3. **元堂装卦与后天卦**：
    * 根据时辰阴阳和卦象阴阳爻数装配地支。
    * 确定"元堂爻"（动爻）。
    * 元堂爻变，上下卦互换，生成后天卦。
4. **互卦生成**：
    * 分别计算先天卦互卦、后天卦互卦。
5. **条文生成（全方位）**：
    * **加则法**：先天/后天。
    * **纳甲太玄数法**：先天/后天。
    * **本互法**：先天本互/后天本互。
    * **互取数列表**：基于本互数进行加减倍数扩展。
6. **流运系统**：
    * 支持**大运**（每爻管6/9年）推演。
    * 支持**流年**（每年一换）推演。
    * 支持**流月**推演。

## 4. 关键逻辑代码

```dart
// 元堂核心计算
final yuanTangInfo = YuanTangCalculator().calculate(...);

// 条文计算（8种方法）
final jiazeXiantian = TiaowenCalculator.getTiaowenNumberByJiaZe(xiantianGua);
final najiaTaixuanXiantian = TiaowenCalculator.getTiaowenNumberByTaixuan(xiantianGua);
final benhuXiantian = _calculateBenhuNumber(..., isXiantian: true);
// ...以及对应的后天版本
```

## 5. 依赖数据

* `YuanTangCalculator`: 封装了复杂的天地卦、元堂爻计算逻辑。
* `TiaowenCalculator`: 封装了通用的条文计算公式。

## 6. 公式/资源管理

* **公式类型**：高度封装的逻辑类。
* **资源文件**：
  * 流年/流月计算依赖于硬编码的阴阳变换规则。
  * 未发现外部 JSON 依赖。

## 7. 审查结论

* **复杂度最高**：这是目前系统中逻辑最复杂的策略，包含完整的流运系统。
* **数据结构完善**：`YuanTangInfo` 包含了完整的中间态（先天、后天、大运、流年），非常适合用于UI的深度展示。
* **独立性**：虽然依赖 `YuanTangCalculator`，但在 Strategy 层做了很好的封装，对外暴露统一的 `YuanTangModelResult`。
