下面是一份基于实际代码审计修订后的版本，可直接交给 AI agents 执行。目标不是改 theme token，而是先把“UI Widget 内混入推算/状态/策略调用”的部分拆开，让后续 Theme Phase 6 只碰展示层。

---

# 铁板神数 UI/逻辑解耦执行状态

> 更新于 2026-06-18

## 当前状态总览

| Phase | 状态 | 说明 |
|-------|------|------|
| Phase 0 基线 | ✅ 完成 | `.baseline_*.txt` 已删除（临时产物），analyze 1399 info/0 error，use_case 测试全部恢复 47/47 |
| Phase 1 删除 shared/presentation | ✅ 完成 | 38 个文件已删除，`lib/` 和 `test/` 零引用残留 |
| Phase 2 语义色常量 | ✅ 完成 | `tie_ban_semantic_colors.dart` 已创建，未在 Widget 中替换使用（下个分支执行） |
| Phase 3 拆 GuaZhongCard | ⏸️ 未执行 | Provider/setParams 仍在 card 内，计划在 theme token 迁移分支中执行 |
| Phase 4 拆 YuanTang | ⏸️ 部分执行 | `yuan_tang_liuyun_view_model.dart` 已创建但未接入，Widget 仍有 Strategy 透传 |
| Phase 5 拆 KaoDingLiuQin | ⏸️ 未执行 | |
| Phase 6 页面编排确认 | ⏸️ 未执行 | |
| Phase 7 准入审查 | ⏸️ 未执行 | |

## 关键测试状态

| 测试套件 | 结果 | 说明 |
|---------|------|------|
| `test/usecases/` | ✅ 47/47 通过 | 全部恢复 |
| `test/yuan_tang_test.dart` | ✅ 46/46 通过 | |
| `test/shaozishu/` | ✅ 24/24 通过 | |
| `test/service/strategy/` | ❌ 329/401 通过 | 72 失败为预存上游枚举迁移问题，与本次改动无关 |
| `test/features/kao_ding_liu_qin/` | ✅ 16/16 通过 | |

## Theme 迁移准入基线

> 基于 `refactor/ui_logic_splited` (c8dbfab) 当前状态

### 主题系统现状

| 项 | 状态 |
|---|------|
| 本地主题系统 | ✅ `lib/presentation/theme/app_theme_data.dart` — 5 套预设（天青/朱砂/墨玉/藤黄/紫檀），含 Gradient、Material 3 兼容 |
| ThemeViewModel | ✅ 已有，将 AppThemeData 转为 ThemeData |
| 外部 package 依赖 | ❌ 无 `package:theme`、`package:xuan_theme`、`package:xuan_config` 等 |
| 测试目录 `test/theme/` | ❌ 不存在 |

### Widget 迁移分类

**A 类 — 可立即迁移（纯展示，零业务依赖）：**

| Widget | 行数 | 说明 |
|--------|------|------|
| `loading_widget.dart` | ~15 | 纯 loading 指示器 |
| `empty_state_widget.dart` | ~50 | 空状态占位 |
| `error_widget.dart` | ~50 | 错误状态展示 |
| `tiao_wen_item.dart` | ~80 | 单条文列表项 |
| `tiao_wen_list_view.dart` | ~120 | 条文列表容器 |
| `calculation_summary.dart` | ~100 | 计算结果摘要 |
| `strategy_header.dart` | ~30 | 策略头部标题 |
| `section_header.dart` | ~50 | 章节标题组件 |
| `gradient_card.dart` | ~60 | 渐变卡片容器 |
| `animated_button.dart` | ~80 | 动画按钮 |
| `interactive_step_indicator.dart` | ~60 | 步骤指示器 |

**B 类 — 需少量适配（接收 ViewModel，仅引用语义色+Theme.of）：**

| Widget | 行数 | 说明 |
|--------|------|------|
| `xian_houtian_qu_shu_card.dart` | 899 | 接收 ViewModel，仅管理展开状态 |
| `qian_hou_gua_card.dart` | 723 | 接收 ViewModel，Stateless 渲染 |
| `liu_yao_gan_zhi_he_card.dart` | 898 | 接收 ViewModel，仅管理展开状态 |
| `gua_yao_gan_zhi_he_card.dart` | 509 | 接收 ViewModel |
| `xian_houtian_jia_ze_card.dart` | 683 | 接收 ViewModel |
| `ba_gua_jia_ze_card.dart` | 440 | 接收 ViewModel |
| `tai_xuan_dual_method_card.dart` | 324 | 纯展示组件 |
| `tai_xuan_method_section.dart` | 180 | 纯展示组件 |
| `strategy_card.dart` | 175 | 容器组件 |

