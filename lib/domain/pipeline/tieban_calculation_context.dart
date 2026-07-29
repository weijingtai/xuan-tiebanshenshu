/// 铁板神数排盘预处理上下文，参照七政的 QizhengCalculationContext 结构。
///
/// 当前铁板排盘链路是纯同步计算（YuanTangCalculator），无需预加载异步数据。
/// 本上下文预留为后续管线扩展点，例如预加载条文库、策略规则等。
class TiebanCalculationContext {
  const TiebanCalculationContext();

  static Future<TiebanCalculationContext> load() async {
    return const TiebanCalculationContext();
  }
}
