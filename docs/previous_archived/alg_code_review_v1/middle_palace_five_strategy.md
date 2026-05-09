# 中五宫取数策略 (MiddlePalaceFiveStrategy) 算法审查

## 1. 算法概述

**名称**：中五宫取数策略
**类名**：`MiddlePalaceFiveStrategy` (接口) / `DefaultMiddlePalaceFiveStrategy` (实现)
**文件路径**：`lib/service/strategy/middle_palace_five_strategy.dart`
**描述**：这是一个辅助策略借口，用于解决后天八卦中"中五宫"（数字5）无对应卦象的问题。不同流派对"5"寄宫于哪个卦有不同说法，此策略封装了这一逻辑。

## 2. 输入参数

* `era` (`YuanYunOrder`): 三元（上/中/下）。
* `gender` (`Gender`): 性别。
* `isYang` (`bool`): 年干阴阳。

## 3. 计算流程

`DefaultMiddlePalaceFiveStrategy` 的实现逻辑如下：

* **上元**：
  * 男 -> 艮 (Gen)
  * 女 -> 坤 (Kun)
* **中元**：
  * 阴男 (男且阴年) 或 阳女 (女且阳年) -> 坤 (Kun)
  * 其他（阳男或阴女） -> 艮 (Gen)
* **下元**：
  * 男 -> 离 (Li)
  * 女 -> 兑 (Dui)

## 4. 关键逻辑代码

```dart
switch (era) {
  case YuanYunOrder.upper:
    return gender == Gender.male ? Enum8Gua.Gen : Enum8Gua.Kun;
  case YuanYunOrder.middle:
    // ...逻辑同上...
  case YuanYunOrder.lower:
    return gender == Gender.male ? Enum8Gua.Li : Enum8Gua.Dui;
}
```

## 5. 依赖数据

无外部依赖。

## 6. 公式/资源管理

* **公式类型**：硬编码的条件判断逻辑。

## 7. 审查结论

* **辅助性质**：这不是一个独立的生成基础数的策略，而是被其他策略（如涉及九宫飞星或元堂计算）调用的组件。
* **流派差异**：当前实现了一种特定的寄宫规则（上艮坤，下离兑），这是典型的三元九运风水或铁板神数规则。未来可能需要扩展其他流派的寄宫规则（如男寄坤女寄艮等）。
