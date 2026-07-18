# 铁板神数算法测试失败对照文档

更新时间：2026-07-17

## 背景

本文件用于整理当前 `flutter test` 剩余失败中，哪些可以直接修，哪些必须拿旧算法或书例规格比对后再修。

可信参考源：

- `/Users/jingtaiwei/Programme/Python/tmp/tie_ban_shen_shu/case/real_cases_intermediate.md`
- 来源：古籍算法与案例程序，经 Deepseek 逆向整理。
- 使用原则：按 case 对应策略逐项修；禁止把不同 case 的逻辑合并覆盖。

详见古籍案例到项目策略/测试的完整映射表：[docs/real-case-source-map.md](./real-case-source-map.md)

## 古籍案例到项目策略映射

| case | 算法 | 项目对应 | 修复判断 |
| --- | --- | --- | --- |
| case_1 | 六亲考刻取数法 | 待映射，可能在考刻/六亲相关模块 | 可作可信源；先建测试再修 |
| case_2 | 考时定刻 | 考时定刻/八刻数/纳甲加则 | 可作可信源；需找当前入口 |
| case_3 | 四柱天干取数法 | 四柱天干取数策略 | 可直接用于测试/修复 |
| case_4 | 日柱变卦取数法 | 日柱变卦/日干支卦相关策略 | 可直接用于测试/修复 |
| case_5 | 太玄取数一 | `TaiXuanFourZhuStrategy` | 已修基础数、sourceData、32条文展示 |
| case_6 | 太玄取数二 | 不是当前 `TaiXuanFourZhuStrategy`，待映射 | 不可混入 case_5 |
| case_7 | 皇极取数一 | 皇极元会运世相关 | 可作可信源；需单独修 |
| case_8 | 皇极取数二 | 皇极分组规则，代码疑似 copy case_7 | 待核对 |
| case_9 | 皇极取数三 | 皇极基础数一/二实际实现 | 可作可信源；注意注释与实现差异 |

不由该文档直接修的项：

- 元堂后天卦/大运：该文档未覆盖元堂规则。
- 当前 `XianHoutianJiaZeStrategy`：不要用 case_5/6 直接覆盖，先确认算法归属。

当前已先修复：

- 重复 wrapper 问题：`Gua64Name(Gua64Name)`、`Gua8Name(Gua8Name)`、`YinYangName(YinYangName)`。
- `Enum64Gua` / `Enum8Gua` / `YinYang` 与字符串比较不一致的问题：相关 strategy tests 已统一改为比较核心 enum，不再用中文字符串直接比较领域模型字段。
- `upperGuaDisplayText` / `lowerGuaDisplayText` 显示问题：相关模型已改用 `Enum8Gua.name`，避免显示成 `Enum8Gua.Zhen(3)` 这类 Dart enum 调试字符串。
- 皇极旧 JSON 兼容问题：缺 `baseNumberDefinition`、英文枚举值、缺 `description`。
- 皇极 `DerivedBaseNumber.toData` 语义：派生基础数现在以「父基础数 + 派生项」作为 `rawNumber`。
- 太玄四柱 result contract 与条文展示：保留四柱基础数展示，并在 `sourceData` 中补充每柱基础数 ±96 四次得到的 32 条文。

已通过的直接相关测试：

- `flutter test test/yuan_tang_test.dart`
- `flutter test test/usecases/xian_houtian_jia_ze_use_case_test.dart`
- `flutter test test/domain/models/huang_ji_first_formula_test.dart test/domain/models/huang_ji_formula_raw_number_integration_test.dart`
- `flutter test test/domain/models/huang_ji_formula_v2_test.dart test/domain/models/huang_ji_formula_data_v2_test.dart`

本轮 enum/string 修复后的局部验证：

