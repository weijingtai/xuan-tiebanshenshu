<!-- version: v1.0, date: 2026-06-10 -->

# xuan-tiebanshenshu 项目结构详情 (v1.0)

---

## 一、项目身份

| 项目 | 说明 |
|---|---|
| **名称** | `tiebanshenshu`（铁板神数） |
| **类型** | Flutter Module（可嵌入原生宿主应用） |
| **SDK** | Dart ^3.8.1 |
| **版本** | 1.0.0+1 |
| **Android 包名** | `com.example.tiebanshenshu` |
| **iOS Bundle ID** | `com.example.tiebanshenshu` |
| **开发框架** | SPEC-Driven Development（基于 `weijingtai/docs` 协同规范） |
| **入口** | `lib/main.dart` → 启动 `AlgorithmEditorApp`，初始路由 `/dev` |
| **状态管理** | `provider`（MultiProvider 注入 DateTimeProvider / ThemeViewModel / 策略层） |

---

## 二、顶层目录

```
xuan-tiebanshenshu/
├── .codegraph/                  # 代码图谱（自动生成）
├── .understand-anything/        # 代码理解缓存（自动生成）
├── docs/                        # 项目文档体系（含 SPEC、AI 协同 12 模块）
├── example/                     # 示例代码
├── lib/                         # 核心 Dart 源码 ★
├── test/                        # 单元测试
├── web/                         # Web 平台支持
├── pubspec.yaml                 # 项目依赖声明
├── pubspec.lock                 # 依赖锁定
├── analysis_options.yaml        # Lint 规则（继承 flutter_lints）
├── build.yaml                   # build_runner 配置（json_serializable）
├── AI_README.md                 # AI 协同入口（7 条核心原则 + SPEC Coding 工作流）
├── AGENTS.md / CLAUDE.md        # AI 工具接入指引
├── WARNING_README.md            # 警告说明
├── PROBLEM_SOLVED_huang_ji_loading.md  # 黄极加载问题修复记录
├── test_debug.dart              # 调试测试文件
├── .gitignore / .metadata       # 版本控制/Flutter 元数据
└── tiebanshenshu.iml / tiebanshenshu_android.iml  # IDE 配置
```

---

## 三、`lib/` 源码组织结构

项目采用**分层架构 + 功能模块**混合组织，存在已知冗余（`ui/` ↔ `presentation/`、`usecases/` ↔ `application/usecases/`、`service/` ↔ `application/services/` 部分重叠）。

