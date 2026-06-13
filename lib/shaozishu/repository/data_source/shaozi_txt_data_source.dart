/// 邵子 TXT 条文数据源
///
/// 从本地 TXT 文件加载邵子数条文数据，实现 [TiaoWenLocalDataSource] 接口。
///
/// 数据目录：D:\数术\邵子数条目\
/// 文件命名：按地支（子/丑/寅...亥）分组的 .txt 文件，每行格式为「编号 内容」。
library;

import 'dart:io';

import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

import 'tiao_wen_local_data_source.dart';

/// 邵子条文数据默认目录
const String _defaultDataDir = r'D:\数术\邵子数条目';

/// 地支文件名 → DiZhi 枚举映射
const Map<String, DiZhi> _fileNameToDiZhi = {
  '子': DiZhi.zi,
  '丑': DiZhi.chou,
  '寅': DiZhi.yin,
  '卯': DiZhi.mao,
  '辰': DiZhi.chen,
  '巳': DiZhi.si,
  '午': DiZhi.wu,
  '未': DiZhi.wei,
  '申': DiZhi.shen,
  '酉': DiZhi.you,
  '戌': DiZhi.xu,
  '亥': DiZhi.hai,
};

/// 邵子 TXT 数据源
///
/// 从 [dataDir] 目录读取 12 个地支 .txt 文件，解析并缓存所有条文。
/// 支持懒加载 + 内存缓存，确保并发安全。
class ShaoziTxtDataSource implements TiaoWenLocalDataSource {
  /// 条文数据目录
  final String dataDir;

  /// 内存缓存：条文编号 → 条文模型
  final Map<int, TiaoWenDataModel> _cache = {};

  /// 是否已完成初始化
  bool _initialized = false;

  /// 初始化完成标志，用于外部检查
  bool get isInitialized => _initialized;

  /// 缓存中的条文总数
  int get cachedCount => _cache.length;

  ShaoziTxtDataSource({String? dataDir})
      : dataDir = dataDir ?? _defaultDataDir;

  /// 确保数据已加载（懒加载入口）
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    final dir = Directory(dataDir);
    if (!await dir.exists()) {
      throw TiebanshenshuRepositoryError(
        message: '邵子条文数据目录不存在: $dataDir',
      );
    }

    final files =
        await dir.list().where((e) => e.path.endsWith('.txt')).toList();

    if (files.isEmpty) {
      throw TiebanshenshuRepositoryError(
        message: '邵子条文数据目录中没有 .txt 文件: $dataDir',
      );
    }

    for (final file in files) {
      await _loadFile(File(file.path));
    }

    _initialized = true;
  }

  /// 解析单个 TXT 条文文件
  ///
  /// 从文件名提取地支归属，然后逐行解析。
  Future<void> _loadFile(File file) async {
    final fileName =
        file.uri.pathSegments.last.replaceAll('.txt', '');
    final diZhi = _fileNameToDiZhi[fileName];

    if (diZhi == null) {
      // 跳过无法识别地支的文件（如非预期的文件名）
      return;
    }

    final lines = await file.readAsLines();
    for (final line in lines) {
      final tiaoWen = _parseLine(line.trim(), diZhi);
      if (tiaoWen != null) {
        _cache[tiaoWen.id] = tiaoWen;
      }
    }
  }

  /// 解析单行条文文本
  ///
  /// 格式：`<编号><分隔符><内容>`
  /// 分隔符优先匹配制表符（\t），其次匹配首个空格。
  TiaoWenDataModel? _parseLine(String line, DiZhi diZhi) {
    if (line.isEmpty || line.startsWith('#') || line.startsWith('//')) {
      return null;
    }

    // 按制表符分割
    int splitIndex = line.indexOf('\t');

    // 没有制表符则按首个空格分割
    if (splitIndex == -1) {
      splitIndex = line.indexOf(' ');
      if (splitIndex == -1) return null;
    }

    final numberStr = line.substring(0, splitIndex);
    final content = line.substring(splitIndex + 1).trim();
    final number = int.tryParse(numberStr);
    if (number == null) return null;

    // 尝试从内容中提取年龄信息
    final ageSet1 = _extractAgeSet(content);

    return TiaoWenDataModel(
      id: number,
      setName: diZhi,
      content1: content,
      ageSet1: ageSet1,
    );
  }

  /// 从条文内容中提取年龄集合
  ///
  /// 匹配全角括号内的年龄数字，如"（47）"或"（21 22）"。
  /// 无年龄标记时返回 null。
  List<int>? _extractAgeSet(String content) {
    // 匹配全角括号：\uff08 和 \uff09
    final agePattern = RegExp(r'\uff08(\d+(?:\s+\d+)*)\uff09');
    final match = agePattern.firstMatch(content);

    if (match == null) return null;

    final ageStr = match.group(1)!;
    final ages = ageStr
        .split(RegExp(r'\s+'))
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();

    return ages.isEmpty ? null : ages;
  }

  /// 强制重新加载所有数据（清除缓存后重新初始化）
  Future<void> reload() async {
    _cache.clear();
    _initialized = false;
    await _ensureInitialized();
  }

  /// 清除缓存（测试用）
  void clearCache() {
    _cache.clear();
    _initialized = false;
  }

  // ============================================================
  // TiaoWenLocalDataSource 接口实现
  // ============================================================

  @override
  Future<List<TiaoWenDataModel>> loadAll() async {
    await _ensureInitialized();
    final list = _cache.values.toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  @override
  Future<TiaoWenDataModel?> getById(int id) async {
    await _ensureInitialized();
    return _cache[id];
  }

  @override
  Future<List<TiaoWenDataModel>> getByIdList(List<int> ids) async {
    await _ensureInitialized();
    return ids
        .where((id) => _cache.containsKey(id))
        .map((id) => _cache[id]!)
        .toList();
  }

  @override
  Future<Map<int, TiaoWenDataModel>> getByIdMap(List<int> ids) async {
    await _ensureInitialized();
    final result = <int, TiaoWenDataModel>{};
    for (final id in ids) {
      final model = _cache[id];
      if (model != null) {
        result[id] = model;
      }
    }
    return result;
  }

  @override
  Future<List<TiaoWenDataModel>> search({
    String? setName,
    String? contentKeyword,
  }) async {
    await _ensureInitialized();
    Iterable<TiaoWenDataModel> results = _cache.values;

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
      results = results.where((e) => e.content1.contains(contentKeyword));
    }

    return results.toList()..sort((a, b) => a.id.compareTo(b.id));
  }

  @override
  Future<int> getCount() async {
    await _ensureInitialized();
    return _cache.length;
  }
}
