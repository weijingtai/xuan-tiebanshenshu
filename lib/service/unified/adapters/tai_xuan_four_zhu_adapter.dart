import '../../../domain/models/unified/divination_context.dart';
import '../../../domain/models/unified/divination_result.dart';
import '../../../domain/models/tai_xuan_base_number_model.dart';
import '../../strategy/tai_xuan_four_zhu_strategy.dart';
import '../unified_strategy_adapter.dart';

class TaiXuanFourZhuAdapter implements UnifiedStrategyAdapter {
  final TaiXuanFourZhuStrategy _strategy;

  TaiXuanFourZhuAdapter(this._strategy);

  @override
  String get strategyId => 'TaiXuanFourZhuStrategy';

  @override
  String get title => '太玄四柱取数';

  @override
  List<String> get dependencies => [];

  @override
  Future<DivinationResult> execute(DivinationContext context) async {
    final eightChars = context.eightChars;
    final List<DivinationItem> items = [];

    // 执行两种不同的纳甲方法
    final methods = [
      TaiXuanNaJiaMethod.yearGanYinYang,
      TaiXuanNaJiaMethod.innerOuterGua,
    ];

    for (var method in methods) {
      final params = TaiXuanFourZhuStrategyParams(
        eightChars: eightChars,
        naJiaMethod: method,
      );

      try {
        final result = _strategy.calculate(params);

        if (result.hasError) {
          items.add(
            DivinationItem(
              label: 'Error (${method.name})',
              content: 'Error: ${result.errorMessage}',
            ),
          );
          continue;
        }

        items.addAll(
          result.baseNumbers.map((baseNumber) {
            return DivinationItem(
              label: baseNumber.name,
              content: baseNumber.baseNumber.toString(),
              tags: [method.name, baseNumber.sourceDescription],
              metadata: baseNumber.toMap(),
            );
          }),
        );
      } catch (e) {
        items.add(
          DivinationItem(
            label: 'Error (${method.name})',
            content: 'Exception: $e',
          ),
        );
      }
    }

    return StandardDivinationResult(
      strategyId: strategyId,
      title: title,
      items: items,
    );
  }
}
