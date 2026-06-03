import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:tiebanshenshu/domain/models/unified/divination_context.dart';
import 'package:tiebanshenshu/service/strategy/day_gan_zhi_gua_strategy.dart';
import 'package:tiebanshenshu/service/strategy/four_zhu_tian_gan_strategy.dart';
import 'package:tiebanshenshu/service/strategy/tai_xuan_four_zhu_strategy.dart';
import 'package:tiebanshenshu/service/unified/adapters/day_gan_zhi_gua_adapter.dart';
import 'package:tiebanshenshu/service/unified/adapters/four_zhu_tian_gan_adapter.dart';
import 'package:tiebanshenshu/service/unified/adapters/tai_xuan_four_zhu_adapter.dart';
import 'package:tiebanshenshu/service/unified/divination_orchestrator.dart';

void main() {
  test('Unified Divination Demo Run', () async {
    final logger = Logger();

    // 1. Prepare Data (Test Data: Gui Si, Jia Zi, Ding You, Gui Mao)
    final eightChars = EightChars(
      year: JiaZi.GUI_SI, // 癸巳
      month: JiaZi.JIA_ZI, // 甲子
      day: JiaZi.DING_YOU, // 丁酉
      time: JiaZi.GUI_MAO, // 癸卯
    );

    logger.i('Starting Unified Divination Demo');
    logger.i('Input EightChars: $eightChars');

    // 2. Initialize Context
    final context = DivinationContext.create(
      eightChars: eightChars,
      gender: Gender.male, // Assume Male
    );

    // 3. Initialize Strategies & Adapters
    final dayGanZhiGuaStrategy = DayGanZhiGuaStrategy();
    final fourZhuTianGanStrategy = FourZhuTianGanStrategy();
    final taiXuanFourZhuStrategy = TaiXuanFourZhuStrategy();

    final adapters = [
      DayGanZhiGuaAdapter(dayGanZhiGuaStrategy),
      FourZhuTianGanAdapter(fourZhuTianGanStrategy),
      TaiXuanFourZhuAdapter(taiXuanFourZhuStrategy),
    ];

    // 4. Initialize Orchestrator
    final orchestrator = DivinationOrchestrator();
    orchestrator.registerAll(adapters);

    // 5. Execute
    logger.i('Executing orchestration...');

    await for (final updatedContext in orchestrator.execute(context)) {
      logger.i('--- Context Updated ---');
      updatedContext.results.forEach((strategyId, result) {
        logger.i('Strategy: $strategyId');
        if (result.hasError) {
          logger.e('Error: ${result.errorMessage}');
        } else {
          for (var item in result.items) {
            logger.i(
              '  [${item.label}] -> Content: ${item.content}, Tags: ${item.tags}',
            );
          }
        }
      });
    }

    logger.i('--- Execution Completed ---');
  });
}
