/// 条文 Repository 实现
///
/// 实现 [TiaoWenRepository] 接口，组合 LocalDataSource（主） + RemoteDataSource（辅）。
///
/// 架构：
///   TiaoWenRepository（接口）
///       ↓ implements
///   TiaoWenRepositoryImpl（组合器）
///       ↓ 依赖
///   ├── TiaoWenLocalDataSource（本地读取）
///   └── TiaoWenRemoteDataSource（远程同步，暂 Stub）
library;

import 'dart:async';

import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

import 'data_source/tiao_wen_remote_data_source.dart';

/// 条文 Repository 实现
///
/// 组合本地和远程数据源，所有查询优先走本地，远程不可用时自动降级。
/// 使用 Completer 确保并发安全，多个同时调用只触发一次初始化。
class TiaoWenRepositoryImpl implements TiaoWenRepository {
  final TiaoWenLocalDataSource _local;
  final TiaoWenRemoteDataSource _remote;

  /// 数据缓存（委托给 local data source 加载后缓存于此）
  List<TiaoWenDataModel>? _cachedList;
  Map<int, TiaoWenDataModel>? _cachedMap;

  /// 并发安全控制
  Completer<void>? _loadingCompleter;

  TiaoWenRepositoryImpl({
    required TiaoWenLocalDataSource localDataSource,
    required TiaoWenRemoteDataSource remoteDataSource,
  })  : _local = localDataSource,
        _remote = remoteDataSource;

  /// 确保缓存就绪（懒加载 + Completer 并发保护）
  Future<void> _ensureLoaded() async {
    // 已就绪
    if (_cachedList != null && _cachedMap != null) return;

    // 正在加载中，等待完成
    if (_loadingCompleter != null) {
      await _loadingCompleter!.future;
      return;
    }

    _loadingCompleter = Completer<void>();

    try {
      final all = await _local.loadAll();
      final map = <int, TiaoWenDataModel>{};
      for (final item in all) {
        map[item.id] = item;
      }
      _cachedList = all;
      _cachedMap = map;
      _loadingCompleter!.complete();
    } catch (e) {
      _loadingCompleter!.completeError(e);
      rethrow;
    } finally {
      _loadingCompleter = null;
    }
  }

  /// 尝试从远程同步（非阻塞，远程不可用时静默跳过）
  Future<void> _trySyncFromRemote() async {
    try {
      final available = await _remote.isAvailable();
      if (available) {
        await _remote.syncFromRemote();
        // 同步完成后刷新本地缓存
        _cachedList = null;
        _cachedMap = null;
        await _ensureLoaded();
      }
    } catch (_) {
      // 远程同步失败静默降级
    }
  }

  // ============================================================
  // TiaoWenRepository 接口实现（11 个方法）
  // ============================================================

  @override
  Future<TiaoWenDataModel?> getById(int id) async {
    await _ensureLoaded();
    return _cachedMap![id];
  }

  @override
  Future<List<TiaoWenDataModel>> getByIdsWithPageRange({
    required List<int> ids,
    required List<int> pageRange,
    int steps = 1,
  }) async {
    await _ensureLoaded();

    if (pageRange.length != 2) {
      throw ArgumentError(
        'pageRange must contain exactly 2 elements [startIndex, endIndex]',
      );
    }

    final startIndex = pageRange[0];
    final endIndex = pageRange[1];

    if (startIndex < 0 || endIndex < startIndex) {
      throw ArgumentError(
        'startIndex must be >= 0 and endIndex must be >= startIndex',
      );
    }
    if (steps <= 0) {
      throw ArgumentError('steps must be greater than 0');
    }

    final filteredIds = <int>[];
    for (int i = startIndex; i <= endIndex && i < ids.length; i += steps) {
      filteredIds.add(ids[i]);
    }

    final result = <TiaoWenDataModel>[];
    for (final id in filteredIds) {
      final tiaoWen = _cachedMap![id];
      if (tiaoWen != null) {
        result.add(tiaoWen);
      }
    }

    return result;
  }

  @override
  Future<List<TiaoWenDataModel>> listAll() async {
    await _ensureLoaded();
    return List.from(_cachedList!);
  }

  @override
  Future<List<TiaoWenDataModel>> search({
    String? setName,
    String? contentKeyword,
  }) async {
    await _ensureLoaded();

    Iterable<TiaoWenDataModel> results = _cachedList!;

    if (setName != null && setName.isNotEmpty) {
      DiZhi? targetZhi;
      try {
        targetZhi = DiZhi.values.firstWhere(
          (d) => d.name == setName || d.toString().contains(setName),
        );
      } catch (_) {
        return [];
      }
      results = results.where((e) => e.setName == targetZhi);
    }

    if (contentKeyword != null && contentKeyword.isNotEmpty) {
      results = results.where((e) {
        final c1 = e.content1.contains(contentKeyword);
        final c2 = e.content2?.contains(contentKeyword) ?? false;
        return c1 || c2;
      });
    }

    return results.toList();
  }

  @override
  Future<int> getCount() async {
    await _ensureLoaded();
    return _cachedList!.length;
  }

