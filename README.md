# xuan-tiebanshenshu

铁板神数 (TieBan ShenShu / Iron Plate Divine Numbers) divination module — multi-strategy base number derivation engine with interactive use cases, tiao wen (条文) text repository, and comprehensive calculation pipelines.

## Quick Start (AI Agents / Developers)

```bash
git clone http://192.168.0.165:3000/xuan/xuan-tiebanshenshu.git
cd xuan-tiebanshenshu
flutter pub get
dart analyze lib/            # 593 issues (0 errors, 63 warnings, 530 info)
# Tests require git-dependency resolution; see Dependencies section below
```

### Consume This Package

```dart
// pubspec.yaml
dependencies:
  tiebanshenshu:
    git:
      url: http://192.168.0.165:3000/xuan/xuan-tiebanshenshu.git
```

```dart
import 'package:tiebanshenshu/usecases/yuan_tang_tiao_wen_list_use_case.dart';
import 'package:tiebanshenshu/service/strategy/yuan_tang_strategy.dart';
```

## Architecture

```
lib/
├── domain/
│   ├── models/                          # 15+ base number models
│   │   ├── unified/                     # Unified model layer
│   │   ├── ba_gua_gun_base_number_model.dart
│   │   ├── ba_gua_jia_ze_base_number_model.dart
│   │   ├── gua_zhong_base_number_model.dart
│   │   ├── yuan_tang_base_number_model.dart
│   │   ├── si_men_fa_base_number_model.dart
│   │   ├── qian_hou_gua_base_number_model.dart
│   │   ├── xian_houtian_gua_base_number_model.dart
│   │   ├── xian_houtian_qu_shu_base_number_model.dart
│   │   ├── gua_yao_gan_zhi_he_base_number_model.dart
│   │   ├── liu_yao_gan_zhi_he_base_number_model.dart
│   │   ├── tiao_wen_list_result.dart     # TiaoWenListResult
│   │   └── multi_base_number_result.dart # MultiBaseNumberResult
│   └── exceptions/                      # Domain exceptions
├── service/
│   └── strategy/                        # 12 calculation strategies
│       ├── base/
│       │   ├── multi_gua_calculator_base.dart
│       │   └── yuan_tang_based_strategy.dart
│       ├── yuan_tang_strategy.dart       # 元堂 strategy
│       ├── ba_gua_gun_strategy.dart      # 八卦滚 strategy
│       ├── ba_gua_jia_ze_strategy.dart   # 八卦加则 strategy
│       ├── gua_zhong_strategy.dart       # 卦中 strategy
│       ├── si_men_fa_strategy.dart       # 四门法 strategy
│       ├── qian_hou_gua_strategy.dart    # 前后卦 strategy
│       ├── gua_yao_gan_zhi_he_strategy.dart  # 卦爻干支合 strategy
│       ├── liu_yao_gan_zhi_he_strategy.dart  # 六爻干支合 strategy
│       ├── xian_houtian_qu_shu_strategy.dart # 先后天取数 strategy
│       ├── day_gan_zhi_gua_strategy.dart     # 日干支卦 strategy
│       └── tai_xuan_four_zhu_strategy.dart   # 太玄四柱 strategy
├── usecases/                            # 15+ tiao wen list use cases
│   ├── base_get_tiao_wen_list_use_case.dart
│   ├── yuan_tang_tiao_wen_list_use_case.dart
│   ├── ba_gua_gun_tiao_wen_list_use_case.dart
│   ├── ba_gua_jia_ze_tiao_wen_list_use_case.dart
│   ├── gua_zhong_tiao_wen_list_use_case.dart
│   ├── si_men_fa_tiao_wen_list_use_case.dart
│   ├── qian_hou_gua_tiao_wen_list_use_case.dart
│   ├── gua_yao_gan_zhi_he_tiao_wen_list_use_case.dart
│   ├── liu_yao_gan_zhi_he_tiao_wen_list_use_case.dart
│   ├── xian_houtian_qu_shu_tiao_wen_list_use_case.dart
│   ├── xian_houtian_jia_ze_tiao_wen_list_use_case.dart
│   ├── day_gan_zhi_gua_tiao_wen_list_use_case.dart
│   ├── four_zhu_tian_gan_tiao_wen_list_use_case.dart
│   └── tai_xuan_four_zhu_tiao_wen_list_use_case.dart
├── features/
│   ├── huang_ji/                        # 皇极 feature (Huang Ji V2)
│   ├── kao_ding_liu_qin/                # 考定六亲 feature
│   │   ├── models/liu_du_table.dart
│   │   ├── services/                    # QiGuaHelper, NaJiaLiuQinHelper, KaoDingLiuQinStrategy
│   │   ├── usecases/kao_ding_liu_qin_use_case.dart
│   │   ├── pages/
│   │   └── widgets/
│   ├── kao_ke/                          # 考课 feature
│   ├── liuqinkaoke/                     # 六亲考课 feature
│   │   ├── strategy/liuqinkaoke_calculation_strategy.dart
│   │   └── usecase/liuqinkaoke_session_manager.dart
│   ├── six_yao_gua/                     # Six Yao hexagram types
│   │   ├── pure_six_yao_gua.dart        # PureSixYaoGua
│   │   ├── six_yao_calculator.dart      # SixYaoCalculator
│   │   └── enum_6_shou.dart, enum_8_gong_gua.dart
│   └── yuan_tang_gua/                   # 元堂卦
│       ├── pure_yuan_tang_gua.dart
│       └── yuan_tang_calculator.dart
├── application/
│   ├── services/
│   └── usecases/base_interactive_use_case.dart  # Base interactive use case
├── infrastructure/di/strategy_providers.dart     # DI wiring
├── repository/
│   ├── repository_factory.dart
│   ├── tiao_wen_repository.dart                  # TiaoWenRepository port
│   ├── tiao_wen_repository_impl.dart             # Implementation
│   └── datamodels/tiao_wen_datamodel.dart        # Persistence model
├── presentation/
│   ├── models/                                   # UI models (YuanTang, BaGuaGun, BaGuaJiaZe, SiMenFa)
│   └── viewmodels/kao_ding_liu_qin_view_model.dart
├── constant/                                     # Constants + kao ke constants
├── utils/
│   ├── tiao_wen_calculator.dart
│   ├── tiao_wen_number_calculator.dart
│   └── utils.dart
└── extensions/
test/ (~20 test files covering strategies, use cases, models, repository)
```

