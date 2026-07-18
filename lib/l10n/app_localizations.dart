import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('zh')];

  /// No description provided for @tiebanshenshu.
  ///
  /// In zh, this message translates to:
  /// **'铁板神数'**
  String get tiebanshenshu;

  /// No description provided for @taiXuanInteractive.
  ///
  /// In zh, this message translates to:
  /// **'太玄四柱交互式计算'**
  String get taiXuanInteractive;

  /// No description provided for @undo.
  ///
  /// In zh, this message translates to:
  /// **'撤销'**
  String get undo;

  /// No description provided for @restart.
  ///
  /// In zh, this message translates to:
  /// **'重新开始'**
  String get restart;

  /// No description provided for @help.
  ///
  /// In zh, this message translates to:
  /// **'帮助'**
  String get help;

  /// No description provided for @waitingForUserAction.
  ///
  /// In zh, this message translates to:
  /// **'等待用户操作...'**
  String get waitingForUserAction;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// No description provided for @interactiveHelp.
  ///
  /// In zh, this message translates to:
  /// **'交互式计算帮助'**
  String get interactiveHelp;

  /// No description provided for @loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loading;

  /// No description provided for @dataLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'数据加载失败'**
  String get dataLoadFailed;

  /// No description provided for @noCalculationResult.
  ///
  /// In zh, this message translates to:
  /// **'暂无计算结果'**
  String get noCalculationResult;

  /// No description provided for @calculationFailed.
  ///
  /// In zh, this message translates to:
  /// **'计算失败'**
  String get calculationFailed;

  /// No description provided for @confirmSelect.
  ///
  /// In zh, this message translates to:
  /// **'确认选择'**
  String get confirmSelect;

  /// No description provided for @selectAndCalculate.
  ///
  /// In zh, this message translates to:
  /// **'确认选择，进行后续计算'**
  String get selectAndCalculate;

  /// No description provided for @selectComplete.
  ///
  /// In zh, this message translates to:
  /// **'选择完成'**
  String get selectComplete;

  /// No description provided for @confirmByThreeGong.
  ///
  /// In zh, this message translates to:
  /// **'按三宫之数确认'**
  String get confirmByThreeGong;

  /// No description provided for @startNewSession.
  ///
  /// In zh, this message translates to:
  /// **'请开始一个新的会话'**
  String get startNewSession;

  /// No description provided for @initFailed.
  ///
  /// In zh, this message translates to:
  /// **'初始化失败：{error}'**
  String initFailed(Object error);

  /// No description provided for @refreshComplete.
  ///
  /// In zh, this message translates to:
  /// **'刷新完成'**
  String get refreshComplete;

  /// No description provided for @refreshFailed.
  ///
  /// In zh, this message translates to:
  /// **'刷新失败：{error}'**
  String refreshFailed(Object error);

  /// No description provided for @noResult.
  ///
  /// In zh, this message translates to:
  /// **'暂无结果'**
  String get noResult;

  /// No description provided for @selectFailed.
  ///
  /// In zh, this message translates to:
  /// **'选择失败：{error}'**
  String selectFailed(Object error);

  /// No description provided for @undoFailed.
  ///
  /// In zh, this message translates to:
  /// **'撤销失败：{error}'**
  String undoFailed(Object error);

  /// No description provided for @restartFailed.
  ///
  /// In zh, this message translates to:
  /// **'重新开始失败：{error}'**
  String restartFailed(Object error);

  /// No description provided for @confirmOrModifySizhu.
  ///
  /// In zh, this message translates to:
  /// **'确认或修改四柱信息'**
  String get confirmOrModifySizhu;

  /// No description provided for @canUndoAnyStep.
  ///
  /// In zh, this message translates to:
  /// **'您可以随时撤销到上一步，或重新开始整个过程。'**
  String get canUndoAnyStep;

  /// No description provided for @finalCalculationNotice.
  ///
  /// In zh, this message translates to:
  /// **'完成所有步骤后，系统将计算最终的条文列表。'**
  String get finalCalculationNotice;

  /// No description provided for @shareResult.
  ///
  /// In zh, this message translates to:
  /// **'分享结果'**
  String get shareResult;

  /// No description provided for @shareNotImplemented.
  ///
  /// In zh, this message translates to:
  /// **'分享功能待实现'**
  String get shareNotImplemented;

  /// No description provided for @noContent.
  ///
  /// In zh, this message translates to:
  /// **'暂无条文内容'**
  String get noContent;

  /// No description provided for @noMonthData.
  ///
  /// In zh, this message translates to:
  /// **'暂无流月数据'**
  String get noMonthData;

  /// No description provided for @tapToStart.
  ///
  /// In zh, this message translates to:
  /// **'点击刷新开始计算'**
  String get tapToStart;

  /// No description provided for @noYearData.
  ///
  /// In zh, this message translates to:
  /// **'暂无大运数据'**
  String get noYearData;

  /// No description provided for @kaoDingLiuQinStep5.
  ///
  /// In zh, this message translates to:
  /// **'选择完所有六亲类型后，点击\"确认选择\"继续'**
  String get kaoDingLiuQinStep5;

  /// No description provided for @taiXuanInteractiveHelpIntro.
  ///
  /// In zh, this message translates to:
  /// **'太玄四柱交互式计算允许您参与计算过程：'**
  String get taiXuanInteractiveHelpIntro;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