  @override
  Future<List<TiaoWenDataModel>> getAroundById({
    required int centerId,
    required int beforeCount,
    required int afterCount,
    bool includeCenterItem = true,
  }) async {
    await _ensureLoaded();

    if (beforeCount < 0 || afterCount < 0) {
      throw ArgumentError('beforeCount and afterCount must be >= 0');
    }

    final startId = centerId - beforeCount;
    final endId = centerId + afterCount;
    final result = <TiaoWenDataModel>[];

    for (int id = startId; id <= endId; id++) {
      if (!includeCenterItem && id == centerId) continue;
      final tiaoWen = _cachedMap![id];
      if (tiaoWen != null) {
        result.add(tiaoWen);
      }
    }

    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }

  @override
  Future<List<TiaoWenDataModel>> getByIntervalAroundId({
    required int centerId,
    required int interval,
    required int minCount,
    int? maxRange,
    bool includeCenterItem = true,
  }) async {
    await _ensureLoaded();

    if (interval <= 0) throw ArgumentError('interval must be > 0');
    if (minCount <= 0) throw ArgumentError('minCount must be > 0');

    final result = <TiaoWenDataModel>[];
    final addedIds = <int>{};

    if (includeCenterItem) {
      final center = _cachedMap![centerId];
      if (center != null) {
        result.add(center);
        addedIds.add(centerId);
      }
    }

    final searchRange = maxRange ?? 1000;
    int forwardStep = 1;
    int backwardStep = 1;

    while (result.length < minCount &&
        (forwardStep * interval <= searchRange ||
            backwardStep * interval <= searchRange)) {
      // 向后搜索
      if (forwardStep * interval <= searchRange) {
        final forwardId = centerId + (forwardStep * interval);
        if (!addedIds.contains(forwardId)) {
          final tiaoWen = _cachedMap![forwardId];
          if (tiaoWen != null) {
            result.add(tiaoWen);
            addedIds.add(forwardId);
          }
        }
        forwardStep++;
      }

      // 向前搜索
      if (result.length < minCount && backwardStep * interval <= searchRange) {
        final backwardId = centerId - (backwardStep * interval);
        if (!addedIds.contains(backwardId)) {
          final tiaoWen = _cachedMap![backwardId];
          if (tiaoWen != null) {
            result.add(tiaoWen);
            addedIds.add(backwardId);
          }
        }
        backwardStep++;
      }
    }

    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }

  @override
  Future<List<TiaoWenDataModel>> getByIdRange({
    required int startId,
    required int endId,
  }) async {
    await _ensureLoaded();

    if (startId > endId) {
      throw ArgumentError('startId must be <= endId');
    }

    final result = <TiaoWenDataModel>[];
    for (int id = startId; id <= endId; id++) {
      final tiaoWen = _cachedMap![id];
      if (tiaoWen != null) {
        result.add(tiaoWen);
      }
    }

    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }

  @override
  Future<List<TiaoWenDataModel>> getByIdList({
    required List<int> queryList,
    bool preserveOrder = false,
    bool skipNotFound = true,
  }) async {
    await _ensureLoaded();

    if (queryList.isEmpty) return [];

    final result = <TiaoWenDataModel>[];
    final notFoundIds = <int>[];

    if (preserveOrder) {
      for (final id in queryList) {
        final tiaoWen = _cachedMap![id];
        if (tiaoWen != null) {
          result.add(tiaoWen);
        } else {
          notFoundIds.add(id);
        }
      }
    } else {
      final uniqueIds = queryList.toSet().toList()..sort();
      for (final id in uniqueIds) {
        final tiaoWen = _cachedMap![id];
        if (tiaoWen != null) {
          result.add(tiaoWen);
        } else {
          notFoundIds.add(id);
        }
      }
    }

    if (!skipNotFound && notFoundIds.isNotEmpty) {
      throw ArgumentError(
        'The following IDs were not found: ${notFoundIds.join(', ')}',
      );
    }

    return result;
  }

  @override
  Future<Map<int, String>> getTiaoWenContentByNumbers(List<int> numbers) async {
    await _ensureLoaded();

    if (numbers.isEmpty) return {};

    final result = <int, String>{};
    for (final number in numbers) {
      final tiaoWen = _cachedMap![number];
      if (tiaoWen != null) {
        result[number] = tiaoWen.content1;
      }
    }

    return result;
  }

  @override
  Future<String?> getTiaoWenContentByNumber(int number) async {
    await _ensureLoaded();
    return _cachedMap![number]?.content1;
  }

  // ============================================================
  // 扩展方法（非接口方法，复用 AssetsTiaoWenRepository 的便利能力）
  // ============================================================

  /// 根据年龄集合获取条文
  Future<List<TiaoWenDataModel>> getByAgeSet({
    required List<int> ageSet,
    bool useSecondSet = false,
  }) async {
    await _ensureLoaded();
    return _cachedList!.where((tiaoWen) {
      final targetAgeSet = useSecondSet ? tiaoWen.ageSet2 : tiaoWen.ageSet1;
      if (targetAgeSet == null) return false;
      return ageSet.any((age) => targetAgeSet.contains(age));
    }).toList();
  }

  /// 根据地支获取条文
  Future<List<TiaoWenDataModel>> getByDiZhi(DiZhi diZhi) async {
    await _ensureLoaded();
    return _cachedList!
        .where((tiaoWen) => tiaoWen.setName == diZhi)
        .toList();
  }

  /// 清除内存缓存（测试用）
  void clearCache() {
    _cachedList = null;
    _cachedMap = null;
  }
}
