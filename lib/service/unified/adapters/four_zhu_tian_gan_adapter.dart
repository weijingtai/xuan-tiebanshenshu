import '../../../domain/models/unified/divination_context.dart';
import '../../../domain/models/unified/divination_result.dart';
import '../../strategy/four_zhu_tian_gan_strategy.dart';
import '../unified_strategy_adapter.dart';

class FourZhuTianGanAdapter implements UnifiedStrategyAdapter {
  final FourZhuTianGanStrategy _strategy;

  FourZhuTianGanAdapter(this._strategy);

  @override
  String get strategyId => 'FourZhuTianGanStrategy';

  @override
  String get title => '四柱天干取数';

  @override
  List<String> get dependencies => [];

  @override
  Future<DivinationResult> execute(DivinationContext context) async {
    final params = FourZhuTianGanStrategyParams(eightChars: context.eightChars);

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
