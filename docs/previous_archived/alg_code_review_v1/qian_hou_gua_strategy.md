# 前后卦取数法 (QianHouGuaStrategy) 算法审查

## 1. 算法概述

**名称**：前后卦取数法
**类名**：`QianHouGuaStrategy`
**文件路径**：`lib/service/strategy/qian_hou_gua_strategy.dart`
**描述**：将四柱分为两组，年月柱组合为"前卦"，日时柱组合为"后卦"，分别使用加则法计算基础数，并进行递增/递减扩展。

## 2. 输入参数

该算法需要以下参数（通过 `QianHouGuaStrategyParams` 传入）：

* `eightChars` (`EightChars`): 四柱信息。

## 3. 计算流程

1. **取太玄数**：
    * 获取年、月、日、时四柱干支的太玄数 (`Constants.taiXuanGan/ZhiNumberMapper`)。
2. **前卦定局（年月柱）**：
    * **上卦**：(年干太玄数 + 年支太玄数) % 8。
    * **下卦**：(月干太玄数 + 月支太玄数) % 8。
    * *注*：余数为0视作8。根据结果查后天卦名 (`numberHouGuaMapper`)。
3. **后卦定局（日时柱）**：
    * **上卦**：(日干太玄数 + 日支太玄数) % 8。
    * **下卦**：(时干太玄数 + 时支太玄数) % 8。
4. **计算基础数**：
    * 分别对前卦和后卦调用 `TiaowenCalculator.getTiaowenNumberByJiaZe`（即加则法：上卦后天数*1000 + 六爻纳支数和 - 下卦后天数）。
5. **生成条文列表**：
    * **前卦**：递增96四次 (`+0, +96, +192, +288, +384`)。
    * **后卦**：递减96四次 (`-0, -96, -192, -288, -384`)。

## 4. 关键逻辑代码

```dart
// 前卦定局公式
int yearHouTianNum = (yearGanNum + yearZhiNum) % 8;
int monthHouTianNum = (monthGanNum + monthZhiNum) % 8;
final qianGuaName = Enum64Gua.getBy8Gua(
    constants.numberHouGuaMapper[yearHouTianNum]!, 
    constants.numberHouGuaMapper[monthHouTianNum]!
);

// 基础数计算（复用加则法）
final qianGuaBaseNumber = TiaowenCalculator.getTiaowenNumberByJiaZe(qianGuaName);
```

## 5. 依赖数据

* `Constants.taiXuanGan/ZhiNumberMapper`: 太玄数。
* `Constants.numberHouGuaMapper`: 数字 -> 后天卦 (1坎, 2坤...)。
* `TiaowenCalculator`: 提供了通用的加则法计算。

## 6. 公式/资源管理

* **公式类型**：独特的"干支和模8"起卦法 + 标准加则法。
* **资源文件**：无外部 JSON 依赖。

## 7. 审查结论

* **起卦法独特**：这是唯一一个将干支太玄数相加取模来起卦的策略，不同于直接的干支配卦。
* **组合逻辑**：将四柱分为两组（年月vs日时）分别计算，逻辑结构清晰。
* **扩展方向**：前卦递增、后卦递减的扩展方式非常有特色。
