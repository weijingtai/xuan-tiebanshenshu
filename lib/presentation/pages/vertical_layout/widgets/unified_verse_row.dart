import 'package:flutter/material.dart';
import '../models/base_18_models.dart';

class UnifiedVerseRow extends StatelessWidget {
  final VerseData data;
  final Color themeColor;
  final bool isTinyMode;
  final String? algoName;

  const UnifiedVerseRow({
    super.key,
    required this.data,
    required this.themeColor,
    required this.isTinyMode,
    this.algoName,
  });

  @override
  Widget build(BuildContext context) {
    // Determine height constraint: Normal ~120+, Tiny ~48+.
    // We use AnimatedContainer for the background and border.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isTinyMode ? 48 : 120),
      margin: const EdgeInsets.symmetric(vertical: 0),
      // Tiny mode has specific padding/margin behavior in CSS, but here we adjust internal padding.
      decoration: BoxDecoration(
        color: Base18Theme.paper,
        border: Border(
          // HTML: expanded has border-bottom dashed. tiny has border solid (faint).
          bottom: BorderSide(
            color: isTinyMode
                ? Colors.black.withOpacity(0.02)
                : const Color.fromRGBO(
                    0,
                    0,
                    0,
                    0.05,
                  ), // dashed logic handled elsewhere or simplified
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        borderRadius: isTinyMode ? BorderRadius.circular(6) : BorderRadius.zero,
        boxShadow: isTinyMode
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // 1. Watermark (Fades out and moves)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: isTinyMode ? -8 : -10,
            bottom: isTinyMode ? -12 : -5,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isTinyMode ? 0.05 : 0.08, // Subtle in tiny
              child: Transform.rotate(
                angle: -0.2, // Check CSS: rotate? No, just styling.
                child: Text(
                  data.watermark,
                  style: TextStyle(
                    fontFamily: "Noto Serif SC",
                    fontWeight: FontWeight.w900,
                    fontSize: isTinyMode
                        ? 32
                        : 100, // CSS: 32 vs 42 (actually 100 in my previous code)
                    color: Base18Theme.taixuanRed,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),

          // 2. Left Accent Line (Position Consistent)
          // CSS: Normal (left 10, top 18), Tiny (top 10). Left doesn't change!
          // Widget: We use 'left: 0' and 'margin-left: fixed'.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            top: isTinyMode ? 10 : 18,
            bottom: isTinyMode ? 10 : 18,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 3, // CSS says 3px
              margin: const EdgeInsets.only(left: 10), // Constant 10px margin
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 3. Algorithm Tag (Slide/Expand to Appear)
          // CSS: Normal: max-width 0. Tiny: max-width 120.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 18, // 10px + 3px + gap? CSS says content margin-left 18/8.
            // In Tiny, content margin left is 8.
            // But Algo tag is inside meta-left.
            // Let's position it simply at top left of content area.
            top: isTinyMode ? 8 : 18,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: isTinyMode ? 120 : 0, // Expand width
              height: isTinyMode ? null : 0,
              padding: isTinyMode
                  ? const EdgeInsets.symmetric(horizontal: 5, vertical: 1)
                  : EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                algoName ?? "",
                maxLines: 1,
                overflow: TextOverflow.clip,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ),

          // 4. Seal (Fades/Moves)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: isTinyMode ? 6 : 18,
            right: isTinyMode ? 10 : 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: isTinyMode
                  ? const EdgeInsets.symmetric(horizontal: 3, vertical: 1)
                  : const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              decoration: BoxDecoration(
                color: data.sealColor.withOpacity(0.05),
                border: Border.all(
                  color: data.sealColor,
                  width: isTinyMode ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                data.seal,
                style: TextStyle(
                  fontSize: isTinyMode ? 11 : 10.5,
                  fontWeight: FontWeight.bold,
                  color: data.sealColor,
                ),
              ),
            ),
          ),

          // 5. ID Badge (Bottom Right)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: isTinyMode ? 10 : 12,
            bottom: isTinyMode ? 6 : 10,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isTinyMode ? 1.0 : 0.6,
              child: Text(
                "NO.${data.id}",
                style: TextStyle(
                  fontFamily: "JetBrains Mono",
                  fontSize: 9, // CSS: 9px
                  fontWeight: FontWeight.bold,
                  color: Base18Theme.idTextColor,
                  letterSpacing: isTinyMode ? 0.5 : 1,
                ),
              ),
            ),
          ),

          // 6. Main Content Area
          AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            // CSS: Normal padding 18px 20px. Tiny padding 6px 12px.
            // Plus content-wrap margin-left: Normal 18, Tiny 8.
            // Total left padding: Normal 20+18=38? No, CSS says 18px on row, then content-wrap margin 18.
            // Logic: Left Accent is absolute. Content is flex.
            padding: isTinyMode
                ? const EdgeInsets.fromLTRB(
                    20,
                    24,
                    40,
                    6,
                  ) // Left=12+8=20. Top increased for Algo Tag?
                : const EdgeInsets.fromLTRB(38, 18, 20, 18), // Left=20+18=38.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tags Row (Month/Age) - Collapse in Tiny
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  alignment: Alignment.topLeft,
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    height: isTinyMode ? 0 : null,
                    width: isTinyMode ? 0 : null, // Collapse width too?
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isTinyMode ? 0.0 : 1.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Placeholder for Algo name if desired in Normal, but CSS hides it.
                              // Just Month/Age
                              ...data.tags.map((t) => _buildStyledTag(t)),
                            ],
                          ),
                          const SizedBox(height: 6), // Gap
                        ],
                      ),
                    ),
                  ),
                ),

                // Verse Text or Versions
                // Fixed: Removed Expanded to prevent layout issues
                if (data.versions != null && data.versions!.isNotEmpty)
                  _buildAnimatedVersions(data.versions!)
                else
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontFamily: "Songti SC",
                      fontSize: isTinyMode ? 15 : 16.5,
                      height: isTinyMode ? 1.4 : 1.6,
                      fontWeight: FontWeight.w500,
                      color: Base18Theme.inkText,
                    ),
                    child: Text(
                      data.text,
                    ), // Text inside Column inside AnimatedContainer is safe
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTag(String text) {
    bool isMonth = text.contains("月") || text.endsWith("支");
    bool isAge = text.contains("岁") || RegExp(r'\d{4}').hasMatch(text);

    Color tagColor = themeColor;
    // Helper for mixing colors (simplified)
    // CSS uses logic based on themeColor... we assume themeColor passed is correct (Purple/Red/Green)

    if (isMonth) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: Color.lerp(tagColor, Colors.white, 0.92), // mix 8%
          border: Border.all(color: tagColor.withOpacity(0.12), width: 0.5),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: tagColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (isAge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(150, 113, 49, 0.08),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF967131),
            fontSize: 11,
            fontFamily: "JetBrains Mono",
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Color.lerp(tagColor, Colors.white, 0.92),
        border: Border.all(color: tagColor.withOpacity(0.12), width: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: tagColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAnimatedVersions(List<VerseVersion> versions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: versions.map((v) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(
            bottom: isTinyMode ? 2 : 4,
          ), // Reduced Tiny gap
          padding: isTinyMode
              ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (v.isPrimary && !isTinyMode)
                ? Base18Theme.taixuanRed.withOpacity(0.04)
                : Colors.transparent, // Tiny: Transparent bg? CSS says so?
            // CSS: .mode-tiny .version-row { padding: 2px 4px }
            border: Border(
              left: BorderSide(
                color: v.isPrimary
                    ? Base18Theme.taixuanRed
                    : Colors.grey, // Assuming all non-primary are secondary
                width: isTinyMode
                    ? 0
                    : 2, // Tiny border likely smaller or removed?
                // CSS: .version-row { border-left: ... } .mode-tiny ... (no override implies keeps border?)
                // Actually CSS line 625 just says padding change.
                // But effectively let's keep it simple.
              ),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source Tag
              Container(
                margin: const EdgeInsets.only(right: 6, top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                constraints: const BoxConstraints(minWidth: 32),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: v.isPrimary
                        ? Base18Theme.taixuanRed
                        : const Color.fromRGBO(0, 0, 0, 0.15),
                    width: 0.5,
                  ),
                  color: v.isPrimary
                      ? const Color.fromRGBO(166, 43, 31, 0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  v.source,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: v.isPrimary
                        ? Base18Theme.taixuanRed
                        : const Color(0xFF757575),
                  ),
                ),
              ),
              // Content - Use Flexible/Expanded here IS okay because Row is inside Column
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontFamily: "Songti SC",
                    fontSize: isTinyMode ? 13 : 15, // CSS: 13 vs 15
                    height: 1.5,
                    color: Base18Theme.inkText,
                  ),
                  child: Text(v.content),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
