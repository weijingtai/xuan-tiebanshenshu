import 'package:flutter/material.dart';

/// Defines the temporal scope or level of a divination result.
enum TemporalScope {
  natal, // 本命 (基石)
  decadeLuck, // 大运 (10年)
  yearlyLuck, // 流年 (1年)
  monthlyLuck, // 流月 (1月)
  dailyLuck, // 流日 (1日)
  hourlyLuck, // 流时 (1时辰)
}

class VerseVersion {
  final String source;
  final String content;
  final bool isPrimary;
  final String? ageBadge;

  const VerseVersion({
    required this.source,
    required this.content,
    this.isPrimary = false,
    this.ageBadge,
  });
}

/// Data model for a single verse row, used to pass data from page to card.
class VerseRowData {
  final String id;
  final String watermark;
  final String verseText;
  final List<String> tags;
  final String? ageBadge;
  final String? yearRange;
  final String seal;
  final Color sealColor;

  // New fields for grouping
  final String algorithm;
  final String? subAlgorithm;
  final String description; // To be used as card subtitle/formula

  /// The temporal scope of this verse row. Defaults to [TemporalScope.natal].
  final TemporalScope temporalScope;

  /// The specific timeline node for this verse.
  /// For example: "2024 甲辰" or "大运 戊戌".
  final String? temporalNodeText;

  /// Optional multi-version data. When non-null, overrides [verseText].
  final List<VerseVersion>? versions;

  const VerseRowData({
    required this.id,
    required this.watermark,
    required this.verseText,
    required this.tags,
    this.ageBadge,
    this.yearRange,
    required this.seal,
    required this.sealColor,
    required this.algorithm,
    this.subAlgorithm,
    this.description = '',
    this.temporalScope = TemporalScope.natal,
    this.temporalNodeText,
    this.versions,
  });
}

class VerticalVerseRow extends StatelessWidget {
  final String id;
  final String watermark;
  final List<VerseVersion> versions;
  final String algoName;
  final String? algoShortName;
  final List<String> tags;
  final List<String>? shortTags;
  final String? ageBadge;
  final String? yearRange;
  final String seal;
  final Color sealColor;
  final Color themeColor;
  final bool isTinyMode;
  final bool isFlipLayout;

  const VerticalVerseRow({
    super.key,
    required this.id,
    required this.watermark,
    required this.versions,
    required this.algoName,
    this.algoShortName,
    required this.tags,
    this.shortTags,
    this.ageBadge,
    this.yearRange,
    required this.seal,
    required this.sealColor,
    required this.themeColor,
    required this.isTinyMode,
    this.isFlipLayout = false,
  });