```
lib/
├── main.dart                    # 应用入口，MultiProvider 注入 + MaterialApp
├── navigator.dart               # 路由生成器
├── enums.dart                   # 全局枚举
├── summary.md                   # 项目摘要说明
│
├── application/                 # 【应用服务层】
│   ├── services/
│   │   └── interactive_session_service.dart
│   └── usecases/
│       └── base_interactive_use_case.dart
│
├── domain/                      # 【领域层】— 纯数据模型，不依赖 Flutter
│   ├── models/                  # 核心领域模型（46 个文件）
│   │   ├── unified/             # 统一占卜上下文（divination_context / result / session）
│   │   ├── huang_ji_number.dart / .g.dart
│   │   ├── tiao_wen_*.dart       # 条文相关模型
│   │   ├── yuan_hui_yun_shi.dart # 元会运世
│   │   ├── *_base_number_model.dart  # 各类基数模型（八卦滚/八卦加泽/卦爻干支合/前后卦/四门法/太玄/先后天…）
│   │   ├── base_number_selection_*.dart  # 基数选择批次/记录
│   │   ├── interactive_session.dart     # 交互会话
│   │   └── middle_palace_five_strategy.dart
│   └── exceptions/             # 领域异常定义
│       ├── huang_ji_calculation_exceptions.dart
│       └── tiao_wen_calculation_exceptions.dart
│
├── infrastructure/              # 【基础设施】
│   └── di/
│       └── strategy_providers.dart  # Provider 依赖注入配置
│
├── presentation/                # 【表现层】（推荐使用的主 UI 层）
│   ├── home/
│   │   └── home_page.dart       # 首页
│   ├── pages/                   # 页面
│   │   ├── four_doors_and_gun_fa_page.dart
│   │   ├── strategy_demo_page.dart
│   │   ├── tai_xuan_interactive_page.dart
│   │   └── vertical_layout/     # 竖版布局体系
│   │       ├── base_18_page.dart
│   │       ├── vertical_layout_page.dart
│   │       ├── models/
│   │       └── widgets/         # 算法卡片 / 条文行 / 导航栏 / 竖排文本
│   ├── components/              # 通用组件（玻璃容器/渐变卡片/动画按钮/节标题）
│   ├── widgets/                 # 业务 Widgets（27 个文件）
│   │   ├── 条文相关：tiao_wen_item.dart / tiao_wen_list_view.dart / candidate_selection_widget.dart
│   │   ├── 卦象展示：gua_change_visualization.dart / gua_display_widget（在 features/kao_ke/widgets 中）
│   │   ├── 各类卡片：ba_gua_jia_ze_card / gua_zhong_card / qian_hou_gua_card / liu_yao_gan_zhi_he_card /
│   │   │             xian_houtian_jia_ze_card / xian_houtian_qu_shu_card / tai_xuan_dual_method_card /
│   │   │             yuan_tang_card / kao_ding_liu_qin_card / gua_yao_gan_zhi_he_card
│   │   ├── 元堂运程：yuan_tang_dayun_widget / yuan_tang_liunian_list / yuan_tang_liuyue_panel / yuan_tang_liuyun_section
│   │   ├── 交互组件：interactive_result_widget / interactive_session_header / interactive_step_indicator
│   │   └── 通用：loading_widget / empty_state_widget / error_widget / calculation_summary / strategy_card / strategy_header
│   ├── viewmodels/              # ViewModel（18 个文件）
│   │   ├── theme_view_model.dart
│   │   ├── *_view_model.dart     # 每个策略/功能对应一个 ViewModel
│   │   └── base_tiao_wen_list_view_model.dart
│   ├── models/                  # UI 层模型
│   │   ├── ba_gua_gun_ui_model / ba_gua_jia_ze_ui_model / si_men_fa_ui_model / yuan_tang_ui_model
│   │   └── ui_tiao_wen_list_result_model.dart
│   ├── styles/
│   │   └── strategy_demo_styles.dart
│   └── theme/                   # 主题
│       ├── app_colors.dart / app_theme.dart / app_theme_data.dart / app_typography.dart
│
├── features/                    # 【功能模块】— 独立子功能
│   ├── huang_ji/                # 黄极（V2）：公式数据 / 计算策略 / 会话管理 / UseCase / ViewModel
│   ├── kao_ding_liu_qin/        # 考定六亲：模型 / 页面 / 仓库 / 策略 / 纳甲六亲 / 起卦 / UseCase / Widget
│   ├── kao_ke/                  # 考刻：起卦 / 计算策略 / 交互页面 / 会话管理 / UseCase / ViewModel / Widgets
│   ├── liuqinkaoke/             # 六亲考刻：模型 / 页面 / 仓库 / 策略 / UseCase / ViewModel
│   └── yuan_tang_gua/           # 元堂卦：纯元堂卦 / 计算器 / 元堂信息
│
├── service/                     # 【服务层】— 策略计算核心
│   ├── strategy/                # 计算策略（20+ 个）
│   │   ├── base/                # 策略基类（base_calculation_strategy / base_interactive_strategy /
│   │   │                         multi_gua_calculator_base / yuan_tang_based_strategy）
│   │   ├── 具体策略：yuan_tang / ba_gua_gun / ba_gua_jia_ze / si_men_fa / gua_zhong /
│   │   │            gua_yao_gan_zhi_he / liu_yao_gan_zhi_he / qian_hou_gua /
│   │   │            xian_houtian_jia_ze / xian_houtian_qu_shu / tai_xuan_four_zhu /
│   │   │            four_zhu_tian_gan / day_gan_zhi_gua / middle_palace_five /
│   │   │            standard_calculation / tiao_wen_list_calculation
│   │   └── tai_xuan_four_zhu_interactive_strategy.dart
│   └── unified/                 # 统一占卜编排器
│       ├── divination_orchestrator.dart
│       ├── unified_strategy_adapter.dart
│       └── adapters/            # day_gan_zhi_gua / four_zhu_tian_gan / tai_xuan_four_zhu 适配器
│
├── usecases/                    # 【用例层】— 条文列表获取（15 个 UseCase）
│   ├── base_get_tiao_wen_list_use_case.dart
│   ├── yuan_tang_tiao_wen_list_use_case.dart
│   ├── ba_gua_gun_tiao_wen_list_use_case.dart
│   ├── ba_gua_jia_ze_tiao_wen_list_use_case.dart
│   ├── si_men_fa_tiao_wen_list_use_case.dart
│   ├── gua_zhong_tiao_wen_list_use_case.dart
│   ├── gua_yao_gan_zhi_he_tiao_wen_list_use_case.dart
│   ├── liu_yao_gan_zhi_he_tiao_wen_list_use_case.dart
│   ├── qian_hou_gua_tiao_wen_list_use_case.dart
│   ├── xian_houtian_jia_ze_tiao_wen_list_use_case.dart
│   ├── xian_houtian_qu_shu_tiao_wen_list_use_case.dart
│   ├── tai_xuan_four_zhu_tiao_wen_list_use_case.dart
│   ├── tai_xuan_four_zhu_interactive_use_case.dart
│   ├── four_zhu_tian_gan_tiao_wen_list_use_case.dart
│   └── day_gan_zhi_gua_tiao_wen_list_use_case.dart
│
├── repository/                  # 【数据仓库】
│   ├── session_repository.dart
│   └── session_repository_impl.dart
│
├── providers/                   # 【Provider 配置】
│   └── datetime_provider.dart
│
├── ui/                          # 【旧 UI 层】— 待迁移到 presentation/
│   ├── pages/
│   │   └── dev_page.dart
│   └── utils/
│       └── snackbar.dart
│
├── utils/                       # 工具
│   ├── utils.dart
│   ├── tiao_wen_calculator.dart
│   └── tiao_wen_number_calculator.dart
│
├── extensions/                  # 扩展
│   └── chinese_date_info_extension.dart
│
├── constant/                    # 常量
│   ├── constants.dart
│   ├── kao_ke_constants.dart
│   └── kao_ke_constants.g.dart
│
└── dev/
    └── dev_fixtures.dart        # 开发测试数据
```