**Dependency direction:** `Presentation → UseCases → Strategy Services → Domain Models`  |  `Presentation → Features → Domain`

## Strategy Pattern Architecture

Each divination method follows the same pattern:

```
Calculator Base (multi_gua_calculator_base / yuan_tang_based_strategy)
    ↓
Concrete Strategy (e.g., BaGuaGunStrategy)
    ↓
Use Case (e.g., BaGuaGunTiaoWenListUseCase)
    ↓
TiaoWenRepository → tiao wen text retrieval
```

## Key Components

| Component | Layer | Responsibility |
|---|---|---|
| `TiaoWenRepository` | Repository | Port interface for tiao wen text persistence |
| `TiaoWenRepositoryImpl` | Repository | Implementation with local data |
| `MultiGuaCalculatorBase` | Strategy | Base class for multi-gua calculations |
| `YuanTangBasedStrategy` | Strategy | Base class for 元堂-derived strategies |
| `YuanTangStrategy` | Strategy | 元堂 base number derivation |
| `BaGuaGunStrategy` | Strategy | 八卦滚 number derivation |
| `BaGuaJiaZeStrategy` | Strategy | 八卦加则 derivation |
| `GuaZhongStrategy` | Strategy | 卦中 number derivation |
| `SiMenFaStrategy` | Strategy | 四门法 derivation |
| `QianHouGuaStrategy` | Strategy | 前后卦 derivation |
| `GuaYaoGanZhiHeStrategy` | Strategy | 卦爻干支合 derivation |
| `LiuYaoGanZhiHeStrategy` | Strategy | 六爻干支合 derivation |
| `XianHoutianQuShuStrategy` | Strategy | 先后天取数 derivation |
| `DayGanZhiGuaStrategy` | Strategy | 日干支卦 derivation |
| `TaiXuanFourZhuStrategy` | Strategy | 太玄四柱 derivation |
| `BaseInteractiveUseCase` | Application | Base for interactive calculation flows |
| `HuangJiV2UseCase` | Feature | 皇极 interactive use case |
| `KaoDingLiuQinUseCase` | Feature | 考定六亲 use case |
| `LiuQinKaoKeSessionManager` | Feature | 六亲考课 session management |
| `SixYaoCalculator` | Feature | Six Yao hexagram calculator |
| `YuanTangCalculator` | Feature | 元堂卦 calculator |
| `TiaoWenCalculator` | Utils | Tiao wen number calculation |
| `StrategyProviders` | DI | Dependency injection for strategy selection |

