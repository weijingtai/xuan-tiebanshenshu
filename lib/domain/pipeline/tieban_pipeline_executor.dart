import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import 'package:xuan_time_location/xuan_time_location.dart';

import 'tieban_calculation_context.dart';
import 'tieban_chart_calculator.dart';
import 'tieban_chart_params.dart';

/// 铁板神数管线编排器，参照七政的 QizhengPipelineExecutor 结构。
final class TiebanPipelineExecutor {
  final TiebanCalculationContext _context;
  final MomentResolver _momentResolver;

  TiebanPipelineExecutor({
    TiebanCalculationContext? context,
    MomentResolver? momentResolver,
  }) : _context = context ?? const TiebanCalculationContext(),
       _momentResolver = momentResolver ?? const DefaultMomentResolver();

  Future<TiebanDivinationRecordContract> execute(
    ChartRequest<TiebanChartParams> request,
  ) async {
    final moment = _momentResolver.resolve(request.moment);
    final calculator = TiebanChartCalculator(context: _context);
    return calculator.calculate(moment, request.params);
  }
}
