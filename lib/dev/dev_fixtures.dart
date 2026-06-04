import 'package:metaphysics_core/models/datetime_details_bundle_logic_model.dart';
import 'package:metaphysics_core/models/calculation_strategy_config_logic_model.dart';
import 'package:metaphysics_core/models/chinese_date_info.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:metaphysics_core/models/seventy_two_phenology.dart';
import 'package:metaphysics_core/enums/enum_jia_zi.dart';
import 'package:metaphysics_core/enums/enum_twenty_four_jie_qi.dart';
import 'package:metaphysics_core/enums/enum_three_yuan.dart';
import 'package:metaphysics_core/datamodel/location.dart';
import 'package:metaphysics_core/datamodel/geo_location.dart';

class TiebanshenshuDevFixtures {
  static final DateTimeDetailsBundleLogicModel devUsa = _buildDevUsa();

  static DateTimeDetailsBundleLogicModel _buildDevUsa() {
    final standardDatetime = DateTime(2025, 9, 6, 16, 24);
    const timezone = 'America/Los_Angeles';
    final meanSolarDatetime = DateTime(2025, 9, 6, 15, 43, 26);
    final trueSolarDatetime = DateTime(2025, 9, 6, 15, 45);

    final coordinates = Coordinates(
      latitude: 38.80260970,
      longitude: -116.41938900,
    );

    final chineseInfo = ChineseDateInfo(
      eightChars: EightChars(
        year: JiaZi.YI_SI,
        month: JiaZi.JIA_SHEN,
        day: JiaZi.WU_YIN,
        time: JiaZi.GENG_SHEN,
      ),
      phenology: Phenology.phenologyList.where((t) => t.order == 51).first,
      lunarMonth: 7,
      lunarDay: 15,
      isLeapMonth: false,
      jieQiInfo: JieQiInfo(
        jieQi: TwentyFourJieQi.CHU_SHU,
        startAt: DateTime(2025, 8, 23, 23, 0, 0),
        endAt: DateTime(2025, 9, 6, 22, 59, 59),
      ),
      threeYuan: YuanYunOrder.lower,
      nineYun: NineYun.ninth,
    );

    return DateTimeDetailsBundleLogicModel(
      calculationConfig: CalculationStrategyConfigLogicModel.defaultConfig,
      standeredDatetime: standardDatetime,
      standeredChineseInfo: chineseInfo,
      utcDatetime: standardDatetime.toUtc(),
      timezoneStr: timezone,
      isDST: false,
      removeDSTDatetime: standardDatetime,
      removeDSTChineseInfo: chineseInfo,
      location: Location(
        address: Address(
          countryName: 'USA',
          countryId: 233,
          regionId: 1458,
          timezone: timezone,
          province: GeoLocation(
            code: '1458',
            parentCode: '233',
            level: GeoLevel.province,
            name: 'Nevada',
            latitude: 38.80260970,
            longitude: -116.41938900,
          ),
        ),
      ),
      meanSolarDatetime: meanSolarDatetime,
      meanSolarChineseInfo: chineseInfo,
      coordinates: coordinates,
      trueSolarDatetime: trueSolarDatetime,
      trueSolarChineseInfo: chineseInfo,
    );
  }
}
