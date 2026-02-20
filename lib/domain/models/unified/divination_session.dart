import 'divination_context.dart';

/// 排盘会话
///
/// 管理整个应用的生命周期，持有排盘的历史和分支
class DivinationSession {
  /// 会话ID
  final String id;

  /// 创建时间
  final DateTime createdAt;

  /// 所有分支的上下文列表 (历史记录)
  /// 索引 0 是初始状态，后续索引是不同的迭代或分支
  final List<DivinationContext> history;

  /// 当前激活的上下文索引
  final int currentIndex;

  const DivinationSession({
    required this.id,
    required this.createdAt,
    required this.history,
    this.currentIndex = 0,
  });

  /// 创建新会话
  factory DivinationSession.create(DivinationContext initialContext) {
    return DivinationSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      history: [initialContext],
      currentIndex: 0,
    );
  }

  /// 获取当前上下文
  DivinationContext get currentContext => history[currentIndex];

  /// 添加新的上下文作为最新状态 (推进一步)
  ///
  /// 如果当前索引不在末尾，这将创建一个分支（简单追加到列表）
  DivinationSession push(DivinationContext newContext) {
    final newHistory = List<DivinationContext>.from(history);
    newHistory.add(newContext);
    return copyWith(history: newHistory, currentIndex: newHistory.length - 1);
  }

  /// 切换到指定索引的历史状态
  DivinationSession switchTo(int index) {
    if (index < 0 || index >= history.length) {
      throw RangeError('Index out of bounds');
    }
    return copyWith(currentIndex: index);
  }

  /// 复制并更新
  DivinationSession copyWith({
    String? id,
    DateTime? createdAt,
    List<DivinationContext>? history,
    int? currentIndex,
  }) {
    return DivinationSession(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      history: history ?? this.history,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
