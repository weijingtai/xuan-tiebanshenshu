/// 邵子神数 — 河洛天地数法计算工具类
///
/// 提供邵子神数 Phase 1 核心算法的纯函数实现。所有方法均为 static，
/// 无副作用，可直接用于单元测试。
///
/// 算法流程：
///   八字 (4干4支)
///     → 天干转邵子数 (4个) + 地支转河图双数 (8个) = 12个数
///     → 天数 (奇数和 % 25) + 地数 (偶数和 % 30)
///     → 本命基数 (天数×8 + 地数)
///     → 条文编号 (本命基数 × 24 % 6144)
///     → 加一倍法展开 (±96, ±192, ±384, ±768)
library;

import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/eight_chars.dart';

import '../constants/shao_zi_shu_constants.dart' as shaozishu;

/// 邵子数计算结果（单次河洛天地数法）
class ShaoZiShuResult {
  /// 12 个原始数值（4天干 + 8地支）
  final List<int> twelveNumbers;

  /// 天数（奇数之和）
  final int tianShuSum;

  /// 地数（偶数之和）
  final int diShuSum;

  /// 天数余数（天数 % 25，0→25）
  final int tianShu;

  /// 地数余数（地数 % 30，0→30）
  final int diShu;

  /// 本命基数（天数×8 + 地数）
  final int benMingJiShu;

  /// 最终条文编号（1~6144）
  final int tiaoWenNumber;

  /// 加一倍法展开后的条文列表（含基础数）
  final List<int> expandedTiaoWenNumbers;

  /// 计算过程描述
  final String calculationDetail;

  const ShaoZiShuResult({
    required this.twelveNumbers,
    required this.tianShuSum,
    required this.diShuSum,
    required this.tianShu,
    required this.diShu,
    required this.benMingJiShu,
    required this.tiaoWenNumber,
    required this.expandedTiaoWenNumbers,
    required this.calculationDetail,
  });

  @override
  String toString() =>
      'ShaoZiShuResult(tianShu: $tianShu, diShu: $diShu, '
      'benMingJiShu: $benMingJiShu, tiaoWen: $tiaoWenNumber)';
}

/// 河洛天地数法计算辅助类
///
/// 所有方法为 static，纯函数无副作用。
class ShaoZiShuCalculationHelper {
  // =========================================================================
  // 基础映射函数
  // =========================================================================

  /// 天干 → 邵子数
  ///
  /// 根据邵子数口诀「戊一乙癸二，庚三辛四同，壬甲从六数，丁七丙八宫，己九无差别」
  /// 将天干映射为对应的数值。
  static int ganToShaoZiNumber(TianGan gan) {
    return shaozishu.ganToShaoZiNumber[gan] ?? 0;
  }

  /// 地支 → 河图数（返回 [生数, 成数]）
  ///
  /// 根据口诀「亥子一六水，寅卯三八木，巳午二七火，申酉四九金，辰戌丑未五十土」
  /// 将地支映射为河图生成数（两个数值）。
  static List<int> zhiToHeTuNumbers(DiZhi zhi) {
    return shaozishu.zhiToHeTuNumbers[zhi] ?? [0, 0];
  }

  // =========================================================================
  // 核心计算函数
  // =========================================================================

  /// 从八字生成 12 个数（4 天干 × 1 + 4 地支 × 2 = 12）
  ///
  /// 天干：年干、月干、日干、时干 → 各 1 个邵子数
  /// 地支：年支、月支、日支、时支 → 各 2 个河图数（生数+成数）
  static List<int> calculateTwelveNumbers(EightChars eightChars) {
    final numbers = <int>[];

    // 天干 → 邵子数（4 个）
    for (final gan in eightChars.allTianGan) {
      numbers.add(ganToShaoZiNumber(gan));
    }

    // 地支 → 河图双数（4 × 2 = 8 个）
    for (final zhi in eightChars.allDiZhi) {
      numbers.addAll(zhiToHeTuNumbers(zhi));
    }

    return numbers;
  }

  /// 计算天数
  ///
  /// 天数 = sum(12 个数中的所有奇数) % 25
  /// 若余数为 0，则返回 25
  static int calculateTianShu(List<int> twelveNumbers) {
    final sum = twelveNumbers.where((n) => n % 2 == 1).fold<int>(0, (a, b) => a + b);
    final remainder = sum % shaozishu.tianShuMod;
    return remainder == 0 ? shaozishu.tianShuMod : remainder;
  }

  /// 计算地数
  ///
  /// 地数 = sum(12 个数中的所有偶数) % 30
  /// 若余数为 0，则返回 30
  static int calculateDiShu(List<int> twelveNumbers) {
    final sum = twelveNumbers.where((n) => n % 2 == 0).fold<int>(0, (a, b) => a + b);
    final remainder = sum % shaozishu.diShuMod;
    return remainder == 0 ? shaozishu.diShuMod : remainder;
  }

  /// 计算天数原始和（未取模）
  static int calculateTianShuSum(List<int> twelveNumbers) {
    return twelveNumbers.where((n) => n % 2 == 1).fold<int>(0, (a, b) => a + b);
  }

  /// 计算地数原始和（未取模）
  static int calculateDiShuSum(List<int> twelveNumbers) {
    return twelveNumbers.where((n) => n % 2 == 0).fold<int>(0, (a, b) => a + b);
  }