- `dart analyze lib/domain/models/yuan_tang_base_number_model.dart lib/domain/models/xian_houtian_gua_base_number_model.dart lib/domain/models/xian_houtian_qu_shu_base_number_model.dart lib/domain/models/qian_hou_gua_base_number_model.dart lib/domain/models/liu_yao_gan_zhi_he_base_number_model.dart`：通过。
- `flutter test test/service/strategy/xian_houtian_jia_ze_human_spec_test.dart test/service/strategy/xian_houtian_qu_shu_human_spec_test.dart test/service/strategy/qian_hou_gua_human_spec_test.dart test/service/strategy/liu_yao_gan_zhi_he_strategy_test.dart --reporter compact`：前三个 human spec 不再暴露 enum/string 失败；`liu_yao_gan_zhi_he_strategy_test.dart` 剩余后天卦期望分歧。
- `flutter test test/service/strategy/yuan_tang_strategy_specific_debug_test.dart test/service/strategy/liu_yao_gan_zhi_he_human_spec_test.dart --reporter compact`：display getter 失败已修；剩余为 `usedThreeYuanWuGong` 期望分歧与六爻 human spec setup null。
- `flutter test test/service/strategy/tai_xuan_four_zhu_strategy_test.dart --reporter compact`：通过。验证基础四数 `4245/4826/2648/4248`、`sourceData.isYangYear`、`sourceData.baseNumbers`，以及四组各 8 条共 32 条文。

全量串行测试曾有 `65` 个失败。经过本轮 enum/string 边界修复后，原先那批 wrapper/string 假失败已不再作为算法问题处理；剩余失败需要重新以当前分支测试结果统计。

补充线索：你提到今天下午几个小时之前 MIMO 可能已经修过 enum/string 不对应的问题。本轮检查到当前代码已经没有 `Gua64Name` / `Gua8Name` / `YinYangName` wrapper 类残留在 `lib` 与相关 strategy tests 中，模型层实际已经在走核心 enum；因此本轮修复主要是把测试和展示 getter 补齐到这个方向，避免重复追查旧 wrapper 问题。

## 总体分类

| 类别 | 数量/范围 | 是否建议直接修 | 真实问题 |
| --- | --- | --- | --- |
| wrapper/String/Enum 类型边界 | 多个 strategy human spec、debug spec | 已修一批 | 当前模型层已保留核心 enum，测试已改为比较 `Enum64Gua`、`Enum8Gua`、`YinYang`；展示 getter 使用 `.name`。后续若再出现类似失败，优先按同一规则处理。 |
| `Enum64Gua` vs `Gua64Name` | 元堂、先后天、六爻、前后卦 | 当前不再作为算法阻塞 | 当前代码未发现 `Gua64Name` wrapper 残留；核心语义保留 `Enum64Gua`。剩余失败不要再归因到 wrapper，而应看后天卦生成、互卦、基础数、null 来源等规则。 |
| 算法规格不确定 | 八卦滚、四门法、元堂装卦、六爻干支和 | 否 | 当前测试含人工规格，但需要旧算法/书例确认规则。直接改会影响多个算法。 |
| result contract 不一致 | 太玄四柱 | 已修本轮可信范围 | 计算值本来正确；已补稳定业务名、`sourceData` 和每柱 ±96 四次的 32 条文展示数据。 |
| 测试样例前提可疑 | 八卦加则纯卦 | 否 | `乾为天` 下爻序法和纳甲法都得到 `6624`，测试强行要求两法不同，样例可能不适合这个断言。 |

## 第一批建议：类型统一（已执行）

### 目标

先不要改术数算法，只清理类型边界，让测试比较真实语义。本轮已按这个原则处理。

### 规则建议

- 领域计算内部保留：
  - `Enum64Gua`
  - `Enum8Gua`
  - `YinYang`
- 展示层再转：
  - `Gua64Name`
  - `Gua8Name`
  - `YinYangName`
- 测试里不要写 `expect(model.xiantianGua, equals('震坤'))`。
  - 当前做法：直接比较 `expect(model.xiantianGua, equals(Enum64Gua.xxx))`。
  - 八卦比较：直接比较 `Enum8Gua.Kun` / `Enum8Gua.Zhen` 等。
  - 阴阳比较：直接比较 `YinYang.YIN` / `YinYang.YANG`。

### 本轮已处理的直接类型问题示例

