// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get tiebanshenshu => '铁板神数';

  @override
  String get taiXuanInteractive => '太玄四柱交互式计算';

  @override
  String get undo => '撤销';

  @override
  String get restart => '重新开始';

  @override
  String get help => '帮助';

  @override
  String get waitingForUserAction => '等待用户操作...';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get interactiveHelp => '交互式计算帮助';

  @override
  String get loading => '加载中...';

  @override
  String get dataLoadFailed => '数据加载失败';

  @override
  String get noCalculationResult => '暂无计算结果';

  @override
  String get calculationFailed => '计算失败';

  @override
  String get confirmSelect => '确认选择';

  @override
  String get selectAndCalculate => '确认选择，进行后续计算';

  @override
  String get selectComplete => '选择完成';

  @override
  String get confirmByThreeGong => '按三宫之数确认';

  @override
  String get startNewSession => '请开始一个新的会话';

  @override
  String initFailed(Object error) {
    return '初始化失败：$error';
  }

  @override
  String get refreshComplete => '刷新完成';

  @override
  String refreshFailed(Object error) {
    return '刷新失败：$error';
  }

  @override
  String get noResult => '暂无结果';

  @override
  String selectFailed(Object error) {
    return '选择失败：$error';
  }

  @override
  String undoFailed(Object error) {
    return '撤销失败：$error';
  }

  @override
  String restartFailed(Object error) {
    return '重新开始失败：$error';
  }

  @override
  String get confirmOrModifySizhu => '确认或修改四柱信息';

  @override
  String get canUndoAnyStep => '您可以随时撤销到上一步，或重新开始整个过程。';

  @override
  String get finalCalculationNotice => '完成所有步骤后，系统将计算最终的条文列表。';

  @override
  String get shareResult => '分享结果';

  @override
  String get shareNotImplemented => '分享功能待实现';

  @override
  String get noContent => '暂无条文内容';

  @override
  String get noMonthData => '暂无流月数据';

  @override
  String get tapToStart => '点击刷新开始计算';

  @override
  String get noYearData => '暂无大运数据';

  @override
  String get kaoDingLiuQinStep5 => '选择完所有六亲类型后，点击\"确认选择\"继续';

  @override
  String get taiXuanInteractiveHelpIntro => '太玄四柱交互式计算允许您参与计算过程：';

  @override
  String get featureStrategyDemoSubtitle => '综合策略演示';

  @override
  String get featureFourDoorsSubtitle => '四门与枪法';

  @override
  String get featureKaoKeSubtitle => '考刻交互推演';

  @override
  String get featureHuangJiSubtitle => '皇极经世排盘';

  @override
  String get featureVerticalLayoutSubtitle => '传统竖排版';

  @override
  String get featureBase18Subtitle => 'Base 18 竖排版';
}
