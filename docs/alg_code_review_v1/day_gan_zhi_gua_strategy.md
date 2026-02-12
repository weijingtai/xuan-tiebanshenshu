# 日柱变卦取数法 (DayGanZhiGuaStrategy) 算法审查

## 1. 算法概述

**名称**：日柱变卦取数法
**类名**：`DayGanZhiGuaStrategy`
**文件路径**：`lib/service/strategy/day_gan_zhi_gua_strategy.dart`
**描述**：以日干为下卦、日支为上卦组成基本卦，计算互卦，结合后天和先天卦数得到条文编号。

## 2. 输入参数

该算法需要以下参数（通过 `DayGanZhiGuaStrategyParams` 传入）：

* `dayGanZhi` (`JiaZi`): 日柱的干支信息。

## 3. 计算流程

1. **提取日柱**：从输入的 `dayGanZhi` 获取日干和日支。
2. **组成基本卦**：
    * **下卦**：由日干决定（映射关系见 `Constants.tianGanGuaMapper`）。
    * **上卦**：由日支决定（映射关系见 `Constants.diZhiGuaMapper`）。
    * *注*：此步骤生成了"基本卦" (`PureSixYaoGua`)。
3. **计算互卦**：
    * 基于"基本卦"计算其互卦。互卦通过取基本卦的二三四爻为下卦，三四五爻为上卦组成。
4. **计算基本数**：
    * **千位**：基本卦的上卦对应的**后天数**。
    * **百位**：基本卦的下卦对应的**后天数**。
    * **十位**：互卦的上卦对应的**先天数**。
    * **个位**：互卦的下卦对应的**先天数**。
    * *公式*：`千位 * 1000 + 百位 * 100 + 十位 * 10 + 个位`。
5. **计算条文编号**：
    * 基于计算出的基本数，支持多种配置进行扩展（如 ±1000, ±500 等）。默认配置为 `[0, 1000]`，即返回 `基本数` 和 `基本数 + 1000`。

## 4. 关键逻辑代码

```dart
// 计算基本数逻辑
static int _calculateBaseNumber(Enum64Gua baseGua, Enum64Gua huGua) {
  final int firstUp = Constants.houGuaNumberMapper[baseGua.top]!;    // 后天数
  final int firstDown = Constants.houGuaNumberMapper[baseGua.bottom]!; // 后天数

  final int secondUp = Constants.xianGuaNumberMapper[huGua.top]!;    // 先天数
  final int secondDown = Constants.xianGuaNumberMapper[huGua.bottom]!; // 先天数

  return int.parse('$firstUp$firstDown$secondUp$secondDown');
}
```

## 5. 依赖数据

* `Constants.tianGanGuaMapper`: 天干 -> 八卦
* `Constants.diZhiGuaMapper`: 地支 -> 八卦
* `Constants.houGuaNumberMapper`: 八卦 -> 后天数
* `Constants.xianGuaNumberMapper`: 八卦 -> 先天数

## 6. 公式/资源管理

* **公式类型**：硬编码逻辑。
* **资源文件**：无外部 JSON 依赖。

## 7. 审查结论

* **完整性**：算法逻辑完整，涵盖了从起卦到取数的全过程。
* **可维护性**：核心映射逻辑依赖于 `Constants`，解耦良好。
* **扩展性**：支持通过 `TiaoWenCalculationConfig` 扩展条文生成规则。