---

## 四、依赖与配置概况

### 4.1 运行时依赖

| 依赖 | 用途 |
|---|---|
| `xuan_gua_core`（本地路径） | 玄学卦象核心库 |
| `metaphysics_core`（本地路径） | 玄学通用核心库 |
| `repository_interface_tiebanshenshu`（本地路径） | 铁板神数仓库接口 |
| `provider: ^6.1.5+1` | 状态管理 |
| `json_annotation: ^4.10.0` | JSON 序列化注解 |
| `uuid: 4.5.2` | 唯一 ID 生成 |
| `collection: ^1.19.1` | 集合扩展工具 |
| `equatable: ^2.0.8` | 值相等性比较 |
| `fl_nodes: 0.4.0+1` | 节点流式处理 |
| `http: ^1.5.0` | HTTP 请求 |
| `path_provider: ^2.1.5` | 路径获取 |
| `logger: ^2.6.2` | 日志 |
| `tuple: ^2.0.2` | 元组支持 |
| `cupertino_icons: ^1.0.8` | iOS 风格图标 |
| `flutter_localizations` | 国际化 |

### 4.2 开发依赖

| 依赖 | 用途 |
|---|---|
| `build_runner: ^2.10.5` | 代码生成运行器 |
| `json_serializable: ^6.12.0` | JSON 序列化代码生成 |
| `drift_dev: ^2.30.1` | 数据库代码生成 |
| `flutter_lints: ^6.0.0` | Lint 规则 |
| `persistence_assets`（本地路径） | 持久化资源 |

### 4.3 依赖覆写

- `persistence_core` → 本地路径 `../xuan-storage/core`

### 4.4 代码生成配置

`build.yaml` 配置了 `json_serializable`，关闭 `checked` 模式，开启 `create_to_json`/`create_factory`，`.g.dart` 文件为自动生成产物。

---

## 五、架构特点总结

1. **领域驱动**：`domain/models` 下有 40+ 个领域模型，是项目的核心资产，定义了铁板神数占卜的各种基数模型和条文体系。

2. **策略模式**：`service/strategy/` 下有 20+ 种计算策略（元堂/八卦滚/八卦加泽/四门法/卦中/卦爻干支合/六爻干支合/前后卦/先后天加泽/先后天取数/太玄四柱/天干/日干支卦/中宫五…），每种策略都实现了基类接口。

3. **占卜编排器**：`service/unified/divination_orchestrator.dart` 统一调度多种策略，通过适配器模式对接。

4. **功能模块独立**：5 个 features（黄极/考定六亲/考刻/六亲考刻/元堂卦）各自封装完整的 model-page-repository-strategy-usecase-viewmodel 栈。

5. **已知技术债务**：`lib/ui/` 和 `lib/presentation/` 职责重叠待合并；`lib/usecases/` 和 `lib/application/usecases/` 同样存在冗余。迁移计划在 `docs/Plans.md` 中。

6. **SPEC-Driven**：项目采用严格的 SPEC Coding 工作流（A1-A4 → B1-B3），非平凡改动必须先写 SPEC 文档并经批准。

---

## 六、文件统计

| 统计项 | 数量 |
|---|---|
| `lib/` 下 `.dart` 文件总数 | ~235 |
| 其中自动生成的 `.g.dart` 文件 | ~30 |
| `domain/models/` 文件数 | 46 |
| `presentation/widgets/` 文件数 | 27 |
| `service/strategy/` 计算策略数 | 20+ |
| `usecases/` 用例数 | 15 |
| 功能模块 (`features/`) | 5 |

---

## 七、架构分层总览

```
┌──────────────────────────────────────────────┐
│                  main.dart                    │
│          MultiProvider → MaterialApp          │
├──────────────┬───────────────────────────────┤
│ presentation │            ui (旧)             │
│  (viewmodels │    pages / utils / snackbar    │
│   widgets /  │                                │
│   pages /    │                                │
│   models)    │                                │
├──────────────┴───────────────────────────────┤
│                features/                      │
│  huang_ji / kao_ding_liu_qin / kao_ke /      │
│  liuqinkaoke / yuan_tang_gua                  │
├──────────────────────────────────────────────┤
│        usecases/ (条文列表获取)                │
│  application/services & application/usecases │
├──────────────────────────────────────────────┤
│        service/                               │
│  strategy/(20+策略) + unified/ (编排器)        │
├──────────────────────────────────────────────┤
│              domain/                          │
│        models/ + exceptions/                  │
├──────────────────────────────────────────────┤
│  infrastructure/di/  │  repository/           │
├──────────────────────────────────────────────┤
│  utils/  │  extensions/  │  constant/  │ dev/ │
└──────────────────────────────────────────────┘
```