**C 类 — 需先解耦再迁移（含 Strategy/Provider/Repository 引用）：**

| Widget | 问题 | 归类至 |
|--------|------|--------|
| `gua_zhong_card.dart` | Provider 创建 + setParams | Phase 3 |
| `yuan_tang_liuyun_section.dart` | 直接调用 YuanTangStrategy | Phase 4 |
| `yuan_tang_card.dart` | 持有并透传 YuanTangStrategy | Phase 4 |
| `kao_ding_liu_qin_card.dart` | import strategy 文件 | Phase 5 |

### 当前资源引用统计

| 源 | 数量 | 说明 |
|----|------|------|
| `lib/presentation/` 内 `Colors.` 引用 | ~668 | 需迁移到 theme token |
| `lib/presentation/` 内 `const Color(0x` 引用 | ~120 | 需替换为语义常量 |
| `lib/presentation/` 内 Style 类引用 | ~30 | 可提取为 token |

### Flutter Analyze 基线及降噪计划

**当前 1399 issues，0 error。**

| 类别 | 数量 | 说明 | 降噪策略 |
|------|------|------|----------|
| `avoid_print` (test/) | 746 | 测试调试输出 | 在测试文件加 `// ignore_for_file: avoid_print` |
| `avoid_print` (lib/) | 38 | 7 个 lib 文件，集中在 huang_ji 模块 | 改用 `debugPrint()` 或日志 |
| `withOpacity` deprecation | 302 | 多文件散布 | 批量替换 `.withOpacity(x)` → `.withValues(alpha: x)` |
| `surfaceVariant` deprecation | 37 | 约 10 个文件 | 替换为 `surfaceContainerHighest` |
| `timezone` 非依赖导入 | 10 | 直接 import 但未声明 | 在 pubspec.yaml 补充 |
| `http:` 不安全协议 | 6 | 硬编码 URL | 替换为 `https:` |
| `generateTianDiGua` deprecation | 4 | 旧 API 调用 | 替换为 `calculateXianTianGua` |
| Enum 类型比较 | 4 | 策略测试中的遗留 | 已部分在 use_case 修复，strategy 层待修 |
| 命名/风格 | ~50 | 下划线命名、braces 等 | 可接受或一次性格式化 |
| 其他 deprecation/import | ~202 | 零星问题 | 逐项审查 |

**降噪目标：** 先降到 ~200（主要修复 deprecation + 依赖 + enum 比较），最终降到 ~50（只保留命名风格类）。实现方式：下一分支执行。

### 强制门禁（执行后必须验证）

```bash
# 新增 theme 治理测试
test/theme/theme_token_governance_test.dart  # 确保 no import package:xuan_config

# 边界检查
grep -rn "package:xuan_config\|package:theme\|package:xuan_theme" lib/
# 期望：无命中

# 首批 A 类 Widget 迁移后检查
rg -n "Colors\.\|const Color(0x" \
  lib/presentation/widgets/loading_widget.dart \
  lib/presentation/widgets/empty_state_widget.dart \
  lib/presentation/widgets/error_widget.dart \
  lib/presentation/widgets/tiao_wen_item.dart \
  lib/presentation/widgets/calculation_summary.dart
# 期望：无硬编码色值
```

---

# 铁板神数 UI/逻辑解耦计划（修订版 v2）

## 可行性评估摘要

**结论：高度可行。** `lib/presentation/viewmodels/` 下已有 16 个 ViewModel，大部分卡片（xian_houtian_qu_shu_card、qian_hou_gua_card、liu_yao_gan_zhi_he_card 等）已通过 ViewModel 完成解耦；`yuan_tang_card.dart` 仍有 Strategy 透传字段，必须在 Phase 4 移除后才可进入视觉迁移。34 个策略测试、5 个 use case 测试均存在且可作为回归验证入口。

真正需要动手的是 5 个 Widget/业务耦合点、2 个 YuanTang 调用方同步适配点，以及 1 个废弃目录清理。

## 总目标

移除 Widget 内对 Strategy 的直接 import/调用，把 `TiaoWenRepository` 数据拉取从 Widget 内部迁出。完成后 Widget 只负责渲染和交互回调。

## 执行原则

1. 不允许整包硬套 theme token。
2. 不允许先做视觉迁移再解耦 Widget。
3. 纯展示 Widget 可直接迁移；复杂 Widget 必须先完成 UI/业务边界拆分。
4. 每一步必须保持算法输出不变。
5. 禁止在 Widget 中新增 `calculate*`、`strategy.*`、Repository、UseCase 依赖。
6. 业务语义色（方案 1/2/3）不可粗暴替换成 `primary`/`secondary`。

