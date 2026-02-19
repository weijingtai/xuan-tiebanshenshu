import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'vertical_verse_row.dart'; // Reuse VerseVersion model

/// A verse row widget driven by an explicit animation value [animationValue].
///
/// `animationValue` ranges from 0.0 (Normal/expanded) to 1.0 (Tiny/collapsed).
/// All visual properties are computed from this single `t` value,
/// ensuring perfectly synchronized transitions with the parent card.
///
/// ```
/// Container (shell — border-radius, shadow driven by t)
///   └── Stack
///       ├── Watermark (bottom-right, fontSize driven by t)
///       ├── Accent Bar (position driven by t)
///       ├── Content Padding (driven by t)
///       │     ├── Header Row (algo tag widthFactor=t, tags, seal)
///       │     └── Verse Content (fontSize, lineHeight driven by t)
///       └── Footer (position, "NO." opacity driven by t)
/// ```
class HorizontalTiaoWenWidget extends StatelessWidget {
  final String id;
  final String watermark;
  final List<VerseVersion> versions;
  final String algoName;
  final String? algoShortName;
  final List<String> tags;
  final String? ageBadge;
  final String? yearRange;
  final String? seal;
  final Color sealColor;
  final Color themeColor;
  final bool isTinyMode;
  final bool useThemeColorForSeal;

  /// Animation progress: 0.0 = Normal, 1.0 = Tiny.
  /// When null, snaps to 0.0 or 1.0 based on [isTinyMode].
  final double? animationValue;

  const HorizontalTiaoWenWidget({
    super.key,
    required this.id,
    required this.watermark,
    required this.versions,
    required this.algoName,
    this.algoShortName,
    required this.tags,
    this.ageBadge,
    this.yearRange,
    this.seal,
    required this.sealColor,
    required this.themeColor,
    this.isTinyMode = false,
    this.useThemeColorForSeal = false,
    this.animationValue,
  });

  // ───────────────────────── Constants ─────────────────────────
  static const Color ageThemeColor = Color(0xFF967131);

  /// Effective animation value — uses [animationValue] if provided,
  /// otherwise snaps based on [isTinyMode].
  double get _t => animationValue ?? (isTinyMode ? 1.0 : 0.0);

  @override
  Widget build(BuildContext context) {
    final t = _t;

    // ── Shell properties ──
    final cardRadius = lerpDouble(0.0, 8.0, t)!;
    final shadowAlpha = (0x1A * t).round();
    final topPadding = lerpDouble(8.0, 7.0, t)!;
    final bottomPadding = lerpDouble(4.0, 6.0, t)!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          if (shadowAlpha > 0)
            BoxShadow(
              color: Color.fromARGB(shadowAlpha, 0, 0, 0),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Stack(
        children: [
          // ── 0. Watermark ──
          Positioned(
            right: -10.5,
            bottom: -4.0,
            child: Opacity(
              opacity: 0.08,
              child: Text(
                watermark,
                style: TextStyle(
                  fontFamily: "Noto Serif SC",
                  fontSize: lerpDouble(36, 28, t)!,
                  fontWeight: FontWeight.w900,
                  color: themeColor.withAlpha(120),
                  height: 1.0,
                ),
              ),
            ),
          ),

          // ── 1. Accent Left Bar ──
          Positioned(
            left: 10,
            top: lerpDouble(7, 6, t)!,
            bottom: lerpDouble(7, 6, t)!,
            width: 3.0,
            child: Container(
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── 2. Content ──
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, topPadding, 12.0, bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _buildHeaderRow(t: t),
                ),
                const SizedBox(height: 2),
                _buildVerseContent(t: t),
              ],
            ),
          ),

          // ── 3. Footer ──
          _buildFooterRow(t: t),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 上: Header Row — Tags(left) + Spacer + Seal(right)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeaderRow({required double t}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Group: AlgoName + Tags
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Algorithm Name Tag (Hidden in Normal, Visible in Tiny)
            // Slides in from left via widthFactor = t
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: t,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildAlgoNameTag(algoShortName ?? algoName),
                ),
              ),
            ),

