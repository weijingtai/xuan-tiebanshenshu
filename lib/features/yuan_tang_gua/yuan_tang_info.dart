import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../enums.dart';
import 'pure_yuan_tang_gua.dart';
import 'yuan_tang_info_ext.dart';
part 'yuan_tang_info.g.dart';

@JsonSerializable()
class YuanTangInfo {
  // ========== 输入参数 ==========
  /// 四柱信息
  final EightChars eightChars;

  /// 性别（"男" / "女"）
  final Gender gender;

  /// 三元（"上" / "中" / "下"）
  final YuanYunOrder threeYuan;
  final CalanderType calanderType;
  final int birthMonth;
  YinYang get monthYinYan => birthMonth % 2 == 0 ? YinYang.YIN : YinYang.YANG;

  YinYang get yearYinYang => eightChars.year.gan.yinYang;

  /// 时柱干支
  DiZhi get timeZhi => eightChars.time.diZhi;

  /// 时辰阴阳（"阳" / "阴"）
  YinYang get timeYinYang =>
      [
        DiZhi.ZI,
        DiZhi.CHOU,
        DiZhi.YIN,
        DiZhi.MAO,
        DiZhi.CHEN,
        DiZhi.SI,
      ].contains(timeZhi)
      ? YinYang.YANG
      : YinYang.YIN;

  /// 出生节气（"夏至" / "冬至"）
  final TwentyFourJieQi birthAfterJieQi;

  final PureYuanTangGua xianTanGua;
  final PureYuanTangGua houTianGua;

  /// 天地卦生成数据（可选，用于需要详细计算过程的场景）
  final TianDiGuaData? tianDiGuaData;

  /// 构造函数：初始化所有最终字段
  const YuanTangInfo({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.calanderType,
    required this.birthMonth,
    required this.birthAfterJieQi,
    required this.xianTanGua,
    required this.houTianGua,
    this.tianDiGuaData,
  });

  factory YuanTangInfo.fromJson(Map<String, dynamic> json) =>
      _$YuanTangInfoFromJson(json);

  Map<String, dynamic> toJson() => _$YuanTangInfoToJson(this);
}