| 文件 | 测试数据 | 失败点 | 当前实际 | 测试期望 |
| --- | --- | --- | --- | --- |
| `test/service/strategy/yuan_tang_gui_si_test.dart` | 男，癸巳 甲子 丁酉 癸卯，上元，夏至，birthMonth=5 | 天卦/地卦/阴阳/先后天卦/互卦比较 | `Enum8Gua` / `Enum64Gua` / `YinYang` | 已改为 enum 期望 |
| `test/service/strategy/yuan_tang_strategy_specific_debug_test.dart` | 男，己酉 丙子 辛巳 戊子，上元，夏至，birthMonth=8 | 天卦/地卦/先后天卦比较、display getter | `Enum8Gua` / `Enum64Gua` | 已改为 enum 期望；display getter 已修为中文卦名 |
| `test/service/strategy/xian_houtian_jia_ze_human_spec_test.dart` | 男，己酉 丙子 辛巳 戊子，上元，夏至 | 天卦/地卦/先后天卦比较 | `Enum8Gua` / `Enum64Gua` | 已改为 enum 期望 |
| `test/service/strategy/qian_hou_gua_human_spec_test.dart` | 男，癸亥 甲子 己丑 癸酉，上元，夏至 | 前卦/后卦名称比较 | `Enum64Gua` | 已改为 enum 期望 |
| `test/service/strategy/xian_houtian_qu_shu_human_spec_test.dart` | 男，甲戌 己巳 辛丑 丁酉，上元，夏至 | 先天卦/后天卦比较 | `Enum64Gua` | 已改为 enum 期望 |
| `test/service/strategy/liu_yao_gan_zhi_he_strategy_test.dart` | 男，癸巳 甲子 丁酉 癸卯，上元，夏至 | 先后天卦比较 | `Enum64Gua` | 已改为 enum 期望；剩余是后天卦期望分歧 |
| `test/service/strategy/liu_yao_gan_zhi_he_human_spec_test.dart` | 女，丙辰 乙未 壬戌 戊巳，上元，夏至 | 先天卦比较 | `Enum64Gua` | 已改为 enum 期望；剩余是模型未生成导致 null |

本轮同步修复的展示 getter：

- `YuanTangBaseNumberModel.upperGuaDisplayText/lowerGuaDisplayText`
- `XianHoutianGuaBaseNumberModel.upperGuaDisplayText/lowerGuaDisplayText`
- `XianHoutianQuShuBaseNumberModel.upperGuaDisplayText/lowerGuaDisplayText`
- `QianHouGuaBaseNumberModel.upperGuaDisplayText/lowerGuaDisplayText`
- `LiuYaoGanZhiHeBaseNumberModel.upperGuaDisplayText/lowerGuaDisplayText`

验证：

- `rg` 未再发现相关 strategy tests 中这些字段直接和中文字符串比较。
- `rg` 未发现 `Gua64Name` / `Gua8Name` / `YinYangName` 残留。
- `dart analyze` 针对上述 5 个模型文件通过。

## 第二批建议：需要旧算法比对的规则问题

下面这些不要直接改代码。需要把旧算法、书例、或你手上的历史输出拿来对照。

### 1. 元堂装卦：`_zhuangguaLowerThan3` 是否应该二次反转

相关文件：

- `test/service/strategy/yuan_tang_fix_analysis_test.dart`
- `test/service/strategy/yuan_tang_strategy_specific_debug_test.dart`
- `test/service/strategy/yuan_tang_gui_si_test.dart`

关键测试数据：

| 用例 | 参数 | 人工规格期望 |
| --- | --- | --- |
| 元堂 A | 男，己酉 丙子 辛巳 戊子，上元，夏至，birthMonth=8 | 天数 `3`，地数 `3`，先天卦 `震震`，元堂爻 `初爻 index=0`，地支配置 `初:子寅 / 二:辰 / 三:巳 / 四:丑卯 / 五:空 / 上:空`，后天卦 `坤震`，先天加则 `3387`，后天加则 `2477` |
| 元堂 B | 男，癸巳 甲子 丁酉 癸卯，上元，夏至，birthMonth=5 | 天数 `2`，地数 `3`，先天卦 `震坤`，元堂爻 `二爻 index=1`，地支配置 `初:寅 / 二:卯 / 三:辰 / 四:子丑 / 五:巳 / 上:空`，后天卦 `坎震` |

当前测试内已有分析：

- `_zhuangguaLowerThan3` 中第二次 `reversed` 会把结果完全倒过来。
- 如果移除第二次反转，用例 A 会得到人工规格期望。

待确认问题：

- 这个反转是否只在 `阳爻/阴爻 < 3` 的双重装配分支错误？
- `_zhuanggua45` 是否同样需要取消反转？
- 取消后是否会破坏已通过的 `yuan_tang_test.dart` 里 46 个元堂用例？

建议验证方法：

1. 用旧算法跑这两个四柱。
2. 对照六爻地支配置，不只看最终条文号。
3. 若旧算法支持取消反转，再加一个专门测试覆盖 `_zhuangguaLowerThan3`。

