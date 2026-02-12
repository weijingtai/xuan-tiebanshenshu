# 先后天卦六爻干支和数法 (LiuYaoGanZhiHeStrategy) 算法审查

## 1. 算法概述

**名称**：先后天卦六爻干支和数法
**类名**：`LiuYaoGanZhiHeStrategy`
**文件路径**：`lib/service/strategy/liu_yao_gan_zhi_he_strategy.dart`
**描述**：基于元堂卦的先天卦和后天卦，分别进行六爻纳甲（配天干地支），计算每爻干支的太玄数之和（和为10则不计），最后组合成四位条文编号，并进行递增/递减扩展。

## 2. 输入参数

该算法需要以下参数（通过 `LiuYaoGanZhiHeStrategyParams` 传入）：

* `eightChars`, `gender`, `threeYuan` 等：用于计算或复用元堂卦信息。
* `yuanTangInfo`: 可选，复用元堂卦结果。

## 3. 计算流程

1. **获取元堂卦信息**：
    * 复用传入的 `yuanTangInfo` 或者重新计算。
2. **提取双卦**：
    * 提取**先天卦** (`getXiantianGua`)。
    * 提取**后天卦** (`getHoutianGua`)。
3. **六爻纳甲与求和**（对先天、后天分别执行）：
    * **纳甲**：使用标准六爻纳甲法 (`constants.inner/outerGuaYaoTianGan/DiZhi`) 为每爻配置天干和地支。
    * **单爻求和**：`sum = 纳干太玄数 + 纳支太玄数`。若 `sum == 10`，则计为 `0`。
    * **分组求和**：
        * `upperSum`: 上三爻（4,5,6爻）之和。
        * `lowerSum`: 下三爻（1,2,3爻）之和。
    * **基础数拼接**：`baseNumber = upperSum * 100 + lowerSum`。
4. **生成条文列表**：
    * **策略**：`[0, 96, 192, 288, 384, -96, -192, -288]`。
    * 分别对先天基础数和后天基础数应用此策略，各生成8个条文。

## 4. 关键逻辑代码

```dart
// 六爻求和与拼接
final lowerSum = yaoSumList[0] + yaoSumList[1] + yaoSumList[2];
final upperSum = yaoSumList[3] + yaoSumList[4] + yaoSumList[5];
final baseNumber = upperSum * 100 + lowerSum;

// 条文扩展
customList: [0, 96, 192, 288, 384, -96, -192, -288]
```

## 5. 依赖数据

* `YuanTangCalculator`: 核心依赖。
* `Constants.taiXuanGan/ZhiNumberMapper`: 太玄数。
* `Constants.inner/outerGuaYaoTianGan/DiZhi`: 纳甲配置。

## 6. 公式/资源管理

* **公式类型**：太玄数求和拼接 + 96递增减。
* **资源文件**：无外部 JSON 依赖。

## 7. 审查结论

* **策略复用**：再次继承 `YuanTangBasedStrategy`，证明了元堂系策略的一致性设计。
* **取数差异**：不同于 `XianHoutianQuShuStrategy` 的"四位拼接"，本策略使用的是"六爻干支太玄数求和"，这是两种完全不同的数学模型，但在代码结构上高度相似。
* **和为10处理**：明确了 `sum == 10` 返回 `0` 的逻辑，这意味着该爻完全不贡献数值（不同于某些算法可能跳过该爻的计数）。