            // Tags
            ...tags.map(
              (tag) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildSubTag(tag, t: t),
              ),
            ),

            // Age Badge
            if (ageBadge != null) _buildAgeInfoRow(t: t),
          ],
        ),

        // Right Group: Seal Tag
        _buildSealTag(t: t),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 中: Verse Content
  // ═══════════════════════════════════════════════════════════════

  Widget _buildVerseContent({required double t}) {
    final showSource = versions.length > 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: versions.map((v) {
        return _buildVerseItem(v, showSource: showSource, t: t);
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 下: Footer — ID number right-aligned
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFooterRow({required double t}) {
    final normalFactor = 1.0 - t;
    final idFontSize = lerpDouble(9, 10, t)!;
    final footerBottom = lerpDouble(2, 4, t)!;
    final baseAlpha = lerpDouble(0.6, 0.7, t)!;
    final noFontSize = lerpDouble(9.0, 0.0, t)!;
    final noSpacing = lerpDouble(2.0, 0.0, t)!;

    return Positioned(
      bottom: footerBottom,
      right: 6,
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: "JetBrains Mono",
          fontSize: idFontSize,
          color: const Color(0xFF424242).withValues(alpha: baseAlpha),
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // "NO." prefix — shrinks to 0 in Tiny mode
            Opacity(
              opacity: normalFactor,
              child: Text(
                "NO.",
                style: TextStyle(
                  fontFamily: "JetBrains Mono",
                  fontSize: noFontSize,
                  color: const Color(
                    0xFF424242,
                  ).withValues(alpha: lerpDouble(0.6, 0.0, t)!),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: noSpacing),
            Text(id),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Verse Item
  // ═══════════════════════════════════════════════════════════════

  Widget _buildVerseItem(
    VerseVersion version, {
    required bool showSource,
    required double t,
  }) {
    final isPrimary = showSource && version.isPrimary;

    final borderColor = isPrimary
        ? const Color(0xFFA62B1F)
        : (showSource ? const Color(0xFFBDBDBD) : Colors.transparent);

    final fontSize = lerpDouble(19.0, 17.0, t)!;
    final lineHeight = lerpDouble(1.3, 1.15, t)!;
    final itemMarginBottom = showSource ? lerpDouble(8.0, 4.0, t)! : 0.0;
    final vertPadding = showSource
        ? lerpDouble(6.0, 2.0, t)!
        : lerpDouble(4.0, 2.0, t)!;
    final horzPadLeft = 8.0;
    final horzPadRight = showSource ? 12.0 : 8.0;

    return Container(
      margin: showSource
          ? EdgeInsets.only(bottom: itemMarginBottom)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: showSource
            ? LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  (isPrimary
                          ? const Color(0xFFA62B1F)
                          : const Color(0xFFFBF8F5))
                      .withValues(alpha: 0.0),
                  (isPrimary
                          ? const Color(0xFFA62B1F)
                          : const Color(0xFFFBF8F5))
                      .withValues(alpha: isPrimary ? 0.15 : 0.6),
                ],
                stops: const [0.0, 1.0],
              )
            : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horzPadLeft,
                  vertPadding,
                  horzPadRight,
                  vertPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verse header — cross-fades between Normal and Tiny content
                    _buildVerseItemHeader(
                      version: version,
                      showSource: showSource,
                      borderColor: borderColor,
                      t: t,
                    ),
                    // Verse text
                    Expanded(
                      child: Text(
                        version.content,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontFamily: "Songti SC",
                          height: lineHeight,
                          color: const Color(0xFF2B2B2B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header section of each verse item.
  /// In Normal mode: shows source label + age badge + spacing.
  /// In Tiny mode: shows only age text (if available).
  /// Cross-fades using heightFactor driven by [t].
  Widget _buildVerseItemHeader({
    required VerseVersion version,
    required bool showSource,
    required Color borderColor,
    required double t,
  }) {
    final normalFactor = 1.0 - t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Normal-mode header: source label + inline age badge — collapses via heightFactor
        if (showSource)
          ClipRect(
            child: Align(
              alignment: Alignment.topLeft,
              heightFactor: normalFactor,
              child: Opacity(
                opacity: normalFactor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: borderColor.withAlpha(80),
                            border: Border.all(
                              color: borderColor.withAlpha(120),
                              width: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            version.source,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: "Songti SC",
                              color: borderColor.withAlpha(200),
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                        ),
                        if (version.ageBadge != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            "(${version.ageBadge?.replaceAll('(', '').replaceAll(')', '')})",
                            style: const TextStyle(
                              fontSize: 9,
                              color: ageThemeColor,
                              fontFamily: "JetBrains Mono",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),

        // Tiny-mode header: just age text — expands via heightFactor
        if (version.ageBadge != null)
          ClipRect(
            child: Align(
              alignment: Alignment.topLeft,
              heightFactor: showSource
                  ? t
                  : 0.0, // Only show if we had a normal header
              child: Opacity(
                opacity: showSource ? t : 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "(${version.ageBadge?.replaceAll('(', '').replaceAll(')', '')})",
                      style: TextStyle(
                        fontSize: 10,
                        color: ageThemeColor.withValues(alpha: 0.8),
                        fontFamily: "JetBrains Mono",
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: lerpDouble(4, 2, t)!),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Tag Helpers — all driven by t
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSubTag(String text, {required double t}) {
    final opacityFactor = lerpDouble(1.0, 0.8, t)!;
    final fontSize = lerpDouble(11.0, 9.0, t)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.04 * opacityFactor),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.15 * opacityFactor),
          width: 0.6,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: themeColor.withValues(alpha: opacityFactor),
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildAgeCapsule(String text, {required double t}) {
    String display = text
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('-', ',')
        .replaceAll(' ', '');
    final parts = display.split(',');
    if (parts.length >= 2) {
      display = "${parts[0]}, ${parts[1]}";
    }

    final fontSize = lerpDouble(11.0, 9.0, t)!;
    final opacityFactor = lerpDouble(1.0, 0.8, t)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 4),
      decoration: BoxDecoration(
        color: ageThemeColor.withValues(alpha: 0.04 * opacityFactor),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: ageThemeColor.withValues(alpha: 0.25 * opacityFactor),
          width: 0.5,
        ),
      ),
      child: Text(
        display,
        style: TextStyle(
          color: ageThemeColor.withValues(alpha: opacityFactor),
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
          fontFamily: "JetBrains Mono",
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildAgeInfoRow({required double t}) {
    final normalFactor = 1.0 - t;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (ageBadge != null) _buildAgeCapsule(ageBadge!, t: t),
        if (ageBadge != null && yearRange != null)
          ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: normalFactor,
              child: Opacity(
                opacity: normalFactor,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      "($yearRange)",
                      style: TextStyle(
                        color: const Color(0xFF967131).withValues(alpha: 0.8),
                        fontSize: 11,
                        fontFamily: "JetBrains Mono",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSealTag({required double t}) {
    if (seal == null) return const SizedBox.shrink();

    final baseColor = useThemeColorForSeal ? themeColor : sealColor;
    final opacityFactor = lerpDouble(1.0, 0.8, t)!;
    final fontSize = lerpDouble(12.0, 10.0, t)!;
    final hPad = lerpDouble(6.0, 4.0, t)!;
    final vPad = lerpDouble(2.0, 1.0, t)!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        border: Border.all(
          color: baseColor.withValues(alpha: 0.5 * opacityFactor),
          width: 0.8,
        ),
        color: baseColor.withValues(alpha: 0.05 * opacityFactor),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        seal!,
        style: TextStyle(
          color: baseColor.withValues(alpha: 0.7 * opacityFactor),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildAlgoNameTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF462A5A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
    );
  }
}