### 2. 先后天八卦加则法：是否应复用元堂后天卦逻辑

相关文件：

- `test/service/strategy/xian_houtian_jia_ze_strategy_test.dart`
- `test/service/strategy/xian_houtian_jia_ze_human_spec_test.dart`

关键测试数据：

| 用例 | 参数 | 人工规格期望 |
| --- | --- | --- |
| 先后天加则 A | 男，癸巳 甲子 丁酉 癸卯，上元，夏至 | 测试注释说后天卦应与先天卦相同：`震坤`，先后天基础数相同 |
| 先后天加则 B | 男，己酉 丙子 辛巳 戊子，上元，夏至 | 人工规格说先天卦 `震震`，后天卦 `坤震`，先天基础数 `3387`，后天基础数 `2477` |

当前矛盾：

- A 用例认为“先后天八卦加则法不涉及爻变，后天卦与先天卦相同”。
- B 用例认为“后天卦来自元堂爻爻变，得到坤震”。

待确认问题：

- 先后天八卦加则法的“后天卦”到底是否使用元堂爻爻变？
- 如果使用元堂逻辑，A 测试的“后天卦与先天卦相同”应改掉。
- 如果不使用元堂逻辑，B 测试的后天卦 `坤震` 应不是本算法的期望。
- 2026-07-17 追加可信样例提示：用户提供的“先后天八卦加则 A”数据是四柱分别配卦：
  - 年柱 `癸巳`：地火明夷，初到上 `[卯、丑、亥、丑、亥、酉]`，数 `[60、30、180、30、180、150]`
  - 月柱 `甲子`：天水讼，初到上 `[寅、辰、午、午、申、戌]`，数 `[60、90、120、120、150、180]`
  - 日柱 `丁酉`：泽天夬，初到上 `[子、寅、辰、亥、酉、未]`，数 `[30、60、90、180、150、120]`
  - 时柱 `癸卯`：地天泰，初到上 `[子、寅、辰、丑、亥、酉]`，数 `[30、60、90、30、180、150]`
- 该样例看起来不是当前 `XianHoutianJiaZeStrategy` 的“复用元堂先后天卦”逻辑，可能属于另一套四柱配卦加则逻辑。不要直接用它覆盖当前策略实现。

### 3. 八卦加则公开方法：纯卦两法是否允许相同

相关文件：

- `test/service/strategy/ba_gua_jia_ze_public_methods_test.dart`

测试数据：

| 卦 | 当前实际 | 测试期望 |
| --- | --- | --- |
| `乾为天` | 爻序法 `6624`，纳甲法 `6624`；两者 `yaoSum=630` | 两种方法必须不同 |
| `坤为地` | 爻序法 `2628`，纳甲法 `2628` | 测试没有要求不同，只打印 |
| `雷泽归妹` | 爻序法 `3353`，纳甲法 `3623` | 两法不同 |

真实问题：

- 对纯卦，六爻结构高度对称，两种方法可能天然相同。
- 这个测试用 `乾为天` 证明“两法应不同”不可靠。

建议：

- 不改算法。
- 把“不同性”测试换成非纯卦，如 `雷泽归妹` 或 `山火贲`。
- 或把断言改成：“两法都能计算，纯卦允许相等”。

### 4. 八卦滚法：三基数 `a` 到底是单卦数还是组合数

相关文件：

- `test/service/strategy/ba_gua_gun_human_spec_test.dart`

测试数据：

- 男，己酉 丙子 辛巳 戊子，上元。

测试期望：

- 生成 8 个卦。
- 每组三基数：
  - `xiantianShunxu` 范围 `1..8`
  - `xiantianLuoshu` 范围 `1..9`
  - `houtianLuoshu` 范围 `1..9`
- 条文 48 个，且 `<10000`。
- 条文公式：`a*100+b`、`a*100+c`、`b*100+a`、`b*100+c`、`c*100+a`、`c*100+b`。

当前失败：

- `xiantianShunxu` 出现大于 8 的两位值，例如类似上下卦组合数。

待确认问题：

- 三基数 `a` 是“单个八卦的先天序数”，还是“64 卦上下卦组合编码”？
- 如果是单卦数，当前实现取错层级。
- 如果是组合编码，测试范围 `<=8` 错。

