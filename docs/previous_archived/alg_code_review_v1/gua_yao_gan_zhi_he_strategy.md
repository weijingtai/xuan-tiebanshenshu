# 卦爻干支和数法 (GuaYaoGanZhiHeStrategy) 算法审查

## 1. 算法概述

**名称**：卦爻干支和数法
**类名**：`GuaYaoGanZhiHeStrategy`
**文件路径**：`lib/service/strategy/gua_yao_gan_zhi_he_strategy.dart`
**描述**：将四柱干支配卦，对每一卦进行纳甲，计算每爻的太玄数之和（过滤和为10的爻），最后将上卦和与下卦和组合成基础数。

## 2. 输入参数

该算法需要以下参数（通过 `GuaYaoGanZhiHeStrategyParams` 传入）：

* `eightChars` (`EightChars`): 四柱信息。
* `naJiaMethod` (`GuaYaoGanZhiHeNaJiaMethod`): 纳甲方法。
  * `yearGanYinYang`: 年干阴阳纳甲（配合传统内外卦纳支）。
  * `innerOuterGua`: 传统内外卦纳甲。

## 3. 计算流程

1. **排四柱**：遍历年、月、日、时四柱。
2. **干支配卦**：
    * 天干 -> 上卦 (`Constants.tianGanGuaMapper`)。
    * 地支 -> 下卦 (`Constants.diZhiGuaMapper`)。
    * 组合成 64 卦。
3. **纳甲配数**：
    * **策略选择**：
        * `yearGanYinYang`: 下卦干用 `innerGuaYaoTianGan`，上卦干用 `outerGuaYaoTianGan`；**地支统一用 `najiaZhuangGua` (即传统纳支)**。
        * `innerOuterGua`: 干支均用传统六爻装卦法 (`SixYaoCalculator`)。
4. **太玄数求和与过滤**：
    * 遍历 6 爻。
    * 每爻：`sum = 纳干太玄数 + 纳支太玄数`。
    * **核心过滤**：若 `sum == 10`，则该爻不计入总数。
5. **计算基础数**：
    * `upperSum`: 上卦（四五上爻）有效和。
    * `lowerSum`: 下卦（初二三爻）有效和。
    * *公式*：`baseNumber = upperSum * 100 + lowerSum`。
6. **生成条文列表**：
    * 不扩展，直接返回基础数。

## 4. 关键逻辑代码

```dart
// 核心过滤逻辑
final sum = ganNum + zhiNum;
final isFiltered = filterSum10 && (sum == 10);

if (!isFiltered) {
  if (i < 3) {
    lowerSum += sum;
  } else {
    upperSum += sum;
  }
}

// 基础数公式
final baseNumber = calcUpperSum * 100 + calcLowerSum;
```

## 5. 依赖数据

* `Constants.taiXuanGanNumberMapper`: 天干太玄数。
* `Constants.taiXuanZhiNumberMapper`: 地支太玄数。
* `SixYaoCalculator`: 提供了标准的纳甲/纳支算法。

## 6. 公式/资源管理

* **公式类型**：硬编码逻辑。
* **资源文件**：无外部 JSON 依赖。

## 7. 审查结论

* **纳甲灵活性**：支持两种纳甲配置，其中 `yearGanYinYang` 实际上是一种混合模式（传统纳支 + 特定纳干）。
* **复用性**：大量复用了 `GuaYaoGanZhiHeResult` 和 `GuaYaoGanZhiHeBaseNumberModel`，结构清晰。
* **一致性**：与 `TaiXuanFourZhuStrategy` 类似，都使用了"及十不用"（和为10过滤）的规则，体现了太玄系算法的共同特征。