  static const _animDuration = Duration(milliseconds: 600);
  static const _animCurve = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context) {
    // Shared constants based on mode
    // Normal mode: Transparent background to blend with card, no shadow, no border.
    final cardBg = Colors.white;
    final cardRadius = isTinyMode ? 8.0 : 0.0;
    final cardShadow = isTinyMode
        ? const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ]
        : <BoxShadow>[];
    final cardBorder = null;

    final accentTop = isTinyMode ? 4.0 : (versions.length <= 1 ? 7.0 : 12.0);
    final accentBottom = isTinyMode ? 4.0 : (versions.length <= 1 ? 7.0 : 12.0);

    // Unified padding definition for animation
    final contentPadding = EdgeInsets.fromLTRB(
      28,
      isTinyMode ? 2 : (versions.length <= 1 ? 1 : 2),
      isTinyMode ? 12 : 20,
      isTinyMode ? 5 : (versions.length <= 1 ? 5 : 7),
    );

    return AnimatedContainer(
      duration: _animDuration,
      curve: _animCurve,
      margin: EdgeInsets.symmetric(
        vertical: isTinyMode ? 4 : 0,
        horizontal: 0, // Removed 12 -> 0 for width consistency
      ),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: cardShadow,
        border: cardBorder,
      ),
      child: Stack(
        children: [
          // 0. Watermark (Background)
          AnimatedPositioned(
            duration: _animDuration,
            curve: _animCurve,
            right: -10.5,
            bottom: -10.5,
            child: Opacity(
              opacity: 0.08,
              child: AnimatedDefaultTextStyle(
                duration: _animDuration,
                curve: _animCurve,
                style: TextStyle(
                  fontFamily: "Noto Serif SC",
                  fontSize: isTinyMode ? 28 : 42, // Reduced 42 -> 28 for Tiny
                  fontWeight: FontWeight.w900,
                  color: themeColor,
                  height: 1.0,
                ),
                child: Text(watermark),
              ),
            ),
          ),

          // 1. Accent Bar (Left)
          AnimatedPositioned(
            duration: _animDuration,
            curve: _animCurve,
            left: 10,
            top: accentTop,
            bottom: accentBottom,
            width: 3,
            child: Opacity(
              opacity: 0.8,
              child: Container(
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // 2. Main Content
          AnimatedPadding(
            duration: _animDuration,
            curve: _animCurve,
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Algo Name Badge (Hidden in Normal, Visible in Tiny)
                    // Use AnimatedSize + AnimatedOpacity to smoothly reveal
                    AnimatedSize(
                      duration: _animDuration,
                      curve: _animCurve,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: isTinyMode ? null : 0,
                        child: AnimatedOpacity(
                          duration: _animDuration,
                          curve: _animCurve,
                          opacity: isTinyMode ? 1.0 : 0.0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildAlgoNameTag(algoShortName ?? algoName),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          ...(shortTags ?? tags).map(
                            (t) => _buildSubTag(
                              t,
                              isTiny: isTinyMode,
                              key: ValueKey(t),
                            ),
                          ),

                          // Cross-fade between Age Capsule (Tiny) and Age Info Row (Normal)
                          // We use a Stack-like approach or just conditional rendering wrapped in AnimatedSize/Opacity
                          // But to be truly morphing, we render BOTH and cross-fade them, or smoothly transition one.
                          // Since they look very different, cross-fade is best.
                          if (ageBadge != null)
                            AnimatedSize(
                              duration: _animDuration,
                              curve: _animCurve,
                              alignment: Alignment.centerLeft,
                              child: isTinyMode
                                  ? _buildAgeCapsule(ageBadge!, isTiny: true)
                                  : _buildAgeInfoRow(),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),
                    _buildSealTag(
                      isTiny: isTinyMode,
                    ), // Pass isTiny to animate internal style
                  ],
                ),

                const SizedBox(height: 4),

                // Verse Content
                Builder(
                  builder: (context) {
                    final showSource = versions.length > 1;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: versions.map((v) {
                        return _buildVerseItem(
                          v,
                          showSource: showSource,
                          isTiny: isTinyMode,
                        );
                      }).toList(),
                    );
                  },
                ),

                if (!isTinyMode && versions.length > 1)
                  const SizedBox(height: 4),
              ],
            ),
          ),

          // 3. ID (Bottom Right)
          AnimatedPositioned(
            duration: _animDuration,
            curve: _animCurve,
            bottom: isTinyMode ? 4 : (versions.length <= 1 ? 2 : 4),
            right: 12,
            child: AnimatedDefaultTextStyle(
              duration: _animDuration,
              curve: _animCurve,
              style: TextStyle(
                fontFamily: "JetBrains Mono",
                fontSize: isTinyMode ? 11 : 9, // Increased 9 -> 11 for Tiny
                color: const Color(
                  0xFF424242,
                ).withOpacity(isTinyMode ? 0.7 : 0.6),
                fontWeight: FontWeight.bold,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedOpacity(
                    duration: _animDuration,
                    opacity: isTinyMode ? 0.0 : 1.0,
                    curve: _animCurve,
                    child: AnimatedClipRect(
                      open: !isTinyMode,
                      horizontal: true,
                      child: const Text("NO."),
                    ),
                  ),
                  Text(id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget AnimatedClipRect({
    required bool open,
    required Widget child,
    bool horizontal = true,
  }) {
    return AnimatedAlign(
      duration: _animDuration,
      curve: _animCurve,
      alignment: Alignment.centerLeft,
      widthFactor: open ? 1.0 : 0.0,
      heightFactor: 1.0,
      child: AnimatedOpacity(
        duration: _animDuration,
        curve: _animCurve,
        opacity: open ? 1.0 : 0.0,
        child: child,
      ),
    );
  }

  Widget _buildAgeInfoRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (ageBadge != null) _buildAgeCapsule(ageBadge!, isTiny: false),
        if (ageBadge != null && yearRange != null) const SizedBox(width: 8),
        if (yearRange != null)
          Text(
            "($yearRange)",
            style: TextStyle(
              color: const Color(0xFF967131).withOpacity(0.8),
              fontSize: 11,
              fontFamily: "JetBrains Mono",
            ),
          ),
      ],
    );
  }

  Widget _buildAgeCapsule(String text, {required bool isTiny}) {
    // Standardize to N1, N2 format (no parentheses)
    String display = text;
    final cleaned = display
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('-', ',')
        .replaceAll(' ', '');
    final parts = cleaned.split(',');
    if (parts.length >= 2) {
      display = "${parts[0]}, ${parts[1]}";
    } else {
      display = cleaned;
    }

    final fontSize = isTiny ? 9.0 : 11.0; // Matches Sub Tag
    final padding = isTiny
        ? const EdgeInsets.symmetric(vertical: 2, horizontal: 8)
        : const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 6,
          ); // Matches Sub Tag

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF967131).withOpacity(0.05),
        borderRadius: BorderRadius.circular(100), // Capsule shape
        border: Border.all(
          color: const Color(0xFF967131).withOpacity(0.3),
          width: 0.6, // Matches Sub Tag (0.6)
        ),
      ),
      child: Text(
        display,
        style: TextStyle(
          color: const Color(0xFF967131),
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
          fontFamily: "JetBrains Mono",
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildVerseItem(
    VerseVersion version, {
    required bool showSource,
    bool isTiny = false,
  }) {
    final isPrimary = showSource && version.isPrimary;

    // Left border color: distinct if showSource is true, else transparent.
    final borderColor = isPrimary
        ? const Color(0xFFA62B1F)
        : (showSource ? const Color(0xFFBDBDBD) : Colors.transparent);

    // Background tint: from base_18.html screenshot
    final backgroundColor = showSource
        ? (isPrimary
              ? const Color(0xFFA62B1F).withOpacity(0.04)
              : const Color(0xFF000000).withOpacity(0.03))
        : Colors.transparent;

    final fontSize = isTiny ? 17.0 : 19.0;

    return AnimatedContainer(
      duration: _animDuration,
      curve: _animCurve,
      margin: showSource
          ? EdgeInsets.only(bottom: isTiny ? 2 : 8) // Further reduced 4 -> 2
          : EdgeInsets.zero,
      padding: showSource
          ? EdgeInsets.symmetric(
              horizontal: 12,
              vertical: isTiny ? 2 : 8,
            ) // Further reduced 4 -> 2
          : EdgeInsets.symmetric(
              vertical: isTiny ? 0 : 2,
            ), // Reduced 2 -> 0 for Tiny
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: showSource
            ? Border(left: BorderSide(width: 3, color: borderColor))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source Badge - Only show if we distinguish sources
          if (showSource) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: _animDuration,
                  curve: _animCurve,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    border: Border.all(
                      color: isPrimary
                          ? const Color(0xFFA62B1F)
                          : const Color(0xFF757575),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    version.source,
                    style: TextStyle(
                      fontSize: 10,
                      color: isPrimary
                          ? const Color(0xFFA62B1F)
                          : const Color(0xFF757575),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (version.ageBadge != null) ...[
                  const SizedBox(height: 4),
                  _buildAgeCapsule(version.ageBadge!, isTiny: true),
                ],
              ],
            ),
            const SizedBox(width: 12),
          ] else if (version.ageBadge != null) ...[
            // Show age capsule even if source naming is hidden (e.g. single version with specific age)
            _buildAgeCapsule(version.ageBadge!, isTiny: isTiny),
            const SizedBox(width: 12),
          ],

          // Verse Content
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: _animDuration,
              curve: _animCurve,
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: "Songti SC",
                height: isTiny ? 1.3 : 1.5, // Reduced line height for Tiny
                color: const Color(0xFF2B2B2B),
                letterSpacing: 0.5,
              ),
              child: Text(version.content),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tag Helpers — visually distinct by category
  // ---------------------------------------------------------------------------

  /// Source tag (年支, 月支, etc.) — outlined style with themeColor tint.
  /// Source tag (年支, 月支, etc.) — outlined style with themeColor tint.
  Widget _buildSubTag(String text, {required bool isTiny, Key? key}) {
    final fontSize = isTiny
        ? 9.0
        : 11.0; // Normal matches Age Tag (11), Tiny stays 9
    final padding = isTiny
        ? const EdgeInsets.symmetric(vertical: 2, horizontal: 8)
        : const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 6,
          ); // Normal matches Age Tag padding (6)

    return AnimatedContainer(
      key: key,
      duration: _animDuration,
      curve: _animCurve,
      padding: padding,
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.04), // Reduced opacity 0.08 -> 0.04
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: themeColor.withOpacity(0.15), // Reduced 0.2 -> 0.15
          width: 0.6, // Reduced 0.8 -> 0.6
        ),
      ),
      child: AnimatedDefaultTextStyle(
        duration: _animDuration,
        curve: _animCurve,
        style: TextStyle(
          fontSize: fontSize,
          color: themeColor,
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
        child: Text(text),
      ),
    );
  }

  /// Seal tag — 26×26 (normal) or 14×14 (tiny), centered text in colored box.
  /// Seal tag
  Widget _buildSealTag({required bool isTiny}) {
    if (isTiny) {
      return Container(
        width: 12, // Reduced 14 -> 12
        height: 12, // Reduced 14 -> 12
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: sealColor, width: 0.6), // Thinner border
          color: sealColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(1.5),
        ),
        child: FittedBox(
          child: Text(
            seal,
            style: TextStyle(
              color: sealColor,
              fontSize: 6, // Reduced 8 -> 6
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
        ),
      );
    }

    // Normal mode seal - Flat boxed style
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: sealColor.withOpacity(0.5), width: 0.8),
        color: sealColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        seal,
        style: TextStyle(
          color: sealColor.withOpacity(0.7),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildAlgoNameTag(String text, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF462A5A), // Dark purple from screenshot
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9, // Reduced 11 -> 9
          color: Colors.white,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
    );
  }
}