### 5. 四门法 V2：先天数与条文编号范围

相关文件：

- `test/service/strategy/si_men_fa_human_spec_test.dart`

测试数据：

- 男，己酉 丙子 辛巳 戊子，上元。

测试期望：

- 生成 4 个卦。
- 4 个秘数，每个 `<10000`。
- 4 个先天数，每个 `1..8`。
- 条文编号 `>0` 且 `<10000`。

当前失败：

- 先天数出现大于 `8` 的值。
- 条文编号出现 `>=10000` 的值。
- 男女性别变化下基本数相同（测试只打印，未断言）。

待确认问题：

- 四门法的“先天数”是否应该是单卦序数，还是四位/两位组合数？
- 条文体系到底是 `1..9999`，还是允许 `10000..12000/13000`？
- 若条文库总数是 12000，则 `<10000` 的断言可能过窄。

### 6. 六爻干支和数法：后天卦期望分歧与 human spec 空值

相关文件：

- `test/service/strategy/liu_yao_gan_zhi_he_strategy_test.dart`
- `test/service/strategy/liu_yao_gan_zhi_he_human_spec_test.dart`

测试数据 A：

- 男，癸巳 甲子 丁酉 癸卯，上元，夏至。
- 期望先天卦 `震坤`，后天卦 `震坤`。

当前失败 A：

- `Gua64Name` 与字符串比较已修为 `Enum64Gua` 比较。
- 剩余分歧：测试期望后天卦 `震坤`（`Enum64Gua.lei_di_yu`），当前实际为 `坎震`（`Enum64Gua.shui_lei_tun`）。
- 这已经不是 enum 类型问题，而是“六爻干支和数法是否应该生成/沿用后天卦”的算法契约问题。

测试数据 B：

- 女，丙辰 乙未 壬戌 戊巳，上元，夏至。

人工规格期望 B：

- 先天卦：`艮震`（山雷颐）。
- 纳甲初到上：`庚子 / 庚寅 / 庚辰 / 丙戌 / 丙子 / 丙寅`。
- 上卦之和 `42`，下卦之和 `45`。
- 基本数 `4245`。
- 先天条文：`4245, 4341, 4437, 4533, 4629`。
- 后天条文：`4245, 4149, 4053, 3957, 3861`。

当前失败 B：

- 多个测试报 `Null check operator used on a null value`。
- 先天卦字符串比较已修为 `Enum64Gua.shan_lei_yi`。
- 当前真正问题是 setup 阶段没有拿到 `LiuYaoGanZhiHeBaseNumberModel`，后续 `model!` 触发空值。

待确认问题：

- 该四柱是否命中某个卦/纳甲映射缺失？
- 策略是否假设先后天卦一定非空，但该用例的中间结果没有生成？
- 需要先定位 null 来源，再决定是补映射还是修计算流程。

### 7. 先后天卦取数法：大概率是类型问题，算法值看起来匹配

相关文件：

- `test/service/strategy/xian_houtian_qu_shu_human_spec_test.dart`

测试数据：

- 男，甲戌 己巳 辛丑 丁酉，上元，夏至。

人工规格期望：

- 先天卦：`兑乾`（泽天夬）。
- 先天基本数：`2111`。
- 后天卦：`离兑`（火泽睽）。
- 后天基本数：`9719`。

当前失败：

- 本轮已修：卦名字段按 `Enum64Gua` 比较，不再和字符串比。
- 复跑相关 human spec 时未再暴露该文件的 enum/string 失败。

建议：

- 暂不动算法。
- 若后续全量仍失败，再按最新输出重新归类，不再把它归到 wrapper/string。

### 8. 前后卦取数法：大概率是类型问题，算法值看起来匹配

相关文件：

- `test/service/strategy/qian_hou_gua_human_spec_test.dart`

测试数据：

- 男，癸亥 甲子 己丑 癸酉，上元，夏至。

人工规格期望：

- 干太玄数 `[5, 9, 9, 5]`。
- 支太玄数 `[[4], [9], [8], [6]]`。
- 前卦：`坎坤`。
- 后卦：`坎震`。
- 前卦基础数 `1478`，条文 `[1478, 1574, 1670, 1766, 1862]`。
- 后卦基础数 `1387`，条文 `[1387, 1291, 1195, 1099, 1003]`。

当前失败：

