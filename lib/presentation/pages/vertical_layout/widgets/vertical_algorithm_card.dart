import 'package:flutter/material.dart';
import 'vertical_verse_row.dart';

class VerticalAlgorithmCard extends StatelessWidget {
  final String title;
  final String formula;
  final Color themeColor;
  final bool isTinyMode;
  final bool isFlipLayout;
  final List<VerseRowData> verses;

  const VerticalAlgorithmCard({
    super.key,
    required this.title,
    required this.formula,
    required this.themeColor,
    required this.isTinyMode,
    required this.isFlipLayout,
    required this.verses,
  });

  static const _animDuration = Duration(milliseconds: 600);
  static const _animCurve = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        duration: _animDuration,
        curve: _animCurve,
        width: 360.0,
        margin: EdgeInsets.zero,
        clipBehavior: isTinyMode ? Clip.none : Clip.antiAlias,
        decoration: BoxDecoration(
          color: isTinyMode
              ? const Color(0x00FDFBF7) // Same RGB, zero alpha — no flash-black
              : const Color(0xFFFDFBF7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isTinyMode
                  ? const Color(0x00000000)
                  : const Color(0x1F000000),
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
            _buildTopHeader(),

            // 2. Body (Verses)
            AnimatedPadding(
              duration: _animDuration,
              curve: _animCurve,
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildVerseWidgets(isTiny: isTinyMode),
              ),
            ),

            // 3. Bottom Footer
            _buildBottomFooter(),
          ],
        ),
      ),
    );
  }

  // _buildNormalMode and _buildTinyMode are replaced by the unified build method above.

  Widget _buildTopHeader() {
    return ClipRect(
      child: AnimatedAlign(
        duration: _animDuration,
        curve: _animCurve,
        alignment: Alignment.topCenter,
        heightFactor: isTinyMode ? 0.0 : 1.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: themeColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 2,
                  fontFamily: "Noto Serif SC",
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  formula,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: "JetBrains Mono",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomFooter() {
    return ClipRect(
      child: AnimatedAlign(
        duration: _animDuration,
        curve: _animCurve,
        alignment: Alignment.bottomCenter,
        heightFactor: isTinyMode ? 0.0 : 1.0,
        child: Container(
          height: 24,
          decoration: BoxDecoration(
            color: themeColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVerseWidgets({required bool isTiny}) {
    final List<Widget> widgets = [];
    for (int i = 0; i < verses.length; i++) {
      final v = verses[i];
      // Always render separator to keep widget tree stable for animations
      if (i > 0) {
        widgets.add(
          AnimatedSize(
            duration: _animDuration,
            curve: _animCurve,
            child: AnimatedOpacity(
              duration: _animDuration,
              curve: _animCurve,
              opacity: isTiny ? 0.0 : 1.0,
              child: SizedBox(
                height: isTiny ? 0 : null,
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
        VerticalVerseRow(
          id: v.id,
          watermark: v.watermark,
          versions: [
            VerseVersion(source: "刻本", content: v.verseText, isPrimary: true),
          ],
          algoName: v.algorithm,
          tags: v.tags,
          ageBadge: v.ageBadge,
          yearRange: v.yearRange,
          seal: v.seal,
          sealColor: v.sealColor,
          themeColor: themeColor,
          isTinyMode: isTiny,
          isFlipLayout: isFlipLayout,
        ),
      );
    }
    return widgets;
  }
}

class _DottedLineSeparator extends StatelessWidget {
  final double height;
  final Color color;

  const _DottedLineSeparator({
    this.height = 1,
    this.color = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 3.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
