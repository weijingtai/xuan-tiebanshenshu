# 四柱天干取数法 (FourZhuTianGanStrategy) 算法审查

## 1. 算法概述

**名称**：四柱天干取数法
**类名**：`FourZhuTianGanStrategy`
**文件路径**：`lib/service/strategy/four_zhu_tian_gan_strategy.dart`
**描述**：排四柱只取天干进行配数，按月日时年顺序排列得到基本数，递加96生成条文列表。

## 2. 输入参数

该算法需要以下参数（通过 `FourZhuTianGanStrategyParams` 传入）：

* `eightChars` (`EightChars`): 完整的四柱（八字）信息。

## 3. 计算流程

1. **提取四柱天干**：从 `eightChars` 中获取年、月、日、时的天干。
2. **天干配数**：
    * 映射关系：甲1、乙6、丙2、丁7、戊3、己8、庚4、辛9、壬5、癸0。
    * *数据源*：`Constants.fourZhuTianGanNumberMapper`。
3. **排列组合**：
    * 顺序：**月 -> 日 -> 时 -> 年**。
    * *公式*：`月干数 * 1000 + 日干数 * 100 + 时干数 * 10 + 年干数`。
    * 此步骤生成"基础数" (`baseNumber`)。
4. **生成条文列表**：
    * 默认配置：以基础数为起点，递加 96，共加 7 次，生成 8 个条文编号。
    * *序列*：`+0, +96, +192, +288, +384, +480, +576, +672`。

## 4. 关键逻辑代码

```dart
// 排列组合逻辑
final monthNumber = Constants.fourZhuTianGanNumberMapper[monthGan]!;
final dayNumber = Constants.fourZhuTianGanNumberMapper[dayGan]!;
final timeNumber = Constants.fourZhuTianGanNumberMapper[timeGan]!;
final yearNumber = Constants.fourZhuTianGanNumberMapper[yearGan]!;

// 组合成四位数：月日时年
final baseNumber =
    monthNumber * 1000 + dayNumber * 100 + timeNumber * 10 + yearNumber;
```

## 5. 依赖数据

* `Constants.fourZhuTianGanNumberMapper`: 天干 -> 数字 (0-9)

## 6. 公式/资源管理

* **公式类型**：硬编码逻辑。
* **资源文件**：无外部 JSON 依赖。

## 7. 审查结论

* **完整性**：逻辑清晰，严格遵循"月日时年"的特定排列顺序。
* **可维护性**：依赖于 `Constants` 进行天干配数，易于维护。
* **配置项**：提供了"标准"、"简化"、"扩展"三种配置，灵活控制递加 96 的次数。
