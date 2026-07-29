import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

import 'tieban_calculation_context.dart';
import 'tieban_chart_calculator.dart';
import 'tieban_chart_params.dart';

/// 铁板神数管线编排器，参照七政的 QizhengPipelineExecutor 结构。
class TiebanPipelineResult {
  final TiebanDivinationRecordContract contract;
  const TiebanPipelineResult({required this.contract});
}

class TiebanPipelineExecutor {
  Future<TiebanPipelineResult> execute({
    required ResolvedMoment moment,
    required TiebanChartParams params,
  }) async {
    final context = await TiebanCalculationContext.load();
    final calculator = TiebanChartCalculator(context: context);
    final contract = calculator.calculate(moment, params);
    return TiebanPipelineResult(contract: contract);
  }
}
