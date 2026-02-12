# 四门法 (SiMenFaStrategy) 算法审查

## 1. 算法概述

**名称**：四门法V2
**类名**：`SiMenFaStrategy`
**文件路径**：`lib/service/strategy/si_men_fa_strategy.dart`
**描述**：一套完整的秘数推演体系，包含从基本卦生成四卦（本、互、变、错），计算秘数和先天数，最终通过特定的组合公式生成大量条文。

## 2. 输入参数

该算法需要以下参数（通过 `SiMenFaStrategyParams` 传入）：

* `eightChars` (`EightChars`): 四柱信息。
* `gender` (`Gender`): 性别。
* `threeYuan` (`YuanYunOrder`): 三元。

## 3. 计算流程

1. **生成前四卦** (`SiMenFaCalculator.generateFirstFourGua`)：
    * **第一卦**：基本卦的互卦。
    * **第二卦**：第一卦变爻后的错卦。
    * **第三卦**：第一卦的互卦。
    * **第四卦**：第二卦的互卦。
    * *注*：基本卦生成逻辑复用了 `MultiGuaCalculatorBase`（奇偶数和取模8）。
2. **计算秘数列表** (`TiaoWenNumberCalculator.calculateSecretNumbers`)：
    * 根据年份阴阳，对前四卦进行特定运算生成秘数。
3. **计算先天数列表** (`TiaoWenNumberCalculator.calculateXiantianNumbers`)：
    * 基于前四卦及其他参数生成先天数。
4. **生成最终条文** (`TiaoWenNumberCalculator.calculateFinalTiaowen`)：
    * **核心公式**：双重循环遍历先天数和秘数。
    * 对于每一对 `(先天数, 秘数)`，再遍历常数列表 `K = [19, 37, 53, 79, 103, 237]`。
    * `middleware = 秘数 * K - 7`。
    * `rawResult = 先天数 * 47 + middleware`。
    * **归一化**：将 `rawResult` 映射到 `[0, 13000]` 范围内（`+12000` 或 `-12000`）。

## 4. 关键逻辑代码

```dart
// 核心条文生成公式
final secretT = seNum * k - 7;
int eachNum = xiNum * 47 + secretT;

// 归一化逻辑
if (eachNum < 1000) {
  finalNum = eachNum + 12000;
} else if (eachNum > 13000) {
  finalNum = eachNum - 12000; // 递归减直到范围内
}
```

## 5. 依赖数据

* `SiMenFaCalculator`: 专用的起卦计算器。
* `TiaoWenNumberCalculator`: 封装了秘数和先天数的复杂计算逻辑。

## 6. 公式/资源管理

* **公式类型**：复杂的代数运算（`A * 47 + B * K - 7`）。
* **资源文件**：无外部 JSON 依赖。

## 7. 审查结论

* **计算最繁琐**：四门法的计算量极大，涉及多层循环和大量乘法运算。
* **逻辑封装**：核心的数学公式被封装在 `TiaoWenNumberCalculator` 中，策略类主要负责流程编排。
* **数据溯源**：`TiaoWenSourceInfo` 记录了每一条条文是由哪两个卦、哪个常数生成的，这对于排查问题非常有用。
