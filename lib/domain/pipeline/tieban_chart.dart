import 'package:equatable/equatable.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';

class TiebanChart extends Equatable implements Chart {
  final String uuid;
  final String question;
  final bool isMale;
  final DateTime createdAt;
  final String? chartRequestJson;
  final String? chartResultJson;
  final String? calculationResultJson;
  final String? matchedTiaoWenIdsJson;

  const TiebanChart({
    required this.uuid,
    required this.question,
    required this.isMale,
    required this.createdAt,
    this.chartRequestJson,
    this.chartResultJson,
    this.calculationResultJson,
    this.matchedTiaoWenIdsJson,
  });

  @override
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'question': question,
    'isMale': isMale,
    'createdAt': createdAt.toIso8601String(),
    'chartRequestJson': chartRequestJson,
    'chartResultJson': chartResultJson,
    'calculationResultJson': calculationResultJson,
    'matchedTiaoWenIdsJson': matchedTiaoWenIdsJson,
  };

  @override
  List<Object?> get props => [uuid, question, isMale, createdAt];
}
