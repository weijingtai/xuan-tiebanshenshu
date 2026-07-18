# 古籍案例到项目策略/测试映射表

> 可信参考源：`real_cases_intermediate.md`（古籍算法与案例程序整理）
> 共用四柱：癸巳 甲子 丁酉 癸卯，性别男，年干阴年

## 映射总表

| case | 算法名称 | 古籍核心规则摘要 | 当前项目对应策略/模块 | 测试文件 | 来源标签 | 修复建议 |
|------|---------|-----------------|---------------------|---------|---------|---------|
| case_1 | 六亲考刻取数法 | 先天卦/后天卦+八宫遍历变爻+互卦取四位数，±48×n 生成条文 | `lib/features/liuqinkaoke/strategy/liuqinkaoke_calculation_strategy.dart` | `lib/features/liuqinkaoke/` 下的 test | A | 可补测试 |
| case_2 | 考时定刻 | 八刻数表选基本数，纳甲配爻+加则法取数，±48×m 生成条文 | 暂无直接对应（可能对应 `BaGuaJiaZeStrategy` 的纳甲法，但算法流程差异大） | — | A | 需先找对应当前入口再补测试 |
| case_3 | 四柱天干取数法 | 天干配数（甲1丙2…癸0），月日时年排列，递加96×7 | `lib/service/strategy/four_zhu_tian_gan_strategy.dart` | `test/service/strategy/` 下（待建） | A | 可直接补测试 |
| case_4 | 日柱变卦取数法 | 日干配卦+日支配卦，互卦取数，先/后天混合取四位数，±96×m | `lib/service/strategy/day_gan_zhi_gua_strategy.dart` | `test/service/strategy/` 下（待建） | A | 可直接补测试 |
| case_5 | 太玄取数一 | 四柱干支配卦+年干阴阳纳甲+太玄数+上下卦和组成四位数，±96×4 | `lib/service/strategy/tai_xuan_four_zhu_strategy.dart`（`yearGanYinYang` 方法） | `test/service/strategy/tai_xuan_four_zhu_strategy_test.dart` | A | 已修基础数，可直接补扩展断言 |
| case_6 | 太玄取数二 | 太玄数+先天卦/错卦+后天卦/错卦+六亲考刻数，±96×m | 不在当前 `TaiXuanFourZhuStrategy`，无直接对应 | 无 | A | 禁止混入 case_5；需新建独立策略 |
| case_7 | 皇极取数一 | 元会运世+左旋/右旋互合+基础数一/二+12 条公式 | `lib/features/huang_ji/huang_ji_v2_*`；`test/assets/formula/huang_ji_1.json`（皇极取数法一） | `test/domain/models/huang_ji_formula_v2_test.dart`、`huang_ji_formula_data_v2_test.dart` | A | 可直接补测试 |
| case_8 | 皇极取数二 | 源码=case_7 copy，但注释描述不同规则（基础数一/二+干/支位） | `test/assets/formula/huang_ji_2.json`（皇极取数法二） | 同上 | ? | 需确认算法归属后补测试 |
| case_9 | 皇极取数三 | 实际实现了 case_8 注释中的基础数一/二规则 | `test/assets/formula/huang_ji_3.json`（皇极取数法三） | 同上 | A | 可直接补测试；注意与 case_7 规则不混 |

## 来源标签说明

- **A** = 可由 `real_cases_intermediate.md` 直接覆盖（古籍案例与当前项目出自同一本书/同一套算法）
- **B** = 疑似另一本书，不能用 A 覆盖（当前项目算法可能来自不同来源）
- **?** = 暂不确定，需用户确认算法归属

## 禁止直接修的项目（硬性限制）

| 项目 | 原因 |
|------|------|
| 元堂后天卦/大运 | `real_cases_intermediate.md` 未覆盖元堂规则 |
| `XianHoutianJiaZeStrategy` 算法归属 | 当前策略复用元堂 `YuanTangInfo` 的先后天卦+加则法，与 case_5/6 的太玄取数法是完全不同的算法体系，不得用 case_5/6 覆盖 |
| case_6 不可混入 case_5 | case_6 使用错卦+六亲考刻数，与 case_5 的年干阴阳纳甲法不同 |
| case_7 与 case_9 规则不可合并 | case_7 的 12 条公式和 case_9 的 8 条基础数一/二规则是两套不同的公式体系 |

## 各 case 详细映射

