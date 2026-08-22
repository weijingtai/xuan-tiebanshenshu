/// 邵子条文 Repository 实现
///
/// 从 Flutter assets 加载邵子数条文数据，实现 TiaoWenRepository 接口。
library;

import 'package:flutter/services.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
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
  // L0 TiaoWenRepository 接口实现
  // ============================================================

  @override
  Future<Result<TiaoWenDataModel?>> get(int id, RequestContext ctx) async {
    await _ensureInitialized();
    return Ok(_cache[id]);
  }

  @override
  Future<Result<bool>> exists(int id, RequestContext ctx) async {
    await _ensureInitialized();
    return Ok(_cache.containsKey(id));
  }

  @override
  Future<Result<Page<TiaoWenDataModel>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    await _ensureInitialized();

    var results = _cache.values.toList();

    // 按 ids 过滤
    final ids = spec['ids'];
    if (ids is List) {
      final idSet = ids.whereType<int>().toSet();
      results = results.where((e) => idSet.contains(e.id)).toList();
    }

    // 按地支名称过滤
    final setName = spec['setName'];
    if (setName is String) {
      final targetZhi = DiZhi.values.firstWhere(
        (d) => d.name == setName,
        orElse: () => DiZhi.ZI,
      );
      results = results.where((e) => e.setName == targetZhi).toList();
    }

    // 按内容关键词过滤
    final contentKeyword = spec['contentKeyword'];
    if (contentKeyword is String) {
      results = results
          .where((e) => e.content1.contains(contentKeyword))
          .toList();
    }

    // 排序
    results.sort((a, b) => a.id.compareTo(b.id));

    // 分页
    final items = results.take(page.limit).toList();

    return Ok(Page(
      items: items,
      nextCursor: items.length < results.length ? '${items.length}' : null,
    ));
  }

  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) async {
    await _ensureInitialized();
    return Ok(_cache.length);
  }
}
