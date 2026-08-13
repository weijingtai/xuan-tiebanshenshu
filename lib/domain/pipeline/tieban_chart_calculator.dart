import 'dart:convert';

import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_calculator.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_info.dart';
import 'package:tiebanshenshu/enums.dart' as tieban_enums;
import 'package:tiebanshenshu/service/strategy/yuan_tang_strategy.dart';

import 'tieban_calculation_context.dart';
import 'tieban_chart_params.dart';

final class TiebanChartCalculator
    implements ChartCalculator<TiebanChartParams, TiebanDivinationRecordContract> {
  final TiebanCalculationContext context;

  const TiebanChartCalculator({
    this.context = const TiebanCalculationContext(),
  });

  @override
  String get module => 'tiebanshenshu';

  @override
  TiebanDivinationRecordContract calculate(ResolvedMoment moment, TiebanChartParams params) {
    final eightChars = moment.eightChars;
    final gender = params.isMale ? Gender.male : Gender.female;
    final yearYinYang = eightChars.yearTianGan.yinYang;

    final yuanTangCalculator = YuanTangCalculator();
    final YuanTangInfo yuanTangInfo = yuanTangCalculator.calculate(
      eightChars: eightChars,
      yearYinYang: yearYinYang,
      gender: gender,
      threeYuan: YuanYunOrder.lower,
      birthJieQi: TwentyFourJieQi.XIA_ZHI,
      monthType: YuanTangMonthType.monthYinYan,
      calanderType: tieban_enums.CalanderType.solar,
      birthMonth: YuanTangStrategyParams.getMonthNumberFromZhi(
        eightChars.month.zhi.name,
      ),
    );

    final calculationResult = {
      'xiantianGua': yuanTangInfo.xianTanGua.gua.name,
      'houTianGua': yuanTangInfo.houTianGua.gua.name,
      'yuanTangYaoIndex': yuanTangInfo.xianTanGua.yuanTangYao.indexAtYaoList,
      'yaoList': yuanTangInfo.xianTanGua.yuanTangYaoList
          .map((y) => {
                'order': y.order.index,
                'yinYang': y.yinYang.isYang ? '阳' : '阴',
                'isYuanTang': y.isYuanTang,
              })
          .toList(),
    };

    final paramsPayload = {
      'isMale': params.isMale,
      'eightChars': eightChars.toString(),
      'gender': gender.name,
      'yearYinYang': yearYinYang.name,
      'latitude': params.latitude,
      'longitude': params.longitude,
      'altitude': params.altitude,
      'timezone': params.timezone,
    };

    return TiebanDivinationRecordContract(
      uuid: params.uuid,
      question: '铁板神数排盘',
      createdAt: moment.nominalTime,
      calculationResultJson: jsonEncode(calculationResult),
      paramsJson: jsonEncode(paramsPayload),
    );
  }
}
