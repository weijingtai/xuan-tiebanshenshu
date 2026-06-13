# 硬编码代码与测试映射关系报告

## 第一部分：源码硬编码排查结果

### 1. 魔法数字 25/30（元堂卦计算阈值）

| 源码文件 | 行号 | 硬编码内容 | 说明 |
|---------|------|-----------|------|
| `lib/features/yuan_tang_gua/yuan_tang_calculator.dart` | 151 | `calculateGuaNum(tianNumTotal, 25, 5)` | 天数阈值25，默认值5 |
| `lib/features/yuan_tang_gua/yuan_tang_calculator.dart` | 153 | `calculateGuaNum(diNumNumTotal, 30, 3)` | 地数阈值30，默认值3 |
| `lib/features/yuan_tang_gua/yuan_tang_calculator.dart` | 233 | `calculateGuaNum(oddNumTotal, 25, 5)` | 天数阈值25 |
| `lib/features/yuan_tang_gua/yuan_tang_calculator.dart` | 235 | `calculateGuaNum(evenNumTotal, 30, 3)` | 地数阈值30 |
| `lib/features/yuan_tang_gua/yuan_tang_calculator.dart` | 1293 | `calculateGuaNum(oddNumTotal, 25, 5)` | 天数阈值25 |
| `lib/features/yuan_tang_gua/yuan_tang_calculator.dart` | 1296 | `calculateGuaNum(evenNumTotal, 30, 3)` | 地数阈值30 |
| `lib/utils/utils.dart` | 467 | `calculateGuaNum(oddNumTotal, 25, 5)` | 天数阈值25 |
| `lib/utils/utils.dart` | 470 | `calculateGuaNum(evenNumTotal, 30, 3)` | 地数阈值30 |
| `lib/utils/utils.dart` | 586 | `calculateGuaNum(oddNumTotal, 25, 5)` | 天数阈值25 |
| `lib/utils/utils.dart` | 589 | `calculateGuaNum(evenNumTotal, 30, 3)` | 地数阈值30 |

> **说明**：`calculateGuaNum` 函数的 `threshold` 参数（25/30）是元堂卦计算的核心魔法数字，分散在多个文件中重复硬编码。

### 2. 硬编码基数 13000（条文数边界值）

| 源码文件 | 行号 | 硬编码内容 | 说明 |
|---------|------|-----------|------|
| `lib/domain/models/base_number_selection_record.dart` | 41 | `this.maxValue = 13000` | 最大条文数默认值 |
| `lib/domain/models/huang_ji_number.dart` | 139 | `if (originalNumber > 13000)` | 条文数边界判断 |
| `lib/features/huang_ji/huang_ji_formula_data_v2.dart` | 171 | `if (rawNumber > 13000)` | 条文数边界判断 |
| `lib/features/huang_ji/huang_ji_formula_data_v2.dart` | 399 | `if (rawValue > 13000)` | 条文数边界判断 |
| `lib/features/huang_ji/huang_ji_v2_use_case.dart` | 128 | `maxValue: 13000` | 最大条文数配置 |
| `lib/features/huang_ji/huang_ji_v2_use_case.dart` | 181 | `maxValue: 13000` | 最大条文数配置 |
| `lib/features/liuqinkaoke/models/liuqinkaoke_models.dart` | 18 | `rawNumber > 13000 ? rawNumber - 12000 : rawNumber` | 条文数边界处理 |
| `lib/service/strategy/si_men_fa_strategy.dart` | 167 | `if (eachNum > 13000)` | 条文数边界判断 |
| `lib/service/strategy/si_men_fa_strategy.dart` | 169 | `if (tmpRes > 13000)` | 条文数边界判断 |
| `lib/utils/tiao_wen_number_calculator.dart` | 136 | `if (eachNum > 13000)` | 条文数边界判断 |
| `lib/utils/tiao_wen_number_calculator.dart` | 138 | `if (tmpRes > 13000)` | 条文数边界判断 |

### 3. 硬编码配置 5000/30（候选生成配置）

| 源码文件 | 行号 | 硬编码内容 | 说明 |
|---------|------|-----------|------|
| `lib/features/huang_ji/huang_ji_v2_use_case.dart` | 125 | `offset: 30` | 候选偏移量 |
| `lib/features/huang_ji/huang_ji_v2_use_case.dart` | 178 | `offset: 30` | 候选偏移量 |

### 4. 硬编码条文编号

| 源码文件 | 行号 | 硬编码内容 | 说明 |
|---------|------|-----------|------|
| `lib/service/strategy/yuan_tang_strategy.dart` | 多处 | `3387`, `2477` | 震震/坤震加则法条文编号 |

### 5. 硬编码卦名（switch-case）

| 源码文件 | 行号 | 硬编码内容 |
|---------|------|-----------|
| `lib/service/strategy/xian_houtian_qu_shu_strategy.dart` | 480-494 | 八卦名称 switch-case（乾/坤/震/巽/坎/离/艮/兑） |

### 6. 硬编码干支（UI层）

| 源码文件 | 行号 | 硬编码内容 |
|---------|------|-----------|
| `lib/presentation/pages/verticle_layout/base_18_page.dart` | 163 | `庚寅`（硬编码干支显示） |
| `lib/presentation/pages/verticle_layout/verticle_layout_page.dart` | 148 | `甲辰`（硬编码干支显示） |
| `lib/presentation/pages/verticle_layout/verticle_layout_page.dart` | 225 | `庚寅`（硬编码干支显示） |