---

## Phase 0：基线与边界确认

### 目标

跑基线、输出文件分类清单、确认 canonical 目录。

### 步骤

1. **保存基线**

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-tiebanshenshu
flutter analyze > .baseline_analyze.txt 2>&1
flutter test > .baseline_test.txt 2>&1
```

2. **确认 canonical 目录**

- `lib/presentation` 是 canonical 目录（16 处代码引用）。
- `lib/shared/presentation` 在代码中零引用，是废弃副本。
- `lib/shared/models`（注意不是 shared/presentation）仍有 3 处在 `shaozishu` 中的引用，**不能删除**。

3. **文件分类清单**

**直接迁移（无需重构，已满足解耦要求）：**

| 文件 | 行数 | 当前状态 |
|------|------|---------|
| `lib/presentation/widgets/xian_houtian_qu_shu_card.dart` | 899 | 接收 ViewModel，仅管理展开状态 |
| `lib/presentation/widgets/qian_hou_gua_card.dart` | 723 | 接收 ViewModel，Stateless 渲染 |
| `lib/presentation/widgets/liu_yao_gan_zhi_he_card.dart` | 898 | 接收 ViewModel，仅管理展开状态 |
| `lib/presentation/widgets/gua_yao_gan_zhi_he_card.dart` | 509 | 接收 ViewModel |
| `lib/presentation/widgets/xian_houtian_jia_ze_card.dart` | 683 | 接收 ViewModel |
| `lib/presentation/widgets/ba_gua_jia_ze_card.dart` | 440 | 接收 ViewModel |
| `lib/presentation/widgets/tai_xuan_dual_method_card.dart` | 324 | 纯展示组件 |
| `lib/presentation/widgets/strategy_card.dart` | 175 | 容器组件 |
| `lib/presentation/widgets/yuan_tang_dayun_widget.dart` | 224 | 纯展示组件 |
| `lib/presentation/widgets/yuan_tang_liunian_list.dart` | 313 | 纯展示组件 |
| `lib/presentation/widgets/yuan_tang_liuyue_panel.dart` | 435 | 纯展示组件 |
| 所有低风险组件 | — | gradient_card, section_header, loading, empty, error, tiao_wen_item, tiao_wen_list_view, calculation_summary |
| `features/kao_ke/widgets/*` 中除 `dou_jia_yi_selection_table.dart` 外的组件 | — | gua_display_widget, ke_selection_table, method_selector_widget 等；`dou_jia_yi_selection_table.dart` 需在 Phase 5 重构 |

**需重构（目前仍耦合业务逻辑）：**

| 文件 | 行数 | 问题 | Phase |
|------|------|------|-------|
| `lib/presentation/widgets/gua_zhong_card.dart` | 594 | build 内创建 Provider + `setParams()`；`_getPlanColor()` 硬编码方案色 | Phase 3 |
| `lib/presentation/widgets/yuan_tang_liuyun_section.dart` | 465 | 直接 import 并调用 `YuanTangStrategy.calculateAllLiunianGua()` / `calculateLiuyueForAge()` | Phase 4 |
| `lib/presentation/widgets/yuan_tang_card.dart` | 951 | 持有 `YuanTangStrategy? strategy` 并透传给 liuyun section（仅 import + 持有 + 透传，不调用算法） | Phase 4 |
| `lib/presentation/widgets/kao_ding_liu_qin_card.dart` | 342 | import `kao_ding_liu_qin_strategy.dart`（需确认是否仅 import 还是实际调用） | Phase 5 |
| `lib/features/kao_ke/widgets/dou_jia_yi_selection_table.dart` | 182 | `initState()` 内 `Provider.of<TiaoWenRepository>` 拉取内容 | Phase 5 |

**页面确认（需检查不直接执行策略计算）：**

| 文件 | 行数 | 检查点 | Phase |
|------|------|--------|-------|
| `lib/presentation/pages/strategy_demo_page.dart` | 1014 | 第 773 行 `YuanTangStrategy()` 直接创建实例并透传；import yuan_tang_strategy.dart | Phase 4 |
| `lib/features/yuan_tang_gua/yuan_tang_info.dart` | 约 170 | 调用 `YuanTangCard(... strategy: strategy)`，需随 `YuanTangCard.strategy` 字段移除同步适配 | Phase 4 |
| `lib/features/kao_ke/kao_ke_interactive_page.dart` | 678 | 已通过 ViewModel 管理，仅需确认 | Phase 6 |
| `lib/features/kao_ding_liu_qin/pages/kao_ding_liu_qin_page.dart` | 528 | `_calculateAll()` → `viewModel.calculateAll()`，需确认 viewModel 层调用链 | Phase 6 |

### 验收标准

```bash
flutter analyze  # 保存基线，记录现有 warning
flutter test     # 全部通过
```

---

## Phase 1：废弃 `lib/shared/presentation` 删除

### 目标

安全删除零引用的废弃目录 `lib/shared/presentation/`。

### 警告

**不要删除 `lib/shared/models/`** — 该目录有 3 处在 `shaozishu` 中的引用。仅删除 `lib/shared/presentation/`。

### 步骤

1. **扫描引用**

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-tiebanshenshu
# 确认 shared/presentation 无任何代码引用
grep -rn "shared/presentation" lib/ test/ 2>/dev/null
# 应输出空（或仅 docs/ 下的文档引用）
```

2. **备份验证**

```bash
# 创建唯一备份（以防万一，避免覆盖旧备份）
BACKUP_DIR="/tmp/xuan-tiebanshenshu-shared-presentation-backup-$(date +%Y%m%d%H%M%S)"
test -d lib/shared/presentation
cp -R lib/shared/presentation "$BACKUP_DIR"
echo "Backup saved to $BACKUP_DIR"
```

3. **删除**

```bash
rm -rf lib/shared/presentation/
```

4. **验证**

```bash
flutter analyze   # 与基线对比，应无因删除导致的新增错误
flutter test      # 应全部通过
```

---

## Phase 2：业务语义色常量

### 目标

给方案 1/2/3 的 3 种业务语义色建立命名常量。注意：本项目已大量使用 `theme.colorScheme.primary/secondary/tertiary` 用于纯视觉颜色，**不需要**大型 Style Adapter。

### 新增文件

```dart
// lib/presentation/styles/tie_ban_semantic_colors.dart

import 'package:flutter/material.dart';

/// 铁板神数业务语义色
///
/// 这些颜色有特定业务含义（方案编号），不可与 Flutter theme token 混淆。
/// 后续 Theme Phase 6 可映射到具体色值，但语义名称必须保留。
class TieBanSemanticColors {
  const TieBanSemanticColors._();

  /// 方案1：取1代替0（推荐方案）
  static const Color plan1 = Color(0xFF2196F3); // Blue

  /// 方案2：取卦先天数
  static const Color plan2 = Color(0xFF4CAF50); // Green

  /// 方案3：保留10（五位数）
  static const Color plan3 = Color(0xFFFF9800); // Orange

  /// 未知方案（fallback）
  static const Color planUnknown = Color(0xFF9E9E9E); // Grey
}
```

### 验收标准

- `gua_zhong_card.dart` 中 `Colors.blue/green/orange` 方案色引用替换为 `TieBanSemanticColors.plan1/plan2/plan3`
- 纯视觉 colorScheme 引用保持不变
- `flutter test` 全部通过

---

## Phase 3：拆 `GuaZhongCard`

### 目标

移除 Widget 内部的 Provider 创建和 `setParams()` 调用，将方案色改为语义常量引用。

### 当前问题

- `build()` 中通过 `ChangeNotifierProvider` 创建 `GuaZhongViewModel` 并调用 `setParams(eightChars:)`
- `_getPlanColor()` 返回硬编码 `Colors.blue/green/orange`
- `_buildGuaSection()` 中调用 `viewModel.filteredTiaoWenNumbersWithLabel.where()` 做业务过滤

### 执行要求

1. **Widget 改为接收 ViewModel 参数**

   ```dart
   // Before
   class GuaZhongCard extends StatelessWidget {
     final EightChars eightChars;
     // build() 内: ChangeNotifierProvider + setParams()
   }

   // After
   class GuaZhongCard extends StatelessWidget {
     final GuaZhongViewModel viewModel;
     // Widget 只渲染，不触碰 Provider
   }
   ```

2. **`_getPlanColor()` → 引用 `TieBanSemanticColors`**

   ```dart
   // Before
   Color _getPlanColor(int planNumber) {
     switch (planNumber) {
       case 1: return Colors.blue;
       case 2: return Colors.green;
       case 3: return Colors.orange;
       default: return Colors.grey;
     }
   }

   // After
   Color _getPlanColor(int planNumber) => switch (planNumber) {
     1 => TieBanSemanticColors.plan1,
     2 => TieBanSemanticColors.plan2,
     3 => TieBanSemanticColors.plan3,
     _ => TieBanSemanticColors.planUnknown,
   };
   ```

3. **方案选择区域中 `secondary` 装饰色同步更新**

   `CheckboxListTile` 的 `secondary` 圆圈色和 `activeColor` 改为使用 `TieBanSemanticColors`。

4. **将 `filteredTiaoWenNumbersWithLabel.where()` 过滤逻辑下沉到 ViewModel**

   在 `GuaZhongViewModel` 中新增 getter：

   ```dart
   List<(int, int, String)> getFilteredNumbersForSection(String sectionTitle) {
     return filteredTiaoWenNumbersWithLabel.where((item) {
       if (sectionTitle == '年月卦') return item.$3.startsWith('年月卦');
       return item.$3.startsWith('日时卦');
     }).toList();
   }
   ```

   Widget 中改为 `viewModel.getFilteredNumbersForSection(title)`。

### 验收标准

- `gua_zhong_card.dart` 中不得出现：
  - `ChangeNotifierProvider(`
  - `setParams(`
  - `context.read<GuaZhongViewModel>()`
  - `context.watch<GuaZhongViewModel>()`
  - `Colors.blue/green/orange` 用作方案色
- 调用方同步适配（`strategy_demo_page.dart` 等）— 改为在页面层创建/获取 ViewModel 并传入 Widget
- 现有测试通过：

```bash
flutter test test/service/strategy/gua_zhong_three_plans_test.dart
flutter test test/usecases/gua_zhong_use_case_test.dart
```

---

## Phase 4：拆 `YuanTangLiuyunSection` + `YuanTangCard`

### 目标

1. `YuanTangLiuyunSection` 不再 import 或调用 `YuanTangStrategy`
2. `YuanTangCard` 不再持有并透传 `YuanTangStrategy? strategy` 字段

### 当前问题

- `yuan_tang_liuyun_section.dart`：Widget 持有 `YuanTangStrategy strategy` 作为构造参数；`initState()` 中调用 `strategy.calculateAllLiunianGua()`；`_onLiunianTap()` 中调用 `strategy.calculateLiuyueForAge()`；同文件内的 `YuanTangLiuyunCompactSection` 同样在 build 中调用 `strategy.calculateAllLiunianGua()`
- `yuan_tang_card.dart`：第 4 行 import `yuan_tang_strategy.dart`；第 23 行持有 `YuanTangStrategy? strategy`；第 945 行 `strategy: widget.strategy!` 仅透传
- `strategy_demo_page.dart`：第 773 行 `final strategy = YuanTangStrategy()` 创建实例；第 780 行 `strategy: strategy` 传给 YuanTangCard
- `features/yuan_tang_gua/yuan_tang_info.dart`：调用 `YuanTangCard(... strategy: strategy)`，移除 `YuanTangCard.strategy` 字段时必须同步适配

### 执行要求

1. **新增 `YuanTangLiuyunViewModel` 或在现有 `YuanTangViewModel` 中扩展**

   将流年/流月计算逻辑迁入 ViewModel：

   ```dart
   class YuanTangLiuyunViewModel extends ChangeNotifier {
     List<YuanTangLiunianGua> _allLiunianList = [];
     final Map<int, List<YuanTangLiuyueGua>> _liuyueCache = {};
     int? _selectedLiunianAge;

     void initialize(YuanTangBaseNumberModel model, int birthYear) { ... }
     void selectLiunianAge(int age) { ... }

     List<YuanTangLiunianGua> get allLiunianList => _allLiunianList;
     // ... getters for filtered lists
   }
   ```

2. **`YuanTangLiuyunSection` 改为接收 ViewModel**

   ```dart
   // Before
   class YuanTangLiuyunSection extends StatefulWidget {
     final YuanTangBaseNumberModel model;
     final int birthYear;
     final YuanTangStrategy strategy;  // ← 算法依赖
   }

   // After
   class YuanTangLiuyunSection extends StatefulWidget {
     final YuanTangLiuyunViewModel viewModel;  // ← 只接收 UI 状态
   }
   ```

3. **`YuanTangLiuyunCompactSection` 同步处理**

4. **`YuanTangCard` 移除 strategy 字段**

   ```dart
   // Before
   final YuanTangBaseNumberModel? baseNumberModel;
   final int? birthYear;
   final YuanTangStrategy? strategy;

   // After: 移除 strategy 字段
   // 流运系统由独立的 YuanTangLiuyunViewModel 管理，不再通过 YuanTangCard 透传
   ```

   相应地移除 `import yuan_tang_strategy.dart`（但保留其他现有 imports）。

5. **`strategy_demo_page.dart` 适配**

   移除第 773 行 `final strategy = YuanTangStrategy()`，不再创建 strategy 实例用于 UI 层。

6. **`features/yuan_tang_gua/yuan_tang_info.dart` 适配**

   移除传给 `YuanTangCard` 的 `strategy:` 参数；如该页面仍需要流运数据，必须改为由 ViewModel/UseCase 预先提供，不允许继续通过 Widget 透传 Strategy。

### 验收标准

- `yuan_tang_liuyun_section.dart` 不得 `import yuan_tang_strategy.dart`
- `yuan_tang_card.dart` 不得 import 或持有 `YuanTangStrategy`
- `strategy_demo_page.dart` 不得创建 `YuanTangStrategy()` 实例用于 UI
- `features/yuan_tang_gua/yuan_tang_info.dart` 不得向 `YuanTangCard` 传 `strategy:`
- Widget 中不得出现 `calculateAllLiunianGua`、`calculateLiuyueForAge`、`strategy.`
- 算法测试通过：

```bash
flutter test test/service/strategy/yuan_tang_strategy_test.dart
flutter test test/service/strategy/yuan_tang_dayun_test.dart
flutter test test/yuan_tang_test.dart
```

---

## Phase 5：拆 `KaoDingLiuQinCard` + `DouJiaYiSelectionTable`

### 目标

1. `KaoDingLiuQinCard` 不再 import strategy 文件
2. `DouJiaYiSelectionTable` 不再在 `initState` 内直接拉取 Repository

### 当前问题

- `kao_ding_liu_qin_card.dart`：第 4 行 `import '../../features/kao_ding_liu_qin/services/kao_ding_liu_qin_strategy.dart'`
- `kao_ding_liu_qin_view_model.dart`：第 6 行同样 import 了同一文件（ViewModel 层引用 Strategy 是合理的）
- `dou_jia_yi_selection_table.dart`：`initState()` 中 `Provider.of<TiaoWenRepository>(context, listen: false)` 拉取内容

### 执行要求

1. **`KaoDingLiuQinCard`**

   - 检查 Widget 内是否实际使用了 strategy 的类/方法（可能仅是冗余 import）
   - 如实际使用，改为通过 `KaoDingLiuQinViewModel` 暴露
   - 移除 import

2. **`DouJiaYiSelectionTable`**

   - 将 `TiaoWenRepository` 拉取逻辑移到 ViewModel 或父页面
   - Widget 改为接收预加载的 `Map<int, String>? contentMap` 作为构造参数
   - 移除 `Provider.of<TiaoWenRepository>` 调用

### 验收标准

- `kao_ding_liu_qin_card.dart` 不再 import strategy 文件
- `dou_jia_yi_selection_table.dart` 不再调用 `Provider.of<TiaoWenRepository>`
- 相关测试通过：

```bash
flutter test test/features/kao_ding_liu_qin/
```

---

## Phase 6：交互页面编排确认

### 目标

确认页面不直接执行策略计算，仅做编排。

### 范围

| 文件 | 检查点 | 当前判定 |
|------|--------|---------|
| `strategy_demo_page.dart` | import `yuan_tang_strategy.dart` + 第 773 行 `YuanTangStrategy()` | ⚠️ 需在 Phase 4 中一并修复 |
| `kao_ke_interactive_page.dart` | 调用 `viewModel.calculateFinalResults()` | ✅ 已通过 ViewModel |
| `kao_ding_liu_qin_page.dart` | `_calculateAll()` → `viewModel.calculateAll()` | ⚠️ 需确认 ViewModel 层调用链不泄漏到页面 |
| `tai_xuan_interactive_page.dart` | 确认无直接策略调用 | 待检查 |
| `four_doors_and_gun_fa_page.dart` | 确认无直接策略调用 | 待检查 |

### 执行要求

- 页面中 `build()` 和 `_build*()` 只处理布局、控件、回调
- 页面状态来自 ViewModel
- 如有直接 strategy import/调用，下沉到 ViewModel/UseCase

### 验收标准

- 页面文件不直接 import Strategy 模块
- 功能测试通过：

```bash
flutter test test/features/kao_ke/
flutter test test/features/kao_ding_liu_qin/
flutter test test/features/liuqinkaoke/
```

---

## Phase 7：准入前审查

### 目标

确认 5 个重构项 + 页面编排全部完成，系统进入可进行 theme token 迁移的状态。

### 准入条件

1. `gua_zhong_card.dart` 不再有 Provider 创建、`setParams`、方案硬编码色
2. `yuan_tang_liuyun_section.dart` 不再 import/call `YuanTangStrategy`
3. `yuan_tang_card.dart` 不再持有 `YuanTangStrategy? strategy` 字段
4. `kao_ding_liu_qin_card.dart` 不再 import strategy
5. `dou_jia_yi_selection_table.dart` 不再调用 `Provider.of<TiaoWenRepository>`
6. 所有策略测试、use case 测试、功能测试通过
7. `flutter analyze` 无新增 warning（与基线对比）
8. 方案 1/2/3 颜色使用 `TieBanSemanticColors` 常量

### 禁止进入的情况

- 任一 Widget 仍有 `strategy.` import 或调用
- 任一 Widget 仍有 `calculate*` 算法调用
- 任一 Widget 仍用裸色值表达方案语义

---

## 防假性通过 / 假性完成门禁

### 目标

防止 agent 只凭“代码已改”“测试应当通过”“未看到错误”就宣布完成。任何 Phase 的完成结论必须由新鲜命令输出、边界扫描和 diff 证据共同支撑。

### 硬性规则

1. **不能用口头结论代替证据**
   - 不接受：“已完成”“应该通过”“看起来没问题”“agent 自检通过”。
   - 必须提供：执行命令、退出码、关键输出摘要、失败/跳过项说明。

2. **不能只跑局部测试就宣布 Phase 完成**
   - 局部测试只能证明对应模块。
   - 每个 Phase 最低要求：对应专项测试 + `flutter analyze`。
   - Phase 7 最低要求：`flutter analyze` + `flutter test` + 所有边界扫描。

3. **不能只看测试绿就宣布 UI/逻辑解耦完成**
   - 必须额外跑 import/调用边界扫描。
   - 如测试绿但扫描命中禁止模式，结论仍为不通过。

4. **不能把旧问题伪装成本次通过**
   - Phase 0 必须保存 `.baseline_analyze.txt` 和 `.baseline_test.txt`。
   - 后续 Phase 必须说明新增/减少/不相关的 analyze/test 差异。
   - 如果基线本身失败，只能报告“未达到全量通过，当前无新增失败/新增错误”，不能报告“全量通过”。

5. **不能扩大范围制造假性完成**
   - 只能修改本计划列出的文件及必要的调用方/ViewModel/测试。
   - 不得通过删除功能、跳过渲染、注释测试、修改算法期望值来获得绿灯。

### 必跑边界扫描

Phase 3 完成后必须跑：

```bash
rg -n "ChangeNotifierProvider\\(|setParams\\(|context\\.(read|watch)<GuaZhongViewModel>|Colors\\.(blue|green|orange)" lib/presentation/widgets/gua_zhong_card.dart
```

期望：无命中；如命中，必须逐条解释是否为非方案色或遗留耦合。无法解释则不通过。

Phase 4 完成后必须跑：

```bash
rg -n "yuan_tang_strategy|YuanTangStrategy|strategy:|strategy\\.|calculateAllLiunianGua|calculateLiuyueForAge" \
  lib/presentation/widgets/yuan_tang_liuyun_section.dart \
  lib/presentation/widgets/yuan_tang_card.dart \
  lib/presentation/pages/strategy_demo_page.dart \
  lib/features/yuan_tang_gua/yuan_tang_info.dart
```

期望：Widget 层和页面透传链无命中；如果 ViewModel/UseCase 层仍引用 Strategy，必须明确说明该引用不在上述文件内且属于业务层。

Phase 5 完成后必须跑：

```bash
rg -n "kao_ding_liu_qin_strategy|Provider\\.of<TiaoWenRepository>|TiaoWenRepository|initState\\(\\)" \
  lib/presentation/widgets/kao_ding_liu_qin_card.dart \
  lib/features/kao_ke/widgets/dou_jia_yi_selection_table.dart
```

期望：`kao_ding_liu_qin_card.dart` 无 strategy import；`dou_jia_yi_selection_table.dart` 无 Repository/Provider 拉取。`initState()` 若仍存在，必须只处理纯 UI 状态。

Phase 6/7 完成后必须跑：

```bash
rg -n "import .*strategy|Strategy\\(|strategy\\.|calculate[A-Z]" \
  lib/presentation/pages \
  lib/features/*/*page*.dart \
  lib/features/*/*_page.dart
```

期望：页面层无直接策略创建/调用；允许 ViewModel 文件命中，但交付报告必须列出命中位置并说明边界合理性。

删除 `lib/shared/presentation/` 后必须跑：

```bash
test ! -d lib/shared/presentation
rg -n "shared/presentation" lib test
rg -n "shared/models" lib/shaozishu
```

期望：`shared/presentation` 在 `lib/` 和 `test/` 无引用；`shared/models` 在 shaozishu 中仍可被找到，证明没有误删。

### 交付证据最低格式

每个 Phase 的交付报告必须包含以下 8 项，缺一项即视为未完成：

1. **范围证据**：本 Phase 修改文件列表，附 `git diff --name-only` 输出摘要。
2. **边界证据**：上述对应 `rg` 扫描命令及输出摘要。
3. **测试证据**：实际运行的测试命令、退出码、通过/失败数量。
4. **基线对比**：与 Phase 0 baseline 的新增错误/新增失败说明。
5. **算法不变证据**：相关 strategy/usecase 测试结果；不得修改算法测试期望值。
6. **语义色证据**：方案 1/2/3 是否仍使用 `TieBanSemanticColors`，不得退化为通用 theme token。
7. **残留风险**：未跑命令、跳过原因、仍存在的耦合或旧问题。
8. **准入结论**：只能写 `PASS`、`PARTIAL`、`FAIL` 三者之一；`PARTIAL`/`FAIL` 不允许进入下一 Phase。

### 独立复核要求

- Phase 3、Phase 4、Phase 5 完成后，必须由另一个 agent 或同一 agent 的独立复核轮次重新执行边界扫描和专项测试。
- 复核不能只阅读执行 agent 的报告，必须重新跑命令或读取最新文件。
- 复核报告必须明确写出“允许进入下一 Phase”或“不允许进入下一 Phase”。

### 一票否决

出现以下任一情况，直接判定为假性完成：

- 修改或删除算法测试期望值来通过测试。
- 注释、跳过、重命名测试来规避失败。
- Widget 层仍直接 import Strategy/Repository/UseCase。
- 页面层仍创建 Strategy 并向 Widget 透传。
- 删除 `lib/shared/models/` 或破坏 shaozishu 引用。
- 未运行 `flutter analyze` 却声称 analyze 通过。
- 未运行 `flutter test` 却声称全量测试通过。
- 只提供 agent 自述，没有命令输出摘要。

---

## 通用验收命令

每个 Phase 完成后必须运行：

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-tiebanshenshu
dart format lib test
flutter analyze
flutter test
```

针对风险模块补充：

```bash
flutter test test/service/strategy/
flutter test test/usecases/
flutter test test/features/kao_ke/
flutter test test/features/kao_ding_liu_qin/
```

---

## 交付证据要求

每个 agent 的交付报告必须包含：

1. 修改文件清单
2. 移除的 UI/逻辑混合点（具体行数/模式）
3. 新增的 ViewModel getter / 语义色引用
4. 业务语义色映射表

### 业务语义色映射表（仅 4 项）

| 语义名称 | 色值 | 用途 |
|---------|------|------|
| `plan1` | `#2196F3` Blue | 方案1：取1代替0 |
| `plan2` | `#4CAF50` Green | 方案2：取卦先天数 |
| `plan3` | `#FF9800` Orange | 方案3：保留10 |
| `planUnknown` | `#9E9E9E` Grey | 未知方案 fallback |

5. 测试命令和结果
6. 未解决风险
7. 是否允许进入 Theme Token 迁移的结论

---

## 注意事项

- 不要把 `Colors.blue` 统一改成 `theme.colorScheme.primary`，这会丢失方案色语义。
- 不要为了减小 Widget 文件而把逻辑搬到另一个 Widget 私有 helper；必须搬到 ViewModel 或 UseCase。
- 不要改算法测试期望值。视觉解耦不应改变任何条文编号、卦象、流年、流月、方案结果。
- 不要顺手重构不在清单内的算法服务。
- `lib/shared/models/` 有 3 处 shaozishu 引用，**不能删**。只删 `lib/shared/presentation/`。
- 如果 `flutter analyze` 起点已有旧问题，agent 必须记录 baseline，不得把无关旧问题混入本任务。

---

## 推荐执行顺序

```
Phase 0（基线 + 分类清单）
  → Phase 1（删除 shared/presentation：扫描 → 备份 → 删除 → 验证）
    → Phase 2（语义色常量）
      → Phase 3（GuaZhongCard：Provider + 方案色）
        → Phase 4（YuanTangLiuyunSection + YuanTangCard + strategy_demo_page + yuan_tang_info：Strategy 链）
          → Phase 5（KaoDingLiuQinCard + DouJiaYiSelectionTable：Strategy import + Repository 拉取）
            → Phase 6（页面编排确认）
              → Phase 7（准入审查）
```
