# Module Onboarding Playbook

> 本文档记录将一个新术数模块挂入 xuan-shell 的标准 7 步流程。
> 以 tiebanshenshu 为探路参考，后续 5 个模块照此走。

---

## 前置检查清单

准备接入一个新模块前，确认以下事项：

- 模块仓已存在，`pub get / analyze / test` 全绿
- xuan-storage 中已有对应的 `{module}_module_registry.dart` （含 `codec()` + `record_backed_*_repository`）
- 模块的 `repository-interface-{module}` 包已在 Gitea 上可访问
- 模块有一个可直接导航到的首页 Widget

---

## Step 1 — 模块仓：创建 barrel file

在模块根目录 `lib/` 下创建 `<module_name>.dart`，导出壳需要引用的所有符号：

```dart
// lib/tiebanshenshu.dart

// -- Module Manifest --
export 'src/module/tiebanshenshu_module_manifest.dart';

// -- Infrastructure: DI --
export 'infrastructure/di/strategy_providers.dart';

// -- Navigator --
export 'navigator.dart';

// -- Presentation: Home Page --
export 'presentation/home/home_page.dart';
```

**注意：**
- 壳从 barrel file import 模块 manifest，不直接从 `lib/src/` 引用
- 导出清单：manifest → DI → navigator（或路由）→ 首页 Widget
- 不要导出 `main.dart`（它包含自己的 `runApp`）

---

## Step 2 — 模块仓：创建 XuanModuleManifest 实现

在模块 `lib/src/module/` 下创建 `<module>_module_manifest.dart`：

```dart
// lib/src/module/tiebanshenshu_module_manifest.dart

import 'package:provider/single_child_widget.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

import '../../infrastructure/di/strategy_providers.dart';

final class TiebanshenshuModuleManifest {
  const TiebanshenshuModuleManifest._();

  static const String id = 'tiebanshenshu';
  static const String displayNameKey = 'module_tiebanshenshu_name';
  static const String version = '0.1.0';
  static const String minShellVersion = '0.1.0-a3';

  static List<SingleChildWidget> createProviders(TiebanRecordRepository repo) {
    return StrategyProviders.getProvidersWithRealRepo(repo);
  }
}
```

**关键约束：**
- `id` 必须与 `ModuleStoragePorts` 中的字段名一致（`tiebanshenshu`）
- `displayNameKey` 必须与 shell 的 `app_zh.arb` 中的 key 对应
- `createProviders` 接收**真实存储端口**，不接受 Dummy/Fake 实现
- 参数类型使用存储接口（`TiebanRecordRepository`），不是具体实现

---

## Step 3 — 模块仓：清理重复 DI 注入

检查模块的路由/navigator 文件中是否重复注入了 Provider。
如果在 Navigator 的某些路由中调用了 `MultiProvider(providers: StrategyProviders.providers, ...)`，
**必须移除这些内层包装**——DI 现在由壳统一注入。

```diff
-      return MultiProvider(
-        providers: StrategyProviders.providers,
-        child: KaoKeInteractivePage(eightChars: eightChars),
-      );
+      return KaoKeInteractivePage(eightChars: eightChars);
```

---

## Step 4 — 模块仓：提交并推送

```bash
git checkout -b feat/module-mounting-{module}
git add ... && git commit
git push gitea feat/module-mounting-{module}
```

**记住：铁律禁止在 main 上直接修改代码。**

---

## Step 5 — 壳仓：添加依赖

在 `xuan-shell/pubspec.yaml` 中添加两行依赖：

```yaml
dependencies:
  # ... 其他依赖 ...
  {module}:
    git:
      url: http://192.168.0.165:3000/xuan/xuan-{module}.git
  repository_interface_{module}:
    git:
      url: http://192.168.0.165:3000/xuan/repository-interface-{module}.git

dependency_overrides:
  {module}:
    path: ../xuan-{module}
  # ... 其他 override ...
```

然后 `flutter pub get`。

---

## Step 6 — 壳仓：创建模块入口

在 `xuan-shell/lib/modules/` 下创建 `<module>_module_entry.dart`：