---

## 第二部分：测试与硬编码映射关系

| 模块 | 源码硬编码(文件:行号) | 对应测试(文件:行号) | 状态 |
|------|----------------------|----------------------|------|
| **yuan_tang_gua** | `yuan_tang_calculator.dart:151,153,233,235,1293,1296` (魔法数字25/30) | `test/yuan_tang_test.dart:15-61` | ✅ 已覆盖 |
| **yuan_tang_gua** | `utils/utils.dart:467,470,586,589` (魔法数字25/30) | `test/yuan_tang_test.dart:15-61` | ✅ 已覆盖 |
| **yuan_tang_strategy** | `yuan_tang_strategy.dart` (条文编号3387/2477) | `test/service/strategy/yuan_tang_strategy_test.dart:720-732` | ✅ 已覆盖 |
| **yuan_tang_strategy** | `yuan_tang_strategy.dart` (硬编码八字: 己酉丙子辛巳戊子) | `test/service/strategy/yuan_tang_strategy_test.dart:537-753` | ✅ 已覆盖 |
| **huang_ji_formula** | `huang_ji_formula_data_v2.dart:171,399` (13000) | `test/domain/models/huang_ji_formula_data_v2_test.dart:300-340` | ✅ 已覆盖 |
| **huang_ji_formula** | `huang_ji_number.dart:139` (13000) | `test/domain/models/huang_ji_formula_data_v2_test.dart:300-340` | ✅ 已覆盖 |
| **huang_ji_formula** | `huang_ji_formula_data_v2.dart:171,399` (13000) | `test/domain/models/huang_ji_formula_raw_number_integration_test.dart:200-225` | ✅ 已覆盖 |
| **huang_ji_formula** | `tiao_wen_number_calculator.dart:136,138` (13000) | `test/domain/models/huang_ji_formula_raw_number_integration_test.dart:200-225` | ✅ 已覆盖 |
| **gua_64** | `xian_houtian_qu_shu_strategy.dart:480-494` (卦名switch) | `test/gua_64_test.dart:7-23` | ✅ 已覆盖 |
| **tiao_wen** | `tiao_wen_list_result.dart` (条文模型) | `test/domain/models/tiao_wen_list_result_test.dart:9-170` | ✅ 已覆盖 |
| **huang_ji_v2** | `base_number_selection_record.dart:41` (13000) | `test/huang_ji_v2_models_test.dart:9-18` | ✅ 已覆盖 |
| **huang_ji_v2** | `huang_ji_v2_use_case.dart:125,128,178,181` (5000/13000/30) | `test/huang_ji_v2_models_test.dart:9-18` | ✅ 已覆盖 |
| **tiao_wen** | `tiao_wen_repository.dart` (条文仓库) | `test/tiao_wen_repository_test.dart:25-175` | ✅ 已覆盖 |
| **si_men_fa_strategy** | `si_men_fa_strategy.dart:167,169` (13000) | **无对应测试** | ⚠️ 无测试 |
| **liuqinkaoke_models** | `liuqinkaoke_models.dart:18` (13000) | **无对应测试** | ⚠️ 无测试 |
| **presentation** | `base_18_page.dart:163`, `verticle_layout_page.dart:148,225` (干支) | **无对应测试** | ⚠️ 无测试 |

---

## 第三部分：残留测试排查

### 已禁用的测试文件

| 文件 | 状态 | 说明 |
|------|------|------|
| `test/disabled/huang_ji_formula_v2_integration_test.dart` | ❌ 残留测试 | 测试 `huang_ji_formula_v2.dart` 的集成逻辑，已被禁用 |
| `test/disabled/verify_raw_number_fix.dart` | ❌ 残留测试 | 验证 rawNumber 修复的脚本，已被禁用 |

### 测试覆盖分析

- ✅ **已覆盖**：13 处源码硬编码有对应测试
- ⚠️ **无测试**：3 处源码硬编码无对应测试（`si_men_fa_strategy`, `liuqinkaoke_models`, `presentation`）
- ❌ **残留测试**：2 个禁用测试文件（内容仍引用硬编码数据）

---

## 第四部分：硬编码集中问题分析

### 问题1：魔法数字 25/30 重复硬编码

`calculateGuaNum(total, threshold, defaultValue)` 函数的阈值参数在以下位置重复硬编码：
- `yuan_tang_calculator.dart` 6 处
- `utils/utils.dart` 4 处

**建议**：将 25/30 提取为 `constants.dart` 中的常量 `kYuanTangTianShuThreshold = 25` 和 `kYuanTangDiShuThreshold = 30`。

### 问题2：基数 13000 分散在 11 处

条文数边界值 `13000` 在 11 个文件中硬编码，一旦需要修改（如支持更多条文），维护成本极高。

**建议**：提取为 `constants.dart` 中的 `kMaxTiaoWenNumber = 13000`。

### 问题3：残留测试未清理

`test/disabled/` 目录下的 2 个测试文件虽然被禁用，但仍包含硬编码数据，容易造成混淆。

**建议**：确认不再需要后删除，或移入 `test/archive/` 目录。
