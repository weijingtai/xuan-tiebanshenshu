/// 邵子条文 Repository 实现
///
/// 从 Flutter assets 加载邵子数条文数据，实现 TiaoWenRepository 接口。
library;

import 'package:flutter/services.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

/// 地支 → assets 路径映射
const Map<DiZhi, String> _diZhiToAssetPath = {
  DiZhi.ZI:   'assets/shaozishu/子.txt',
  DiZhi.CHOU: 'assets/shaozishu/丑.txt',
  DiZhi.YIN:  'assets/shaozishu/寅.txt',
  DiZhi.MAO:  'assets/shaozishu/卯.txt',
  DiZhi.CHEN: 'assets/shaozishu/辰.txt',
  DiZhi.SI:   'assets/shaozishu/巳.txt',
  DiZhi.WU:   'assets/shaozishu/午.txt',
  DiZhi.WEI:  'assets/shaozishu/未.txt',
  DiZhi.SHEN: 'assets/shaozishu/申.txt',
  DiZhi.YOU:  'assets/shaozishu/酉.txt',
  DiZhi.XU:   'assets/shaozishu/戌.txt',
  DiZhi.HAI:  'assets/shaozishu/亥.txt',
};

/// 邵子条文 Repository
///
/// 实现 [TiaoWenRepository] 接口，从 Flutter assets 加载条文数据。
class ShaoziTiaoWenRepository implements TiaoWenRepository {
  /// 内存缓存：条文编号 → 条文模型
  final Map<int, TiaoWenDataModel> _cache = {};

  /// 是否已初始化
  bool _initialized = false;

  /// 从 assets 加载条文数据
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    for (final entry in _diZhiToAssetPath.entries) {
      await _loadAsset(entry.key, entry.value);
    }

    _initialized = true;
  }

  /// 从 asset 加载单个地支的条文文件
  Future<void> _loadAsset(DiZhi diZhi, String assetPath) async {
    final content = await rootBundle.loadString(assetPath);
    final lines = content.split('\n');
    for (final line in lines) {
      final tiaoWen = _parseLine(line.trim(), diZhi);
      if (tiaoWen != null) {
        _cache[tiaoWen.id] = tiaoWen;
      }
    }
  }

  /// 解析单行条文文本
  TiaoWenDataModel? _parseLine(String line, DiZhi diZhi) {
    if (line.isEmpty || line.startsWith('#') || line.startsWith('//')) {
      return null;
    }

    final splitIndex = line.indexOf('\t');
    if (splitIndex == -1) {
      final spaceIndex = line.indexOf(' ');
      if (spaceIndex == -1) return null;
      final numberStr = line.substring(0, spaceIndex);
      final content = line.substring(spaceIndex + 1);
      final number = int.tryParse(numberStr);
      if (number == null) return null;
      return TiaoWenDataModel(
        id: number,
        setName: diZhi,
        content1: content,
        ageSet1: [],
      );
    }

    final numberStr = line.substring(0, splitIndex);
    final content = line.substring(splitIndex + 1);
    final number = int.tryParse(numberStr);
    if (number == null) return null;
    return TiaoWenDataModel(
      id: number,
      setName: diZhi,
      content1: content,
      ageSet1: [],
    );
  }

  // ============================================================
  // TiaoWenRepository 接口实现
  // ============================================================

  @override
  Future<TiaoWenDataModel?> getById(int id) async {
    await _ensureInitialized();
    return _cache[id];
  }

  @override
  Future<List<TiaoWenDataModel>> getByIdsWithPageRange({
    required List<int> ids,
    required List<int> pageRange,
    int steps = 1,
  }) async {
    await _ensureInitialized();
    return ids
        .skip(pageRange[0])
        .take(pageRange[1] - pageRange[0])
        .where((id) => _cache.containsKey(id))
        .map((id) => _cache[id]!)
        .toList();
  }

  @override
  Future<List<TiaoWenDataModel>> listAll() async {
    await _ensureInitialized();
    return _cache.values.toList()..sort((a, b) => a.id.compareTo(b.id));
  }

  @override
  Future<List<TiaoWenDataModel>> search({
    String? setName,
    String? contentKeyword,
  }) async {
    await _ensureInitialized();
    var results = _cache.values.toList();

    if (setName != null) {
      final targetZhi = DiZhi.values.firstWhere(
        (d) => d.name == setName,
        orElse: () => DiZhi.ZI,
      );
      results = results.where((e) => e.setName == targetZhi).toList();
    }

    if (contentKeyword != null) {
      results = results
          .where((e) => e.content1.contains(contentKeyword))
          .toList();
    }

    return results;
  }

  @override
  Future<int> getCount() async {
    await _ensureInitialized();
    return _cache.length;
  }

  @override
  Future<List<TiaoWenDataModel>> getAroundById({
    required int centerId,
    required int beforeCount,
    required int afterCount,
    bool includeCenterItem = true,
  }) async {
    await _ensureInitialized();
    final sortedIds = _cache.keys.toList()..sort();
    final centerIndex = sortedIds.indexOf(centerId);
    if (centerIndex == -1) return [];

    final start = (centerIndex - beforeCount).clamp(0, sortedIds.length - 1);
    final end = (centerIndex + afterCount).clamp(0, sortedIds.length - 1);

    return sortedIds
        .sublist(start, end + 1)
        .where((id) => includeCenterItem || id != centerId)
        .map((id) => _cache[id]!)
        .toList();
  }

  @override
  Future<List<TiaoWenDataModel>> getByIntervalAroundId({
    required int centerId,
    required int interval,
    required int minCount,
    int? maxRange,
    bool includeCenterItem = true,
  }) async {
    await _ensureInitialized();
    return [];
  }

  @override
  Future<List<TiaoWenDataModel>> getByIdRange({
    required int startId,
    required int endId,
  }) async {
    await _ensureInitialized();
    return _cache.values
        .where((e) => e.id >= startId && e.id <= endId)
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  @override
  Future<List<TiaoWenDataModel>> getByIdList({
    required List<int> queryList,
    bool preserveOrder = false,
    bool skipNotFound = true,
  }) async {
    await _ensureInitialized();
    if (preserveOrder) {
      return queryList
          .where((id) => skipNotFound ? _cache.containsKey(id) : true)
          .map((id) => _cache[id])
          .whereType<TiaoWenDataModel>()
          .toList();
    }
    return queryList
        .where((id) => _cache.containsKey(id))
        .map((id) => _cache[id]!)
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  @override
  Future<Map<int, String>> getTiaoWenContentByNumbers(List<int> numbers) async {
    await _ensureInitialized();
    final result = <int, String>{};
    for (final num in numbers) {
      final tiaoWen = _cache[num];
      if (tiaoWen != null) {
        result[num] = tiaoWen.content1;
      }
    }
    return result;
  }

  @override
  Future<String?> getTiaoWenContentByNumber(int number) async {
    await _ensureInitialized();
    return _cache[number]?.content1;
  }
}
