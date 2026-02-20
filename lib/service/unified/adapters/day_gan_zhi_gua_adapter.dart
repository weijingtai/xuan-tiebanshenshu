import '../../../domain/models/unified/divination_context.dart';
import '../../../domain/models/unified/divination_result.dart';
import '../../strategy/day_gan_zhi_gua_strategy.dart';
import '../unified_strategy_adapter.dart';

class DayGanZhiGuaAdapter implements UnifiedStrategyAdapter {
  final DayGanZhiGuaStrategy _strategy;

  DayGanZhiGuaAdapter(this._strategy);

  @override
  String get strategyId => 'DayGanZhiGuaStrategy';

  @override
  String get title => '日柱变卦取数';

  @override
  List<String> get dependencies => []; // No dependencies other than root

  @override
  Future<DivinationResult> execute(DivinationContext context) async {
    // 日柱变卦使用日柱
    final eightChars = context.eightChars;
    final params = DayGanZhiGuaStrategyParams(dayGanZhi: eightChars.day);

    try {
      final result = _strategy.calculate(params);

      if (result.hasError) {
        return StandardDivinationResult.error(
          strategyId: strategyId,
          title: title,
          error: result.errorMessage ?? 'Unknown error',
        );
      }

      final items = result.baseNumbers.map((baseNumber) {
        return DivinationItem(
          label: baseNumber.name,
          content: baseNumber.baseNumber.toString(),
          tags: [baseNumber.sourceDescription],
          metadata: result.sourceData,
        );
      }).toList();

      return StandardDivinationResult(
        strategyId: strategyId,
        title: title,
        items: items,
      );
    } catch (e) {
      return StandardDivinationResult.error(
        strategyId: strategyId,
        title: title,
        error: e.toString(),
      );
    }
  }
}