```dart
// lib/modules/tieban_module_entry.dart

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiebanshenshu/tiebanshenshu.dart' as tb;

import 'module_manifest.dart';

final class TiebanshenshuManifest implements XuanModuleManifest {
  const TiebanshenshuManifest();

  @override
  String get id => tb.TiebanshenshuModuleManifest.id;

  @override
  String get displayNameKey => tb.TiebanshenshuModuleManifest.displayNameKey;

  // ... version, minShellVersion, capabilities ...

  @override
  List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [];

  @override
  List<String> get supportedLocaleTags => [];

  @override
  List<SingleChildWidget> createProviders(ModuleHostContext host) {
    final repo = host.storage.tiebanshenshu; // ← 字段名与 ModuleStoragePorts 一致
    if (repo == null) return [];
    return tb.TiebanshenshuModuleManifest.createProviders(repo);
  }

  @override
  List<GoRoute> createRoutes(ModuleHostContext host) {
    return [
      GoRoute(
        path: '/modules/tiebanshenshu',
        name: 'module.tiebanshenshu.home',
        builder: (context, state) => Navigator(
          onGenerateRoute: tb.NavigatorGenerator.generateRoute,
          initialRoute: '/tiebanshenshu/home',
        ),
      ),
    ];
  }
}
```

**路由模式选择：**
- **自定义 Navigator**：模块有自己复杂的 `NavigatorGenerator`（如 tieban 的 push/back 导航）→ 使用 `Navigator(onGenerateRoute: ...)` 包装
- **简单 GoRoute**：模块只有一个首页（如 liuyao）→ 直接 builder 返回首页 Widget

**capabilities 设置指南：**
- `hasRecordHistory`：模块是否使用 `host.records` 做记录持久化
- `requiresAccountScope`：模块是否需要登录/scope 切换
- `requiresTimeLocation`：模块是否需要时间和位置上下文
- `consumesTheme`：模块是否消费壳的主题（通常都是 true）

---

## Step 7 — 壳仓：注册模块、接线存储、启用入口

### 7a. 注册模块

在 `xuan-shell/lib/modules/registered_modules.dart` 中：

```dart
import 'tieban_module_entry.dart';  // ← 加 import

List<XuanModuleManifest> registeredModules() {
  return [
    const LiuyaoManifest(),
    const QiZhengSiYuManifest(),
    const ZiweiModuleManifest(),
    const TiebanshenshuManifest(),  // ← 加注册
  ];
}
```

### 7b. 接线存储端口

在 `xuan-shell/lib/modules/module_manifest.dart` 中：

```dart
// 添加 import
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

// 在 ModuleStoragePorts 中添加字段
final class ModuleStoragePorts {
  const ModuleStoragePorts({
    this.liuyao,
    this.qizhengsiyu,
    this.tiebanshenshu,         // ← 加字段
    this.recordStore,
  });

  final TiebanRecordRepository? tiebanshenshu;  // ← 加声明
}
```

### 7c. 接线存储运行时

在 `xuan-shell/lib/storage/shell_scoped_storage_runtime.dart` 中：

```dart
// 添加 import
import 'package:persistence_drift/tiebanshenshu/tiebanshenshu_module_registry.dart';

// 注册 codec 到 RecordAdapterRegistry
RecordAdapterRegistry([
  LiuYaoModuleRegistry.codec(),
  QiZhengModuleRegistry.codec(),
  TiebanshenshuModuleRegistry.codec(),  // ← 加 codec
])

// 创建 repository
final tiebanRepo = TiebanshenshuModuleRegistry.repository(store: store);

// 注入到 ports
final ports = ModuleStoragePorts(
  liuyao: liuyaoRepo,
  qizhengsiyu: qizhengDeps,
  tiebanshenshu: tiebanRepo,  // ← 加注入
);
```

### 7d. 启用首页入口

在 `xuan-shell/lib/home/shell_home_page.dart` 中：

```dart
ModuleEntry(id: 'tiebanshenshu', ..., enabled: true),  // false → true
```

---

## Step 8 — 壳仓：提交并推送

```bash
git checkout -b feat/module-mounting-{module}
git add ... && git commit
git push origin feat/module-mounting-{module}
```

---

## 验证清单

| 检查项 | 方法 |
|--------|------|
| 模块仓 pub get | `flutter pub get` |
| 模块仓 analyze | `flutter analyze`（关注 error 级，非本模块的 info 可忽略） |
| 模块仓 test | `flutter test`（必须全绿，不可比基线少） |
| 壳仓 pub get | `flutter pub get` |
| 壳仓 analyze | `dart analyze lib/modules/{module}_module_entry.dart ...`（只查新增文件） |
| 壳仓 build | `flutter build macos --debug` |
| 壳仓 test | `flutter test` |
| 运行时验证 | `flutter run` 后从首页点击模块入口，确认页面正常加载 |
| 两仓 push | `git ls-remote gitea/origin refs/heads/feat/module-mounting-{module}` 确认本地 HEAD == 远端 HEAD |

