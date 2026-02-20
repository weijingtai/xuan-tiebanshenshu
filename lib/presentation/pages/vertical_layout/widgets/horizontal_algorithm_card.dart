import 'package:flutter/material.dart';
import 'horizontal_tiao_wen_widget.dart';
import 'vertical_verse_row.dart'; // Reuse VerseRowData and VerseVersion models

class HorizontalAlgorithmCard extends StatefulWidget {
  final String title;
  final String formula;
  final Color themeColor;
  final bool isTinyMode;
  final List<VerseRowData> verses;

  /// The scope of this card. Determines header layout details.
  final TemporalScope temporalScope;

  /// The specific timeline node for this card, if it represents a flow of time.
  /// Used as the main title for [TemporalScope.decadeLuck] and [TemporalScope.yearlyLuck].
  final String? temporalNodeText;

  const HorizontalAlgorithmCard({
    super.key,
    required this.title,
    required this.formula,
    required this.themeColor,
    required this.isTinyMode,
    required this.verses,
    this.temporalScope = TemporalScope.natal,
    this.temporalNodeText,
  });

  @override
  State<HorizontalAlgorithmCard> createState() =>
      _HorizontalAlgorithmCardState();
}

class _HorizontalAlgorithmCardState extends State<HorizontalAlgorithmCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;

  static const _duration = Duration(milliseconds: 500);
  static const _curve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _duration,
      vsync: this,
      value: widget.isTinyMode ? 1.0 : 0.0, // Start at correct state
    );
    _animation = CurvedAnimation(parent: _controller, curve: _curve);
  }

  @override
  void didUpdateWidget(covariant HorizontalAlgorithmCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isTinyMode != widget.isTinyMode) {
      if (widget.isTinyMode) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        // t: 0.0 = Normal (expanded), 1.0 = Tiny (collapsed)
        final t = _animation.value;
        final normalFactor = 1.0 - t; // 1.0 = fully visible, 0.0 = hidden

        final bgColor = Color.lerp(
          const Color(0xFFFDFBF7), // Normal: opaque warm-white
          const Color(0x00FDFBF7), // Tiny:   transparent
          t,
        )!;
        final shadowColor = Color.lerp(
          const Color(0x1F000000), // Normal: visible shadow
          const Color(0x00000000), // Tiny:   no shadow
          t,
        )!;

        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 360.0,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top Header
                _buildHeader(normalFactor),

                // 2. Body (Verses)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildVerseWidgets(normalFactor: normalFactor),
                ),

                // 3. Bottom Footer
                _buildFooter(normalFactor),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Header — collapses via Align.heightFactor driven by animation
  // ─────────────────────────────────────────────────────────────

  Widget _buildHeader(double normalFactor) {
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: normalFactor,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: widget.themeColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildHeaderContent(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHeaderContent() {
    // If it's a temporal card (Decade or Yearly), the focus shifts:
    // the main title becomes the Temporal Node (e.g., "大运 戊戌", "2024 甲辰年"),
    // and the subtitle becomes the age/year range description.
    final isTemporal =
        widget.temporalScope == TemporalScope.decadeLuck ||
        widget.temporalScope == TemporalScope.yearlyLuck;

    final mainTitle = isTemporal && widget.temporalNodeText != null
        ? widget.temporalNodeText!
        : widget.title;

    final subTitle = isTemporal
        ? widget
              .formula // Often used for ranges in temporal
        : widget.formula;

    return [
      Text(
        mainTitle,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          letterSpacing: 2,
          fontFamily: "Noto Serif SC",
        ),
      ),
      if (subTitle.isNotEmpty) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            subTitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
              fontFamily: "JetBrains Mono",
            ),
          ),
        ),
      ],
    ];
  }

  // ─────────────────────────────────────────────────────────────
  // Footer — collapses via Align.heightFactor driven by animation
  // ─────────────────────────────────────────────────────────────

  Widget _buildFooter(double normalFactor) {
    return ClipRect(
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: normalFactor,
        child: Container(
          height: 24.0,
          decoration: BoxDecoration(
            color: widget.themeColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Verse Widgets + Separators
  // ─────────────────────────────────────────────────────────────

  List<Widget> _buildVerseWidgets({required double normalFactor}) {
    final List<Widget> widgets = [];
    for (int i = 0; i < widget.verses.length; i++) {
      final v = widget.verses[i];

      // Separator between verses — collapses + fades in sync with header/footer
      if (i > 0) {
        widgets.add(
          ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: normalFactor,
              child: Opacity(
                opacity: normalFactor,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: _DottedLineSeparator(color: Color(0x1F000000)),
                ),
              ),
            ),
          ),
        );
      }

      widgets.add(
        HorizontalTiaoWenWidget(
          id: v.id,
          watermark: v.watermark,
          versions:
              v.versions ??
              [
                VerseVersion(
                  source: "刻本",
                  content: v.verseText,
                  isPrimary: true,
                ),
              ],
          algoName: v.algorithm,
          algoShortName: v.subAlgorithm,
          tags: v.tags,
          ageBadge: v.ageBadge,
          yearRange: v.yearRange,
          seal: v.seal,
          sealColor: v.sealColor,
          themeColor: widget.themeColor,
          isTinyMode: widget.isTinyMode,
          temporalScope: widget.temporalScope,
          animationValue: _animation.value,
        ),
      );
    }
    return widgets;
  }
}

// ═══════════════════════════════════════════════════════════════
// Dotted Line Separator (unchanged)
// ═══════════════════════════════════════════════════════════════

class _DottedLineSeparator extends StatelessWidget {
  final Color color;

  const _DottedLineSeparator({this.color = const Color(0xFFE0E0E0)});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 3.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
