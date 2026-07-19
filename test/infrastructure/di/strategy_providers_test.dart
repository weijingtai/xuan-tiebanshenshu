import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import 'package:tiebanshenshu/infrastructure/di/strategy_providers.dart';

class _FakeTiebanRecordRepository implements TiebanRecordRepository {
  @override
  Future<List<TiebanDivinationRecordContract>> getAllRecords() async =>
      const [];

  @override
  Future<TiebanDivinationRecordContract?> getRecordByUuid(String uuid) async =>
      null;

  @override
  Future<String> saveRecord(TiebanDivinationRecordContract record) async =>
      record.uuid;

  @override
  Future<bool> softDeleteRecord(String uuid) async => true;

  @override
  Stream<List<TiebanDivinationRecordContract>> watchAllRecords() =>
      Stream.value(const []);
}

class _FakeTiaoWenRepository implements TiaoWenRepository {
  @override
  Future<TiaoWenDataModel?> getById(int id) async => null;

  @override
  Future<List<TiaoWenDataModel>> getAroundById({
    required int centerId,
    required int beforeCount,
    required int afterCount,
    bool includeCenterItem = true,
  }) async => const [];

  @override
  Future<List<TiaoWenDataModel>> getByIdList({
    required List<int> queryList,
    bool preserveOrder = false,
    bool skipNotFound = true,
  }) async => const [];

  @override
  Future<List<TiaoWenDataModel>> getByIdRange({
    required int startId,
    required int endId,
  }) async => const [];

  @override
  Future<List<TiaoWenDataModel>> getByIdsWithPageRange({
    required List<int> ids,
    required List<int> pageRange,
    int steps = 1,
  }) async => const [];

  @override
  Future<List<TiaoWenDataModel>> getByIntervalAroundId({
    required int centerId,
    required int interval,
    required int minCount,
    int? maxRange,
    bool includeCenterItem = true,
  }) async => const [];

  @override
  Future<int> getCount() async => 0;

  @override
  Future<String?> getTiaoWenContentByNumber(int number) async => null;

  @override
  Future<Map<int, String>> getTiaoWenContentByNumbers(
    List<int> numbers,
  ) async => const {};

  @override
  Future<List<TiaoWenDataModel>> listAll() async => const [];

  @override
  Future<List<TiaoWenDataModel>> search({
    String? setName,
    String? contentKeyword,
  }) async => const [];
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
