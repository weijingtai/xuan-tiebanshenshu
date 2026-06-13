/// 邵子条文模型
///
/// 定义邵子数特有的条文数据结构，适配 repository_interface_tiebanshenshu 的 TiaoWenDataModel 接口。
library;

import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

/// 邵子条文模型
///
/// 包含条文编号、内容、地支归属、宫位分组（百位/十位）等字段。
/// 实现 [TiaoWenDataModel] 的字段映射，确保与 Repository 接口兼容。
class ShaoziTiaoWenModel {
  /// 条文编号
  final int number;

  /// 条文内容
  final String content;

  /// 所属地支
  final DiZhi diZhi;

  /// 宫位分组（百位：0-9）
  final int palaceGroup;

  /// 子分组（十位：0-9）
  final int subGroup;

  const ShaoziTiaoWenModel({
    required this.number,
    required this.content,
    required this.diZhi,
    required this.palaceGroup,
    required this.subGroup,
  });

  /// 从 [TiaoWenDataModel] 转换为 [ShaoziTiaoWenModel]
  ///
  /// [tiaoWen] 通用条文数据模型
  factory ShaoziTiaoWenModel.fromTiaoWenDataModel(TiaoWenDataModel tiaoWen) {
    final numberStr = tiaoWen.id.toString().padLeft(4, '0');
    final palaceGroup = int.parse(numberStr[0]);
    final subGroup = int.parse(numberStr[2]);

    return ShaoziTiaoWenModel(
      number: tiaoWen.id,
      content: tiaoWen.content1,
      diZhi: tiaoWen.setName,
      palaceGroup: palaceGroup,
      subGroup: subGroup,
    );
  }

  /// 转换为 [TiaoWenDataModel] 以兼容 Repository 接口
  TiaoWenDataModel toTiaoWenDataModel() {
    return TiaoWenDataModel(
      id: number,
      setName: diZhi,
      content1: content,
      ageSet1: [],
    );
  }

  @override
  String toString() =>
      'ShaoziTiaoWenModel(number: $number, diZhi: $diZhi, palace: $palaceGroup, sub: $subGroup)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShaoziTiaoWenModel &&
          number == other.number &&
          content == other.content &&
          diZhi == other.diZhi;

  @override
  int get hashCode => Object.hash(number, content, diZhi);
}