---

## 坑点与注意事项

### 1. 绝对不要用 Dummy 胶水

`ziwei_module_entry_patches.dart` 是反面教材，它用 `FakeTiebanRecordRepository()` 硬编码假仓库。
正确做法是像 liuyao 那样从 `host.storage.xxx` 拿真实仓库，null 时返回空 providers。

### 2. 模块 Navigator 中的重复 Provider 注入

很多模块的 `navigator.dart` 中会对每个路由重复注入 `MultiProvider(providers: StrategyProviders.providers, ...)`。
挂入壳后 DI 由壳在外层注入，这些内层 `MultiProvider` 必须移除，否则会创建多个重复的 Provider 实例。

### 3. pubspec 的 dependency_overrides

本地开发时必须用 `path: ../xuan-{module}` override，否则会从 Gitea git clone 旧版本。
**但 push 前只需保留 override（用于 CI/本地构建），正式合并前应移除并改用 git ref。**

### 4. ModuleStoragePorts 字段命名

`ModuleStoragePorts` 中字段名必须与 `entry` 中的 `host.storage.xxx` 一致，与 `manifest` 中的 `id` 一致。
例如 tieban 三处都是 `tiebanshenshu`（小写无横线）。

### 5. 路由路径约定

模块路由统一为 `/modules/{module_id}`，name 为 `module.{module_id}.home`。
ModuleRouteRegistry 自动将模块 ID 映射到 `/modules/{module_id}`。

### 6. l10n 预置

壳已在 `app_zh.arb` 中预置了所有 10 个模块的 `module_xxx_name` 本地化 key。
如果模块有自己的 localizationsDelegates，需要在 entry 中导出。

### 7. Tieban 特有的 NavigatorGenerator 路由

Tieban 使用自定义 `NavigatorGenerator.generateRoute` 而非 GoRoute builder。
在 entry 中用 `Navigator(onGenerateRoute: ..., initialRoute: ...)` 包装即可。
模块内部的路径（如 `/tiebanshenshu/home`、`/tiebanshenshu/strategy_demo`）由 Navigator 管理，
不需要在 entry 中为每个子页面创建独立 GoRoute。

---

## Tieban 探路实录

| 步骤 | 耗时/难度 | 说明 |
|------|-----------|------|
| 探索现有模式 | 中等 | liuyao 和 qizhengsiyu 遵循完全相同的模式，可以作为参考 |
| 创建 barrel + manifest | 快 | manifest 只需转发 `StrategyProviders.getProvidersWithRealRepo(repo)` |
| 清理 Navigator 重复 DI | 快 | 只需删除内层 MultiProvider 包装，Provider 由壳统一注入 |
| 壳 pub 依赖 | 快 | 新增两行依赖 + local override |
| 创建 entry + 注册 | 中等 | 需注意 entry 字段名与 ModuleStoragePorts 一致 |
| ModuleStoragePorts 接线 | 中等 | 需要在 3 处修改（构造函数、字段声明、storage runtime） |
| 验证 | 中等 | flutter analyze, flutter test, flutter build macos 全绿 |
| **总文件变更** | tieban 仓 3 文件 / shell 仓 7 文件 | |

### 构建验证结果

- tieban 仓：`flutter test` 697 passed
- 壳仓：`flutter build macos --debug` 成功
- 壳仓：`flutter test` 30 passed
- 两仓 git ls-remote 一致

---

## 断点——后续模块接入参考

tieban 的结构与其他待接入模块有些差异。以下是各模块可能遇到的不同情况：

| 模块 | 路由模式 | 存储端口 | 笔记 |
|------|----------|----------|------|
| tiebanshenshu | NavigatorGenerator | TiebanRecordRepository | 已完成 |
| qimendunjia | 待确认 | 待确认 | xuan-storage 已有 qimendunjia 注册 |
| taiyishenshu | 待确认 | 待确认 | xuan-storage 已有 taiyishenshu 注册 |
| bazi | 待确认 | 待确认 | |
| meihuayishu | 待确认 | 待确认 | xuan-storage 已有 meihuayishu 注册 |
| daliuren | 待确认 | 待确认 | xuan-storage 已有 daliuren 注册 |
