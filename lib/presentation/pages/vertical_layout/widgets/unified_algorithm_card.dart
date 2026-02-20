import 'package:flutter/material.dart';
import '../models/base_18_models.dart';
import 'unified_verse_row.dart';

class UnifiedAlgorithmCard extends StatelessWidget {
  final String title;
  final String formula;
  final Color themeColor;
  final bool isTinyMode;
  final List<VerseData> verses;

  const UnifiedAlgorithmCard({
    super.key,
    required this.title,
    required this.formula,
    required this.themeColor,
    required this.isTinyMode,
    required this.verses,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Head (Hidden in Tiny Mode)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: isTinyMode ? 0 : null,
              child: Opacity(opacity: isTinyMode ? 0 : 1, child: _buildHead()),
            ),
          ),

          // Body (Animate gap/padding if needed, though mostly handled by VerseRow)
          _buildBody(),

          // Foot (Hidden in Tiny Mode)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: isTinyMode ? 0 : null,
              child: Opacity(opacity: isTinyMode ? 0 : 1, child: _buildFoot()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHead() {
    return Container(
      height: 64, // Increased height for stacked layout
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Songti SC",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15), // Darker capsule
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  formula,
                  style: TextStyle(
                    fontFamily: Base18Theme.fontMono.first,
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          // Optional: Add close/minimize button if needed, but not in spec.
          // For now just the centered content.
        ],
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: isTinyMode
          ? const EdgeInsets.all(0)
          : const EdgeInsets.symmetric(vertical: 2),
      // decoration: Remove border as VerseRow handles the accent line now
      child: Column(
        children: [
          // Removed card-level Tiny Mode Label to avoid duplication with VerseRow tag

          // Verses
          ...verses.asMap().entries.map((entry) {
            final index = entry.key;
            final verse = entry.value;
            // Create a gap between verses in Tiny Mode
            return Column(
              children: [
                UnifiedVerseRow(
                  data: verse,
                  themeColor: themeColor,
                  isTinyMode: isTinyMode,
                  algoName: title, // Pass full title for "Algo + SubAlgo"
                ),
                // Gap in Tiny Mode (CSS: gap: 8px)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isTinyMode && index < verses.length - 1 ? 8.0 : 0.0,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFoot() {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
