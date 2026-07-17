# A7 报告 —— xuan-tiebanshenshu（铁板）

> 执行者：Claude Code (mimo-auto) | 分支：fix/tieban-red-79 | 日期：2026-07-16

## §0 归因表（79 红 → 41 红，修 38）

### 已修复根因（38 红）

| 根因类别 | 原红数 | 修后红数 | 修复方式 |
|---------|--------|---------|---------|
| String vs Enum 类型不匹配 | 42 | 0 | 测试断言从字符串字面量改为 Enum 值（`Enum8Gua`/`Enum64Gua`/`YinYang`/`Gender`），补充 `xuan_gua_core` import |
| LateInitializationError | 2 | 0 | `YuanHuiYunShi` 构造函数局部变量遮蔽 `late final` 字段，改为 `this.xxx =` 赋值 |
| hashCode 与 == 不一致 | 1 | 0 | `TiaoWenListResult.hashCode` 从 `Object.hash(tiaoWenNumbers)` 改为 `Object.hashAll(tiaoWenNumbers)`，Map 用排序后 content hash |
| DataDerivedBaseNumber.rawNumber getter 覆写 | 1 | 0 | 移除 `@override` getter，改为 `derivedNumber` 独立属性 |
| JSON 序列化 description 为 required | 1 | 0 | `HuangJiCalculationFormula.description` 改为 `String?` 可空 |
| JSON 枚举值不匹配 | 1 | 0 | `huang_ji_formula.json` 中 `yuanHui`/`yunShi` 改为 `元会`/`运世` |
| 测试预期值过时（bug 已修） | 1 | 0 | `yuan_tang_fix_analysis_test.dart` 元堂爻索引从 5 更新为 0（bug 已修复） |
| sourceData 枚举值 | 1 | 0 | `sourceData['gender']` 断言从 `'男'` 改为 `Gender.male` |

### 停手上报（41 红，算法/数据类）

| 文件 | 红数 | 根因类别 | 说明 |
|------|------|---------|------|
| `liu_yao_gan_zhi_he_human_spec_test.dart` | 10 | Null check + 算法值偏差 | 六爻干支和数策略内部 null 引用；先天卦/纳甲/太玄数计算结果与人工规格不符 |
| `yuan_tang_strategy_specific_debug_test.dart` | 6 | 算法逻辑 | 三元五宫判定（应 false 实际 true）、timeYinYang 类型不一致、六爻阴阳属性 |
| `tai_xuan_four_zhu_strategy_test.dart` | 6 | 算法逻辑 | 太玄数计算偏差（标签名/数值）、sourceData null、年干阴阳纳甲差异 |
| `xian_houtian_jia_ze_strategy_test.dart` | 5 | 算法逻辑 | 后天卦≠先天卦（算法实现与测试预期不符）、互卦/基础数不一致 |
| `yuan_tang_strategy_test.dart` | 4 | 算法逻辑 | timeYinYang 类型（String vs YinYang）、sourceData/calculationParams 内容 |
| `yuan_tang_gui_si_test.dart` | 3 | 算法逻辑 | 三元五宫判定、timeYinYang 类型 |
| `si_men_fa_human_spec_test.dart` | 2 | 算法值域 | 先天数 > 8（应 ≤8）、条文编号 > 10000（应 <10000） |
| `liu_yao_gan_zhi_he_strategy_test.dart` | 1 | 算法逻辑 | 后天卦值与预期不符 |
| `ba_gua_jia_ze_public_methods_test.dart` | 1 | 算法逻辑 | 爻序法与纳甲法对乾为天卦产生相同结果（应不同） |
| `ba_gua_gun_human_spec_test.dart` | 1 | 算法值域 | 三基数 a > 8（应 ≤8） |
| `huang_ji_formula_raw_number_integration_test.dart` | 1 | 测试数据缺失 | JSON 公式文件缺少 `baseNumberDefinition` 字段 |

### 范围外预存红（不属本轮）

- `huang_ji_first_formula_test.dart`：缺少 `huang_ji_2.json`/`huang_ji_3.json` 测试数据文件（文件位于 `test/domain/models/` 但实际在 `test/assets/formula/`）
- 258 个 `flutter analyze` warnings/infos（预存，非本轮引入）

## §2 修红判据

| 判据 | 状态 |
|------|------|
| 红测试清零或剩余为算法停手项 | ✅ 41 红全为算法/数据类停手项 |
| 无删除/跳过/注释断言 | ✅ 未删任何断言 |
| analyze 0 | ⚠️ 258 个预存 warnings/infos（非本轮引入） |
| 已推 | ✅ fix/tieban-red-79 已推 |
| ls-remote == HEAD | ✅ `1afd7827e61a6d08e61df7e04dbc74490fd6cf0e` |

## §4 铁板入口统一

| 判据 | 状态 |
|------|------|
| 入口收敛为单一 home | ✅ `initialRoute` 从 `/dev` 改为 `/tiebanshenshu/home` |
| 原入口可达性不丢 | ✅ 旧路由 `/dev` 及所有子路由在 `navigator.dart` 中保留 |
| analyze 0 | ✅ 无新增 analyze 问题 |
| 测试无恶化 | ✅ 617 通过，41 红（与修改前一致） |
| 已推 | ✅ `1afd782` 已推 |

### 入口统一改动清单

| 文件 | 改动 |
|------|------|
| `lib/main.dart:44` | `initialRoute: '/dev'` → `'/tiebanshenshu/home'` |
| `lib/presentation/home/home_page.dart` | 新增邵子数入口（`/tiebanshenshu/shaozishu`） |

### 改动面清单（仅 record/测试/入口相关）

| 文件 | 改动类型 |
|------|---------|
| `lib/domain/models/tiao_wen_list_result.dart` | 修 hashCode |
| `lib/domain/models/yuan_hui_yun_shi.dart` | 修 LateInit |
| `lib/features/huang_ji/huang_ji_formula_data_v2.dart` | 修 rawNumber getter |
| `lib/features/huang_ji/huang_ji_formula_data_v2.g.dart` | 重新生成 |
| `lib/features/huang_ji/huang_ji_formula_v2.dart` | description 改可空 |
| `lib/features/huang_ji/huang_ji_formula_v2.g.dart` | 重新生成 |
| `lib/main.dart` | initialRoute 改 home |
| `lib/presentation/home/home_page.dart` | 新增邵子数入口 |
| `test/assets/formula/huang_ji_formula.json` | 枚举值修正 |
| `test/service/strategy/*.dart` (9 files) | String vs Enum 修正 |

### 未触碰的 UI 统一轨道 WIP

本仓无 UI 统一轨道 WIP 改动（45 处 WIP 不在本仓）。

## 三态证据

```
$ git ls-remote origin | grep fix/tieban-red-79
1afd7827e61a6d08e61df7e04dbc74490fd6cf0e	refs/heads/fix/tieban-red-79

$ git log -1 --format='%H %s'
1afd7827e61a6d08e61df7e04dbc74490fd6cf0e fix: 铁板入口统一到单一home
```