### case_1 — 六亲考刻取数法

**古籍规则摘要**：
1. 四柱太玄数 → 先天卦（年月模8，阴年男月上年下）
2. 基本卦+互卦 → 先天卦数组成四位数
3. 变爻遍历（初爻到上爻）找到匹配条文 → 基本数
4. 日时太玄数−10 → 后天卦+变爻遍历 → 后天基本数
5. 先天/后天各 ±48×m (m∈[2,4,8,16,-2,-4,-8,-16]) → 各8条文

**测试期望值（参考）**：
- 先天基本数：2253（四爻变）
- 先天条文：2349, 2445, 2637, 3021, 2157, 2061, 1869, 1485
- 后天基本数：2723（初爻变）
- 后天条文：2819, 2915, 3107, 3491, 2627, 2531, 2339, 1955

**当前项目对应**：
- 策略：`lib/features/liuqinkaoke/strategy/liuqinkaoke_calculation_strategy.dart`
- 模块：`lib/features/liuqinkaoke/`（含 strategy/usecase/session_manager/models/repository）
- 当前测试：`lib/features/liuqinkaoke/` 对应 test 目录

### case_2 — 考时定刻

**古籍规则摘要**：
1. 出生时刻查八刻数表 → 基本数
2. 基本数转后天卦
3. 纳甲配爻+加则法取数
4. 条文数 ±48×m

**测试期望值（参考）**：
- 刻基本数（卯时八刻选中）：2506
- 纳甲加则结果：7624
- 条文：6856, 7240, 7432, 7528, 7624, 7720, 7816, 8008, 8392

**当前项目对应**：
- 无直接一对一策略
- `BaGuaJiaZeStrategy`：卦的加则法计算（爻序法+纳甲法），但计算流程和用例场景不同
- `GuaZhongStrategy`：卦中取数法，部分逻辑相关但算法不同

### case_3 — 四柱天干取数法

**古籍规则摘要**：
1. 天干配数：甲1 丙2 戊3 庚4 壬5 乙6 丁7 己8 辛9 癸0
2. 月日时年排列 → 基本数
3. 基本数 +96×n (n∈[0..7])

**测试期望值（参考）**：
- 月甲=1, 日丁=7, 时癸=0, 年癸=0 → 基本数 1700
- 条文：1700, 1796, 1892, 1988, 2084, 2180, 2276, 2372

**当前项目对应**：
- 策略：`lib/service/strategy/four_zhu_tian_gan_strategy.dart`
- 常量：`lib/constant/constants.dart` 中 `fourZhuTianGanNumberMapper`（丁=7 正确）
- 排列顺序：月日时年 ✓（代码 `monthNumber*1000 + dayNumber*100 + timeNumber*10 + yearNumber`）

### case_4 — 日柱变卦取数法

**古籍规则摘要**：
1. 日干配卦+日支配卦 → 日支上卦、日干下卦
2. 第一卦互卦为第二卦
3. 第一卦上【后天】数千位，下【后天】数百位；第二卦上【先天】数十位，下【先天】数个位
4. ±96×m (m∈[-4..4])

**测试期望值（参考）**：
- 日柱丁酉：丁→兑，酉→乾 → 乾兑
- 互卦：巽离
- 基本数：乾后天6+兑后天7+巽先天5+离先天3 = 6753

**当前项目对应**：
- 策略：`lib/service/strategy/day_gan_zhi_gua_strategy.dart`
- 干支配卦映射：`tianGanGuaMapper`（丁→兑）和 `diZhiGuaMapper`（酉→乾）与古籍一致 ✓
- 取数逻辑：`_calculateBaseNumber` 上卦后天数/互卦先天数与古籍一致 ✓

### case_5 — 太玄取数一

**古籍规则摘要**：
1. 四柱干支配卦 → 年干阴阳纳甲
2. 每爻干支太玄数相加，和=10 跳过
3. 上卦和×100 + 下卦和 → 四位数
4. 每柱 ±96×4 → 8 条文

**测试期望值（参考）**：
- 年柱癸巳 4245，月柱甲子 4826，日柱丁酉 2648，时柱癸卯 4248

**当前项目对应**：
- 策略：`lib/service/strategy/tai_xuan_four_zhu_strategy.dart`（`_calculateByYearGanYinYang`）
- 测试：`test/service/strategy/tai_xuan_four_zhu_strategy_test.dart`
- 已通过 ✓（基础四数 4245/4826/2648/4248）
- 阴年纳甲（乾用甲、坤用乙、兑用丁）与古籍一致 ✓