  /// 计算本命基数
  ///
  /// 本命基数 = 天数 × 8 + 地数
  static int calculateBenMingJiShu(int tianShu, int diShu) {
    return tianShu * 8 + diShu;
  }

  /// 计算条文编号
  ///
  /// 条文编号 = 本命基数 × 24 % 6144
  /// 若结果为 0，则返回 6144
  static int calculateTiaoWenNumber(int benMingJiShu) {
    final num = (benMingJiShu * 24) % shaozishu.totalTiaoWenCount;
    return num == 0 ? shaozishu.totalTiaoWenCount : num;
  }

  /// 加一倍法展开条文编号
  ///
  /// 以基础条文编号为中心，分别 ±96、±192、±384、±768，
  /// 生成 9 个条文编号（含基础值），并按 1~6144 范围裁剪。
  static List<int> expandByJiaYiBei(int baseTiaoWenNumber) {
    final results = <int>[];
    for (final offset in shaozishu.jiaYiBeiExpansionOffsets) {
      // 加法
      int plus = baseTiaoWenNumber + offset;
      if (plus > shaozishu.totalTiaoWenCount) plus -= shaozishu.totalTiaoWenCount;
      results.add(plus);

      // 减法（offset=0 时不重复添加）
      if (offset > 0) {
        int minus = baseTiaoWenNumber - offset;
        if (minus <= 0) minus += shaozishu.totalTiaoWenCount;
        results.add(minus);
      }
    }
    return results;
  }

  // =========================================================================
  // 完整流程
  // =========================================================================

  /// 执行完整的河洛天地数法计算
  ///
  /// 输入八字，输出完整的 [ShaoZiShuResult]，包含所有中间结果和最终条文。
  static ShaoZiShuResult calculate(EightChars eightChars) {
    final buffer = StringBuffer();
    buffer.writeln('===== 邵子数 河洛天地数法 计算过程 =====');
    buffer.writeln('八字: $eightChars');
    buffer.writeln();

    // 1. 生成 12 个数
    final twelveNumbers = calculateTwelveNumbers(eightChars);
    buffer.writeln('【步骤1】天干→邵子数 + 地支→河图数 (12个数)');
    buffer.write('  天干: ');
    for (int i = 0; i < 4; i++) {
      final gan = eightChars.allTianGan[i];
      buffer.write('${gan.value}=${twelveNumbers[i]} ');
    }
    buffer.writeln();
    buffer.write('  地支: ');
    for (int i = 0; i < 4; i++) {
      final zhi = eightChars.allDiZhi[i];
      final idx = 4 + i * 2;
      buffer.write('${zhi.value}=[${twelveNumbers[idx]},${twelveNumbers[idx + 1]}] ');
    }
    buffer.writeln();
    buffer.writeln('  全部: $twelveNumbers');
    buffer.writeln();

    // 2. 分离天数/地数
    final tianShuSum = calculateTianShuSum(twelveNumbers);
    final diShuSum = calculateDiShuSum(twelveNumbers);
    final oddNums = twelveNumbers.where((n) => n % 2 == 1).toList();
    final evenNums = twelveNumbers.where((n) => n % 2 == 0).toList();

    buffer.writeln('【步骤2】分离天数(奇数)与地数(偶数)');
    buffer.writeln('  天数(奇数): $oddNums → 和=$tianShuSum');
    buffer.writeln('  地数(偶数): $evenNums → 和=$diShuSum');
    buffer.writeln();

    // 3. 取天地余数
    final tianShu = calculateTianShu(twelveNumbers);
    final diShu = calculateDiShu(twelveNumbers);

    buffer.writeln('【步骤3】取天地余数');
    buffer.writeln('  天数: $tianShuSum % ${shaozishu.tianShuMod} = $tianShu');
    buffer.writeln('  地数: $diShuSum % ${shaozishu.diShuMod} = $diShu');
    buffer.writeln();

    // 4. 本命基数
    final benMingJiShu = calculateBenMingJiShu(tianShu, diShu);

    buffer.writeln('【步骤4】本命基数');
    buffer.writeln('  天数×8 + 地数 = $tianShu × 8 + $diShu = $benMingJiShu');
    buffer.writeln();

    // 5. 条文编号
    final tiaoWenNumber = calculateTiaoWenNumber(benMingJiShu);

    buffer.writeln('【步骤5】条文编号');
    buffer.writeln('  本命基数×24 % ${shaozishu.totalTiaoWenCount} = $benMingJiShu × 24 % ${shaozishu.totalTiaoWenCount} = $tiaoWenNumber');
    buffer.writeln();

    // 6. 加一倍法展开
    final expandedNumbers = expandByJiaYiBei(tiaoWenNumber);

    buffer.writeln('【步骤6】加一倍法展开');
    buffer.writeln('  基础数 ± (0, 96, 192, 384, 768): $expandedNumbers');
    buffer.writeln('===== 计算结束 =====');

    return ShaoZiShuResult(
      twelveNumbers: twelveNumbers,
      tianShuSum: tianShuSum,
      diShuSum: diShuSum,
      tianShu: tianShu,
      diShu: diShu,
      benMingJiShu: benMingJiShu,
      tiaoWenNumber: tiaoWenNumber,
      expandedTiaoWenNumbers: expandedNumbers,
      calculationDetail: buffer.toString(),
    );
  }
}
