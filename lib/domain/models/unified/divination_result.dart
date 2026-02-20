/// 统一排盘结果模型
///
/// 用于标准化不同策略的输出，以便在统一视图中展示
library;

/// 统一排盘结果条目
class DivinationItem {
  /// 标签文本，例如 "年柱 - 方法A"
  final String label;

  /// 内容文本，通常是条文编号（如 "1234"）或具体断语
  final String content;

  /// 标签列表，用于分类和过滤，例如 ["元堂", "先天"]
  final List<String> tags;

  /// 元数据，用于存储额外信息（如爻详情、原始计算值等），支持下钻详情
  final Map<String, dynamic> metadata;

  /// 关联的条文诗句（可选，后续异步获取填入）
  final String? poeticVerse;

  /// 关联的注解（可选）
  final String? annotation;

  const DivinationItem({
    required this.label,
    required this.content,
    this.tags = const [],
    this.metadata = const {},
    this.poeticVerse,
    this.annotation,
  });

  /// 复制并更新
  DivinationItem copyWith({
    String? label,
    String? content,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? poeticVerse,
    String? annotation,
  }) {
    return DivinationItem(
      label: label ?? this.label,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      poeticVerse: poeticVerse ?? this.poeticVerse,
      annotation: annotation ?? this.annotation,
    );
  }

  @override
  String toString() =>
      'DivinationItem(label: $label, content: $content, tags: $tags)';
}

/// 统一排盘结果
///
/// 每个策略执行后产生的标准化结果
abstract class DivinationResult {
  /// 策略ID (通常对应 Strategy.id 或类名)
  String get strategyId;

  /// 结果标题，用于卡片头部展示
  String get title;

  /// 结果条目列表
  List<DivinationItem> get items;

  /// 是否包含错误
  bool get hasError;

  /// 错误信息（如果有）
  String? get errorMessage;
}

/// 通用的基础排盘结果实现
class StandardDivinationResult implements DivinationResult {
  @override
  final String strategyId;

  @override
  final String title;

  @override
  final List<DivinationItem> items;

  @override
  final bool hasError;

  @override
  final String? errorMessage;

  const StandardDivinationResult({
    required this.strategyId,
    required this.title,
    required this.items,
    this.hasError = false,
    this.errorMessage,
  });

  factory StandardDivinationResult.error({
    required String strategyId,
    required String title,
    required String error,
  }) {
    return StandardDivinationResult(
      strategyId: strategyId,
      title: title,
      items: [],
      hasError: true,
      errorMessage: error,
    );
  }
}