- 本轮已修：前卦/后卦按 `Enum64Gua.shui_di_bi`、`Enum64Gua.shui_lei_tun` 比较。
- 复跑相关 human spec 时未再暴露该文件的 enum/string 失败。

建议：

- 暂不动算法。
- 若后续全量仍失败，再看是否是条文数或取数流程问题。

### 9. 太玄四柱：计算值与 result contract 分离

相关文件：

- `test/service/strategy/tai_xuan_four_zhu_strategy_test.dart`

测试数据：

- 癸巳 甲子 丁酉 癸卯。

人工规格期望：

- 年柱癸巳：`4245`，名称 `年柱太玄数`。
- 月柱甲子：`4826`，名称 `月柱太玄数`。
- 日柱丁酉：`2648`，名称 `日柱太玄数`。
- 时柱癸卯：`4248`，名称 `时柱太玄数`。
- `sourceData.isYangYear == false`。
- `sourceData.baseNumbers` 是长度 4 的列表。

当前实际：

- 数值断言通过。
- 旧问题：名称实际是 `年柱-年干阴阳纳甲` 等，`sourceData['isYangYear']` 和 `sourceData['baseNumbers']` 为空。
- 已修：名称稳定为 `年柱太玄数` 等，`sourceData` 包含 `isYangYear`、`baseNumbers`、`baseNumberValues`、`expandedTiaoWenNumbers`、`expandedTiaoWenCount`、`expandedTiaoWenExplanation`。

真实问题：

- 不是核心计算错，而是 result contract 不一致。该项已在本轮修复。
- 条文规则按用户可信数据：基础四数只展示，不计入 32 条文；每柱基础数递加96四次、递减96四次，四柱共 32 条。

已验证：

- `flutter test test/service/strategy/tai_xuan_four_zhu_strategy_test.dart --reporter compact`

## 建议修复顺序

### Phase 1：只做类型统一（已完成本轮可见范围）

目标：不改变算法，消除 wrapper/String/Enum 假失败。

动作：

1. 已确认当前代码里 `Gua8Name`、`Gua64Name`、`YinYangName` wrapper 不再作为模型字段存在。
2. 已修改相关测试比较：
   - `Enum8Gua.Kun/Zhen/Kan/...`
   - `Enum64Gua.lei_di_yu/shui_lei_tun/...`
   - `YinYang.YIN/YANG`
3. 已修展示 getter，统一用 `.name` 输出中文卦名。
4. 下一步应跑当前分支全量测试，重新统计剩余失败。

预期效果：

- 元堂、先后天加则、前后卦、先后天取数、六爻中的 enum/string 假失败已被排除。
- 剩余失败应按算法契约、样例前提、result contract 或 null 来源重新分类。

### Phase 2：修 result contract

目标：不动核心计算，只让返回数据契约稳定。

动作：

1. 太玄四柱已补 `sourceData`。
2. 太玄四柱模型 `name` 已回到稳定业务名：`年柱太玄数`、`月柱太玄数`、`日柱太玄数`、`时柱太玄数`。
3. 太玄四柱已补每柱 ±96 四次的 8 条扩展条文，四柱共 32 条。

### Phase 3：旧算法比对

目标：只处理真正算法分歧。

优先比对顺序：

1. 元堂装卦反转问题。
2. 先后天八卦加则法是否复用元堂后天卦。
3. 六爻干支和数法 null 来源。
4. 八卦滚三基数定义。
5. 四门法数值范围。
6. 八卦加则纯卦是否允许两法相等。

每个算法都建议准备同样格式的对照表：

| 算法 | 输入四柱 | 性别 | 三元 | 节气 | 旧算法中间结果 | 当前中间结果 | 测试期望 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |

## 需要你回查旧算法的重点问题

1. 元堂双重装配时，结果列表最后是否应该 `reversed`？
2. 先后天八卦加则法的后天卦是否来自元堂爻变？
3. 八卦滚三基数的 `a` 是单卦先天序数，还是 64 卦上下组合码？
4. 四门法的先天数是否允许两位数？条文号上限是 9999、12000 还是 13000？
5. 六爻干支和数法对 `女 丙辰 乙未 壬戌 戊巳` 是否应生成 `艮震`，以及纳甲是否为 `庚子/庚寅/庚辰/丙戌/丙子/丙寅`？
6. 八卦加则法在纯卦 `乾为天`、`坤为地` 上，爻序法与纳甲法是否允许相同？
