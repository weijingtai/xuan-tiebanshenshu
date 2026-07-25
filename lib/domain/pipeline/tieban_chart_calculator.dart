import 'dart:convert';

import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_calculator.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_info.dart';
import 'package:tiebanshenshu/enums.dart' as tieban_enums;

import 'tieban_chart.dart';
import 'tieban_chart_params.dart';

final class TiebanChartCalculator
    implements ChartCalculator<TiebanChartParams, TiebanChart> {
  const TiebanChartCalculator();

  @override
  String get module => 'tiebanshenshu';

  @override
  TiebanChart calculate(ResolvedMoment moment, TiebanChartParams params) {
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
      calanderType: CalanderType.solar,
      birthMonth: YuanTangStrategyParams.getMonthNumberFromZhi(
        eightChars.month.zhi.name,
      ),
    );

    final calculationResult = {
      'xiantianGua': yuanTangInfo.xianTanGua.gua.name,
      'houTianGua': yuanTangInfo.houTianGua.gua.name,
      'yuanTangYaoIndex': yuanTangInfo.xianTanGua.yuanTangYao.indexAtYaoList,
      'yaoList': yuanTangInfo.xianTanGua.yaoList
          .map((y) => {
                'order': y.order.index,
                'yinYang': y.yinYang.isYang ? '阳' : '阴',
                'isYuanTang': y.isYuanTang,
              })
          .toList(),
    };

    final chartRequest = {
      'eightChars': eightChars.name,
      'gender': gender.name,
      'yearYinYang': yearYinYang.name,
      'latitude': params.latitude,
      'longitude': params.longitude,
      'altitude': params.altitude,
      'timezone': params.timezone,
    };

    return TiebanChart(
      uuid: '',
      question: '铁板神数排盘',
      isMale: params.isMale,
      createdAt: moment.nominalTime,
      chartRequestJson: jsonEncode(chartRequest),
      chartResultJson: jsonEncode(calculationResult),
      calculationResultJson: jsonEncode(calculationResult),
    );
  }
}
