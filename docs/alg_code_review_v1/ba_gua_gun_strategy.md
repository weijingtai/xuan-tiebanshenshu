# 八卦滚法 (BaGuaGunStrategy) 算法审查

## 1. 算法概述

**名称**：八卦滚法
**类名**：`BaGuaGunStrategy`
**文件路径**：`lib/service/strategy/ba_gua_gun_strategy.dart`
**描述**：通过变爻、错卦、互卦等一系列变换，生成八个相关联的卦象，并计算每卦的三基数（先天顺序数、先天洛书数、后天洛书数），最终组合生成48条条文。

## 2. 输入参数

该算法需要以下参数（通过 `BaGuaGunStrategyParams` 传入）：

* `eightChars` (`EightChars`): 四柱信息。
* `gender` (`Gender`): 性别。
* `threeYuan` (`YuanYunOrder`): 三元。

## 3. 计算流程

1. **生成前四卦** (`BaGuaGunCalculator.generateFirstFourGua`)：
    * **第一卦**：基本卦（本卦）。
    * **第二卦**：第一卦变爻后上下交换。
    * **第三卦**：第二卦的互卦。
    * **第四卦**：第三卦的错卦。
    * *注*：基本卦生成逻辑复用了 `MultiGuaCalculatorBase`（个位转换法）。
2. **生成后四卦** (`BaGuaGunCalculator.generateLastFourGua`)：
    * 从第四卦开始继续推演。
    * **第五卦**：第四卦变爻后上下交换。
    * **第六卦**：第五卦的互卦。
    * **第七卦**：第六卦的错卦。
    * **第八卦**：第七卦变爻后上下交换。
3. **计算三基数**：
    * 对这8个卦，分别计算：
        * `a`: 先天顺序数。
        * `b`: 先天洛书数。
        * `c`: 后天洛书数。
4. **生成条文列表**：
    * 每卦生成6个条文，8卦共48个条文。
    * **公式**：`a*100+b`, `a*100+c`, `b*100+a`, `b*100+c`, `c*100+a`, `c*100+b`。

## 4. 关键逻辑代码

```dart
// 卦象推演逻辑（如生成第五卦）
final fifthGuaStrategy = const GuaStrategy(
  needExchange: true,
  needCuoGua: false,
  guaType: "本",
  baseGuaSource: "fourth",
  needVariation: true,
);

// 条文生成逻辑
final perGuaTiaoWen = _tiaoWenCalculator.calculateGuaTiaowenList(
  three.xiantianShunxu,
  three.xiantianLuoshu,
  three.houtianLuoshu,
);
```

## 5. 依赖数据

* `BaGuaGunCalculator`: 专用的起卦计算器，继承自 `MultiGuaCalculatorBase`。
* `TiaoWenNumberCalculator`: 封装了三基数获取和条文组合逻辑。

## 6. 公式/资源管理

* **公式类型**：独特的"变互错"推演链 + 三基数排列组合。
* **资源文件**：无外部 JSON 依赖。

## 7. 审查结论

* **推演链最长**：这是唯一一个连续推演8代卦象的策略，卦象之间的因果链条非常长。
* **排列组合**：条文生成采用了全排列的方式（3个数取2个组合），覆盖面广。
* **基础复用**：`MultiGuaCalculatorBase` 为四门法和八卦滚法提供了统一的基础卦生成和变爻计算支持。
