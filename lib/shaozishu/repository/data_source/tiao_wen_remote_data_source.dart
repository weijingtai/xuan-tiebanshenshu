/// 条文远程数据源抽象接口 + 一期 Stub 实现
///
/// 为未来 Firebase / Supabase 远程同步预留接口。
/// 一期使用 StubTiaoWenRemoteDataSource 空实现，所有方法按降级策略返回。
library;

import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

/// 条文远程数据源抽象接口
///
/// 定义远程同步能力契约，为 Firebase / Supabase 后端预留。
abstract class TiaoWenRemoteDataSource {
  /// 从远程同步条文数据到本地
  ///
  /// 拉取远程增量变更（按最后同步时间），合并到本地数据源。
  Future<void> syncFromRemote();

  /// 推送单条条文到远程
  ///
  /// [model] 要推送的条文数据模型
  Future<void> pushToRemote(TiaoWenDataModel model);

  /// 根据地支从远程获取条文
  ///
  /// [zhi] 地支枚举值
  Future<List<TiaoWenDataModel>> fetchByDiZhi(DiZhi zhi);

  /// 检测远程数据源是否可用
  ///
  /// 返回 true 表示远程连接正常，可以执行同步操作。
  Future<bool> isAvailable();
}

/// 一期远程数据源 Stub 实现
///
/// 所有远程方法返回空/失败，确保 RepositoryImpl 的降级逻辑正常工作。
class StubTiaoWenRemoteDataSource implements TiaoWenRemoteDataSource {
  const StubTiaoWenRemoteDataSource();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<void> syncFromRemote() async {
    // 一期无远程后端，静默跳过
  }

  @override
  Future<void> pushToRemote(TiaoWenDataModel model) async {
    // 一期无远程后端，静默跳过
  }

  @override
  Future<List<TiaoWenDataModel>> fetchByDiZhi(DiZhi zhi) async {
    // 一期无远程后端，返回空列表
    return [];
  }
}