## Feature Modules

| Feature | Description | Key Files |
|---|---|---|
| **皇极 (Huang Ji)** | Huang Ji interactive divination V2 | `lib/features/huang_ji/` |
| **考定六亲 (Kao Ding Liu Qin)** | Six relatives determination with gua installation | `lib/features/kao_ding_liu_qin/` |
| **考课 (Kao Ke)** | Interactive kao ke calculation | `lib/features/kao_ke/` |
| **六亲考课 (LiuQin KaoKe)** | Six relatives + kao ke combined | `lib/features/liuqinkaoke/` |
| **六爻卦 (Six Yao Gua)** | Six Yao hexagram types and calculator | `lib/features/six_yao_gua/` |
| **元堂卦 (Yuan Tang Gua)** | Yuan Tang hexagram types | `lib/features/yuan_tang_gua/` |

## External Dependencies

| Package | Purpose |
|---|---|
| `xuan_gua_core` (path: `../xuan-gua-core`) | Hexagram types, enums, calculator |
| `metaphysics_core` (via xuan_gua_core) | FiveXing, TianGan, DiZhi foundations |

## Design Rules

1. **Strategy pattern for calculation diversity.** Each divination method is a separate strategy with a shared base class.
2. **Base number → tiao wen pipeline.** Strategy produces base numbers → use case queries repository → tiao wen text returned.
3. **Interactive use cases.** `BaseInteractiveUseCase` supports multi-step user interaction flows (huang ji, kao ke).
4. **Feature modules are self-contained.** Each feature under `lib/features/` has its own models, services, use cases, pages, and widgets.

## Code Review Findings

### Strengths
- ✅ Comprehensive strategy pattern — 12 calculation methods with clean inheritance
- ✅ Rich domain model layer — 15+ specialized base number models
- ✅ Feature modularity — each feature is self-contained
- ✅ 15+ use cases map 1:1 to strategies
- ✅ Large test suite across strategies, use cases, models

### Issues
- ⚠️ **No non-Flutter lib/ analysis** — requires Flutter SDK; `dart analyze lib/` shows 593 findings (0 errors)
- ⚠️ **63 warnings** — mostly override misannotations and unused imports, pre-existing
- ⚠️ **530 info-level lints** — collection literals, deprecated member usage, library prefixes (low priority)
- ⚠️ **Test dependency resolution failure** — git-dependency chain through xuan_gua_core → metaphysics_core needs local path overrides
- ⚠️ Missing README.md (now added)

### Recommendation
Add `dependency_overrides` to pubspec.yaml for local development to resolve `metaphysics_core` path for offline testing.

## Developer Tooling

| Tool | Usage |
|---|---|
| CodeGraph | `codegraph query "YuanTangStrategy"` — symbol search |
| Understand Anything | `/understand-chat "how does the ba gua gun strategy work?"` |

## Code Intelligence

- **CodeGraph** (`codegraph.db`): ~17MB index for 218 dart files
- **Understand Anything** (`knowledge-graph.json`): 589 nodes, 723 edges, 17 layers