### case_6 — 太玄取数二

**古籍规则摘要**：
1. 年月太玄和模8取先天卦+错卦 → 四位数（先天数）
2. 日时太玄和个位取后天卦+错卦 → 四位数（后天数）
3. 各+六亲考刻数 → 基础数
4. ±96×m

**测试期望值（参考）**：
- 年月基本数：2178（兑乾+错卦艮坤，先天数）
- 日时基本数：1296（坎坤+错卦离乾，后天数）
- +六亲考刻数 9193 → 11371（年月）、10489（日时）

**当前项目对应**：
- 无 `TaiXuanFourZhuStrategy` 不包含错卦逻辑
- 不包含六亲考刻数相加
- 需要新建独立策略

### case_7 — 皇极取数一

**古籍规则摘要**：
1. 元会运世太玄数 → 左旋互合（元会）、右旋互合（运世）
2. 基础数 = 互合数 + 年干×1000
3. >13000 则减 12000
4. ±30 递进找到匹配
5. 12 条公式（月干百位、月支百位、日干支互合、运世基础数变体等）

**测试期望值（部分）**：
- 元会互合 9018，运世互合 2111
- 基础数一 2018，基础数二 7111
- 条文 2918, 2918, 2084, 2177, 2116, 2117, 2182, 2183

**当前项目对应**：
- 模型：`lib/domain/models/yuan_hui_yun_shi.dart`
- 策略：`lib/features/huang_ji/huang_ji_v2_calculation_strategy_impl.dart`
- JSON 公式：`test/assets/formula/huang_ji_1.json`（皇极取数法一）
- 测试：`test/domain/models/huang_ji_formula_v2_test.dart`

### case_8 — 皇极取数二

**古籍规则摘要**：
- 代码 copy-paste 了 case_7，测试断言与 case_7 相同
- 但注释描述的规则不同（基础数一/二 + 干/支位）

**当前项目对应**：
- JSON 公式：`test/assets/formula/huang_ji_2.json`（皇极取数法二）
- 当前 formula JSON 规则可能与古籍不同

### case_9 — 皇极取数三

**古籍规则摘要**：
1. 元会运世与 case_7 相同
2. 基础数一（primary 2018）→ +月干百位、+日干十位、+时干个位、+时支个位
3. 基础数二（secondary 7111）→ +月干百位、+日干十位、+时干个位、+日干个位

**测试期望值（参考）**：
- 基础数一条文：2918, 2078, 2023, 2024
- 基础数二条文：8011, 7171, 7116, 7117

**当前项目对应**：
- JSON 公式：`test/assets/formula/huang_ji_3.json`（皇极取数法三）
- 测试：`test/domain/models/huang_ji_formula_data_v2_test.dart`

## 可交给下一个 agent 补测试的 case

| case | 前置条件 | 测试类型 |
|------|---------|---------|
| case_1 | 确认当前 `liuqinkaoke` 模块算法与古籍一致 | human spec test（输入四柱+期望中间值+期望条文） |
| case_3 | `fourZhuTianGanNumberMapper` 已确认匹配古籍 ✓ | strategy test（输入四柱，断言 basic number=1700+条文列表） |
| case_4 | 干支配卦取数逻辑已确认匹配古籍 ✓ | strategy test（输入日柱丁酉，断言 6753+条文列表） |
| case_5 | 基础四数测试已过 ✓ | 补充条文列表扩展断言、`sourceData` 完整性断言 |
| case_7 | `huang_ji_1.json` formula 存在 | formula data test（输入 YuanHuiYunShi，断言 12 条公式输出） |
| case_9 | `huang_ji_3.json` formula 存在 | formula data test（断言 8 条公式输出与古籍一致） |

## 必须等用户确认的 case

| case | 待确认问题 |
|------|-----------|
| case_2 | 当前项目是否有考时定刻的独立入口？是否需要新建策略？还是可以复用 `BaGuaJiaZeStrategy`？ |
| case_6 | 与 case_5 算法不同，需确认：①是否要在项目中实现？②是否新建独立策略？ |
| case_8 | 当前 `huang_ji_2.json` 与 case_7 的 `huang_ji_1.json` 的关系？case_8 古籍代码=case_7 copy，但注释描述不同，需确认实际应使用哪种规则 |
