import 'dart:convert';

import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

class TiebanRecordModuleCodec
    implements RecordModuleCodec<TiebanDivinationRecordContract> {
  @override
  String get module => 'tiebanshenshu';

  @override
  String get category => 'divination';

  @override
  String get divinationType => 'tieban';

  @override
  String uuidOf(TiebanDivinationRecordContract contract) => contract.uuid;

  @override
  TiebanDivinationRecordContract withUuid(
    TiebanDivinationRecordContract contract,
    String uuid,
  ) {
    return TiebanDivinationRecordContract(
      uuid: uuid,
      question: contract.question,
      birthDatetimeJson: contract.birthDatetimeJson,
      birthGanZhiJson: contract.birthGanZhiJson,
      calculationResultJson: contract.calculationResultJson,
      matchedTiaoWenIdsJson: contract.matchedTiaoWenIdsJson,
      paramsJson: contract.paramsJson,
      createdAt: contract.createdAt,
      updatedAt: contract.updatedAt,
      deletedAt: contract.deletedAt,
    );
  }

  @override
  EncodedRecord encode(
    TiebanDivinationRecordContract contract, {
    required String scopeUid,
  }) {
    Map<String, dynamic>? params;
    if (contract.paramsJson != null && contract.paramsJson!.isNotEmpty) {
      params = jsonDecode(contract.paramsJson!) as Map<String, dynamic>;
    }

    final meta = RecordMeta(
      uuid: contract.uuid,
      scopeUid: scopeUid,
      module: module,
      category: category,
      divinationType: divinationType,
      createdAt: contract.createdAt,
      updatedAt: contract.updatedAt,
      deletedAt: contract.deletedAt,
      question: contract.question,
      gender: null,
      occurredAtUtc: contract.createdAt,
      reckoningType: '标准时间',
      timezoneStr: params?['timezone'] as String?,
      latitude: params?['latitude'] as double?,
      longitude: params?['longitude'] as double?,
      locationName: null,
      spacetimeJson: contract.birthDatetimeJson,
    );

    final moduleData = {
      'birthDatetimeJson': contract.birthDatetimeJson,
      'birthGanZhiJson': contract.birthGanZhiJson,
      'calculationResultJson': contract.calculationResultJson,
      'matchedTiaoWenIdsJson': contract.matchedTiaoWenIdsJson,
      'paramsJson': contract.paramsJson,
    };

    return (meta: meta, moduleData: moduleData);
  }

  @override
  TiebanDivinationRecordContract decode(
    RecordMeta meta,
    Map<String, dynamic>? moduleData,
  ) {
    if (meta.module != module) {
      throw RecordCodecMismatch(
        message: 'Expected module $module, got ${meta.module}',
      );
    }

    return TiebanDivinationRecordContract(
      uuid: meta.uuid,
      question: meta.question,
      birthDatetimeJson: moduleData?['birthDatetimeJson'] as String?,
      birthGanZhiJson: moduleData?['birthGanZhiJson'] as String?,
      calculationResultJson: moduleData?['calculationResultJson'] as String?,
      matchedTiaoWenIdsJson: moduleData?['matchedTiaoWenIdsJson'] as String?,
      paramsJson: moduleData?['paramsJson'] as String?,
      createdAt: meta.createdAt,
      updatedAt: meta.updatedAt,
      deletedAt: meta.deletedAt,
    );
  }

  @override
  List<SearchTag> extractSearchTags(
    RecordMeta meta,
    Map<String, dynamic>? moduleData,
  ) {
    final tags = <SearchTag>[];

    if (meta.question != null) {
      tags.add(SearchTag('question', meta.question!));
    }

    if (meta.gender != null) {
      tags.add(SearchTag('gender', meta.gender!));
    }

    tags.add(SearchTag('createdAt', meta.createdAt.toIso8601String()));

    final calculationResult =
        moduleData?['calculationResultJson'] as String?;
    if (calculationResult != null && calculationResult.isNotEmpty) {
      tags.add(SearchTag('hasResult', 'true'));
    }

    final matchedTiaoWenIds =
        moduleData?['matchedTiaoWenIdsJson'] as String?;
    if (matchedTiaoWenIds != null && matchedTiaoWenIds.isNotEmpty) {
      tags.add(SearchTag('hasMatchedTiaoWen', 'true'));
    }

    return tags;
  }
}
