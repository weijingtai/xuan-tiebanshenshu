# 太玄取数法 (TaiXuanFourZhuStrategy) 算法审查

## 1. 算法概述

**名称**：太玄取数法（1）
**类名**：`TaiXuanFourZhuStrategy`
**文件路径**：`lib/service/strategy/tai_xuan_four_zhu_strategy.dart`
**描述**：排四柱天干地支分别配卦，纳甲配太玄数，上下卦数相配组成四位数，各加减96生成条文列表。

## 2. 输入参数

该算法需要以下参数（通过 `TaiXuanFourZhuStrategyParams` 传入）：

* `eightChars` (`EightChars`): 四柱信息。
* `naJiaMethod` (`TaiXuanNaJiaMethod`): 纳甲方法选择。
  * `yearGanYinYang`: 年干阴阳纳甲（默认）。
  * `innerOuterGua`: 传统内外卦纳甲。

## 3. 计算流程

1. **排四柱**：遍历年、月、日、时四柱。
2. **天干地支配卦**：
    * 天干 -> 上卦 (`Constants.tianGanGuaMapper`)。
    * 地支 -> 下卦 (`Constants.diZhiGuaMapper`)。
3. **纳甲与配数**：
    * **策略选择**：
        * 若选 `yearGanYinYang`：根据年干阴阳，决定使用 `Constants.yangGuaYaoTianGan` 或 `yinGuaYaoTianGan` 进行纳甲。
        * 若选 `innerOuterGua`：内卦用 `innerGuaYaoTianGan`，外卦用 `outerGuaYaoTianGan`。
    * **太玄数计算**：
        * 每爻取纳甲天干数 (`taiXuanGanNumberMapper`) + 纳支数 (`taiXuanZhiNumberMapper`)。
        * *特殊规则*：若和为 10，则不计入总和。
4. **计算基础数**：
    * **千百位**：上卦（四五上爻）有效太玄数之和。
    * **十个位**：下卦（初二三爻）有效太玄数之和。
    * *公式*：`baseNumber = 上卦和 * 100 + 下卦和`。
5. **生成条文列表**：
    * 标准配置：基础数分别 `±96`, `±192`, `±384`, `±768`。

## 4. 关键逻辑代码

```dart
// 过滤规则：和为10则不用
final sum = ganNum + zhiNum;
if (sum != 10) {
  lowerSum += sum;
}

// 计算基础数：上卦和作千百位，下卦和作十个位
final baseNumber = upperSum * 100 + lowerSum;
```

## 5. 依赖数据

* `Constants.taiXuanGanNumberMapper`: 天干太玄数 (甲9, 乙8...)
* `Constants.taiXuanZhiNumberMapper`: 地支太玄数 (子9, 丑8...)
* `Constants.yangGuaYaoTianGan` / `yinGuaYaoTianGan`: 纳甲映射表

## 6. 公式/资源管理

* **公式类型**：硬编码逻辑。
* **资源文件**：无外部 JSON 依赖。

## 7. 审查结论

* **完整性**：涵盖了复杂的纳甲变体逻辑。
* **灵活性**：通过 `TaiXuanNaJiaMethod` 枚举支持不同流派的纳甲规则。
* **特殊处理**：正确实现了"和为十不用"的太玄数核心判定规则。
