/// 条文本地数据源抽象接口
///
/// 定义从本地存储读取邵子数条文数据的契约。
/// 实现类负责具体的本地存储技术（TXT 文件 / SQLite / CSV 等）。
library;

import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

/// 条文本地数据源接口
///
/// 所有本地数据源实现（TXT / SQLite / CSV 等）必须实现此接口。
abstract class TiaoWenLocalDataSource {
  /// 加载所有条文数据
  ///
  /// 返回按 ID 升序排列的条文列表。
  Future<List<TiaoWenDataModel>> loadAll();

  /// 根据 ID 获取单条条文
  ///
  /// [id] 条文编号
  /// 返回对应的条文模型，不存在则返回 null。
  Future<TiaoWenDataModel?> getById(int id);

  /// 根据 ID 列表批量获取条文
  ///
  /// [ids] 条文编号列表
  /// 返回匹配的条文列表，不存在的 ID 会被跳过。
  Future<List<TiaoWenDataModel>> getByIdList(List<int> ids);

  /// 根据 ID 列表批量获取条文（Map 形式）
  ///
  /// [ids] 条文编号列表
  /// 返回 Map<条文编号, 条文模型>，不存在的 ID 不会出现在返回中。
  Future<Map<int, TiaoWenDataModel>> getByIdMap(List<int> ids);

  /// 条件搜索条文
  ///
  /// [setName] 地支名称筛选（可选）
  /// [contentKeyword] 内容关键词搜索（可选）
  /// 返回符合条件的条文列表。
  Future<List<TiaoWenDataModel>> search({
    String? setName,
    String? contentKeyword,
  });

  /// 获取条文总数
  Future<int> getCount();
}
