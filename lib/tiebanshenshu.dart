// -- Module Manifest --
export 'src/module/tiebanshenshu_module_manifest.dart';

// -- Infrastructure: DI --
export 'infrastructure/di/strategy_providers.dart';

// -- Navigator --
export 'navigator.dart';

// -- Presentation: Home Page --
export 'presentation/home/home_page.dart';

// -- Presentation: 排盘输入页 --
// 导出以显式声明它是模块对外可用的表面：壳内 E2E 需要
// `ChartInputPage` / `ChartInputPageState` 读取排盘执行证据。
export 'presentation/pages/chart_input_page.dart';
