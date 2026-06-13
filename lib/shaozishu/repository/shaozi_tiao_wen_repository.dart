/// 邵子条文 Repository 实现
///
/// 从本地 TXT 文件读取邵子数条文数据，实现 TiaoWenRepository 接口。
library;

import 'dart:io';

import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

/// 邵子条文数据库文件路径
const String _defaultDataDir = r'D:\数术\邵子数条目';

/// 邵子条文 Repository
///
/// 实现 [TiaoWenRepository] 接口，从本地 TXT 条文文件加载数据。
/// 条文文件命名格式：按数字范围或地支分组的 .txt 文件。
class ShaoziTiaoWenRepository implements TiaoWenRepository {
  /// 条文数据目录
  final String dataDir;

  /// 内存缓存：条文编号 → 条文模型
  final Map<int, TiaoWenDataModel> _cache = {};

  /// 是否已初始化
  bool _initialized = false;

  ShaoziTiaoWenRepository({String? dataDir})
      : dataDir = dataDir ?? _defaultDataDir;

  /// 从 TXT 文件加载条文数据
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    final dir = Directory(dataDir);
    if (!await dir.exists()) {
      throw TiebanshenshuRepositoryError(
        message: '邵子条文数据目录不存在: $dataDir',
      );
    }

    final files = await dir.list().where((e) => e.path.endsWith('.txt')).toList();
    for (final file in files) {
      await _loadFile(File(file.path));
    }

    _initialized = true;
  }

  /// 解析单个 TXT 条文文件
  ///
  /// 预期格式：每行一条，编号与内容以制表符或空格分隔。
  Future<void> _loadFile(File file) async {
    final lines = await file.readAsLines();
    for (final line in lines) {
      final tiaoWen = _parseLine(line.trim());
      if (tiaoWen != null) {
        _cache[tiaoWen.id] = tiaoWen;
      }
    }
  }

  /// 解析单行条文文本
  ///
  /// 返回 [TiaoWenDataModel] 或 null（跳过空行/注释）。
  TiaoWenDataModel? _parseLine(String line) {
    if (line.isEmpty || line.startsWith('#') || line.startsWith('//')) {
      return null;
    }

    // 按制表符或首个空格分割：编号<TAB>内容
    final splitIndex = line.indexOf('\t');
    if (splitIndex == -1) {
      // 尝试按空格分割
      final spaceIndex = line.indexOf(' ');
      if (spaceIndex == -1) return null;
      final numberStr = line.substring(0, spaceIndex);
      final content = line.substring(spaceIndex + 1);
      final number = int.tryParse(numberStr);
      if (number == null) return null;
      return TiaoWenDataModel(
        id: number,
        setName: DiZhi.zi,  // 默认地支，实际应在加载后根据分组填充
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
      setName: DiZhi.zi,
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
    // TODO: 实现分页查询
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
        orElse: () => DiZhi.zi,
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
    // TODO: 实现间隔查询
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
