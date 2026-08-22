import 'package:flutter_test/flutter_test.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import 'package:tiebanshenshu/infrastructure/di/strategy_providers.dart';

class _FakeTiebanRecordRepository implements TiebanRecordRepository {
  @override
  Future<Result<TiebanDivinationRecordContract?>> get(String uuid, RequestContext ctx) async => const Ok(null);

  @override
  Future<Result<bool>> exists(String uuid, RequestContext ctx) async => const Ok(false);

  @override
  Future<Result<Rev>> put(TiebanDivinationRecordContract record, RequestContext ctx, {Precondition pre = const Unconditional()}) async => const Ok(Rev('v1'));

  @override
  Future<Result<void>> softDelete(String uuid, RequestContext ctx, {Precondition pre = const Unconditional()}) async => const Ok(null);

  @override
  Future<Result<void>> restore(String uuid, RequestContext ctx) async => const Ok(null);

  @override
  Future<Result<TiebanDivinationRecordContract?>> getIncludingDeleted(String uuid, RequestContext ctx) async => const Ok(null);

  @override
  Future<Result<Page<TiebanDivinationRecordContract>>> query(Map<String, Object?> spec, PageRequest page, RequestContext ctx) async => const Ok(Page(items: []));

  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) async => const Ok(0);

  @override
  Stream<Result<List<TiebanDivinationRecordContract>>> watch(Map<String, Object?> spec, RequestContext ctx) => Stream.value(const Ok([]));

  @override
  Future<Result<BatchOutcome<String>>> putAll(List<TiebanDivinationRecordContract> entities, RequestContext ctx) async => const Ok(BatchOutcome([]));

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async => Ok(await body());
}

class _FakeTiaoWenRepository implements TiaoWenRepository {
  @override
  Future<Result<TiaoWenDataModel?>> get(int id, RequestContext ctx) async => const Ok(null);

  @override
  Future<Result<bool>> exists(int id, RequestContext ctx) async => const Ok(false);

  @override
  Future<Result<Page<TiaoWenDataModel>>> query(Map<String, Object?> spec, PageRequest page, RequestContext ctx) async => const Ok(Page(items: []));

  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) async => const Ok(0);
}

void main() {
  group('StrategyProviders', () {
    test('uses the caller supplied TiaoWenRepository boundary only', () {
      final providers = StrategyProviders.getProviders(
        _FakeTiebanRecordRepository(),
        tiaoWenRepository: _FakeTiaoWenRepository(),
      );

      final providerDescriptions = providers
          .map((p) => p.toString())
          .join('\n');

      expect(providerDescriptions, isNot(contains('TiaoWenLocalDataSource')));
      expect(providerDescriptions, isNot(contains('TiaoWenRemoteDataSource')));
      expect(providerDescriptions, isNot(contains('TiaoWenRepositoryImpl')));
    });
  });
}
