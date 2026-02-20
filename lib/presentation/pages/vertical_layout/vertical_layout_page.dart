import 'package:flutter/material.dart';
import 'widgets/vertical_algorithm_card.dart';
import 'widgets/vertical_verse_row.dart';

class VerticalLayoutPage extends StatefulWidget {
  const VerticalLayoutPage({super.key});

  @override
  State<VerticalLayoutPage> createState() => _VerticalLayoutPageState();
}

class _VerticalLayoutPageState extends State<VerticalLayoutPage> {
  bool _isTinyMode = false;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _cardKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  // Theme colors from HTML :root
  static const _huangjiPurple = Color(0xFF462A5A);
  static const _taixuanRed = Color(0xFF8B1E15);
  static const _heluoGreen = Color(0xFF145A32);

  // Seal colors from HTML
  static const _sealGreatGood = Color(0xFF1B5E20);
  static const _sealGood = Color(0xFF43A047);
  static const _sealNeutral = Color(0xFF5D4037);
  static const _sealBad = Color(0xFFC62828);

  void _scrollToIndex(int index) {
    final context = _cardKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        alignment: 0.5,
      );
    }
  }

  void _toggleTinyMode() {
    setState(() {
      _isTinyMode = !_isTinyMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE6E2D3);
    const tinyBgColor = Color(0xFFF0F0F0);

    return Scaffold(
      backgroundColor: _isTinyMode ? tinyBgColor : bgColor,
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: _isTinyMode ? tinyBgColor : bgColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNavTopBar(),
                Expanded(
                  child: ListView(
                    padding: _isTinyMode
                        ? const EdgeInsets.only(left: 20, top: 60)
                        : const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 40,
                          ),
                    scrollDirection: Axis.vertical, // Changed to vertical
                    controller: _scrollController,
                    children: _buildCardsList(),
                  ),
                ),
              ],
            ),
          ),

          // Controls
          Positioned(
            top: 15,
            right: 20,
            child: Row(
              children: [
                _buildControlButton(label: "≣ 极简模式", onTap: _toggleTinyMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCardsList() {
    // 1. Define all verses in a flat list with metadata
    final allVerses = [
      // 皇极经世 · 方案一
      const VerseRowData(
        id: "1245",
        watermark: "壹貳肆伍",
        verseText: "宏图大展在此时，四海昇平见太平。",
        tags: ["年支"],
        ageBadge: "(44,45)",
        yearRange: "2044,2045",
        seal: "大吉",
        sealColor: _sealGreatGood,
        algorithm: "皇极经世",
        subAlgorithm: "方案一",
        description: "(年干 × 12 + 月支) ÷ 360",
      ),
      const VerseRowData(
        id: "3870",
        watermark: "叁捌柒零",
        verseText: "亢龙有悔，盈不可久。",
        tags: ["月支"],
        ageBadge: "(24)",
        yearRange: "2024",
        seal: "中平",
        sealColor: _sealNeutral,
        algorithm: "皇极经世",
        subAlgorithm: "方案一",
        description: "(年干 × 12 + 月支) ÷ 360",
      ),
      const VerseRowData(
        id: "5432",
        watermark: "伍肆叁貳",
        verseText: "时来天地皆同力，运去英雄不自由。",
        tags: ["月支"],
        ageBadge: "(31,32)",
        yearRange: "2031,2032",
        seal: "吉",
        sealColor: _sealGood,
        algorithm: "皇极经世",
        subAlgorithm: "方案一",
        description: "(年干 × 12 + 月支) ÷ 360",
      ),
      const VerseRowData(
        id: "9108",
        watermark: "玖壹零捌",
        verseText: "梅花香自苦寒来，宝剑锋从磨砺出。",
        tags: ["月支"],
        ageBadge: "甲辰",
        seal: "大吉",
        sealColor: _sealGreatGood,
        algorithm: "皇极经世",
        subAlgorithm: "方案一",
        description: "(年干 × 12 + 月支) ÷ 360",
      ),

      // 皇极经世 · 方案二
      const VerseRowData(
        id: "8912",
        watermark: "捌玖壹貳",
        verseText: "云深不知处，静待有缘人。",
        tags: ["值年"],
        ageBadge: "(25)",
        yearRange: "2025",
        seal: "平",
        sealColor: _sealNeutral,
        algorithm: "皇极经世",
        subAlgorithm: "方案二",
        description: "(值年卦 × 卦象) % 384",
      ),
      const VerseRowData(
        id: "2234",
        watermark: "貳貳叁肆",
        verseText: "石中藏美玉，淘沙见真金。",
        tags: ["卦象"],
        ageBadge: "(41,42)",
        yearRange: "2041,2042",
        seal: "小凶",
        sealColor: _sealBad,
        algorithm: "皇极经世",
        subAlgorithm: "方案二",
        description: "(值年卦 × 卦象) % 384",
      ),
      const VerseRowData(
        id: "11567",
        watermark: "壹万壹貳",
        verseText: "进德修业，水到渠成。",
        tags: ["月支"],
        seal: "中平",
        sealColor: _sealNeutral,
        algorithm: "皇极经世",
        subAlgorithm: "方案二",
        description: "(值年卦 × 卦象) % 384",
      ),
      const VerseRowData(
        id: "4567",
        watermark: "肆伍陸柒",
        verseText: "海阔凭鱼跃，天高任鸟飞。",
        tags: ["月支"],
        seal: "小吉",
        sealColor: _sealGood,
        algorithm: "皇极经世",
        subAlgorithm: "方案二",
        description: "(值年卦 × 卦象) % 384",
      ),

      // 太玄数 · 方案一
      const VerseRowData(
        id: "5621",
        watermark: "伍陸貳壹",
        verseText: "命有定数，运有变数。",
        tags: ["先天"],
        ageBadge: "(27,28)",
        yearRange: "2027,2028",
        seal: "小吉",
        sealColor: _sealGood,
        algorithm: "太玄数",
        subAlgorithm: "方案一",
        description: "(先天 + 后天) % 12 + 1000",
      ),
      const VerseRowData(
        id: "10452",
        watermark: "壹万零肆",
        verseText: "风雨袭来莫惊慌，定心坐禅避祸殃。",
        tags: ["后天"],
        ageBadge: "庚寅",
        seal: "凶",
        sealColor: _sealBad,
        algorithm: "太玄数",
        subAlgorithm: "方案一",
        description: "(先天 + 后天) % 12 + 1000",
      ),
      const VerseRowData(
        id: "7890",
        watermark: "柒捌玖零",
        verseText: "山重水复疑无路，柳暗花明又一村。",
        tags: ["月支"],
        seal: "凶",
        sealColor: _sealBad,
        algorithm: "太玄数",
        subAlgorithm: "方案一",
        description: "(先天 + 后天) % 12 + 1000",
      ),
      const VerseRowData(
        id: "1234",
        watermark: "壹貳叁肆",
        verseText: "读书破万卷，下笔如有神。",
        tags: ["月支"],
        seal: "吉",
        sealColor: _sealGood,
        algorithm: "太玄数",
        subAlgorithm: "方案一",
        description: "(先天 + 后天) % 12 + 1000",
      ),

      // 河洛数
      const VerseRowData(
        id: "12891",
        watermark: "壹万貳捌",
        verseText: "龙腾四海势不凡，功成名就指日看。",
        tags: ["乾元"],
        ageBadge: "(23,24)",
        yearRange: "2023,2024",
        seal: "大吉",
        sealColor: _sealGreatGood,
        algorithm: "河洛数",
        subAlgorithm: "理数",
        description: "(天地总数 - 阳数) % 384",
      ),
      const VerseRowData(
        id: "3344",
        watermark: "叁叁肆肆",
        verseText: "春江水暖鸭先知，细察秋毫得先机。",
        tags: ["坤贞"],
        seal: "吉",
        sealColor: _sealGood,
        algorithm: "河洛数",
        subAlgorithm: "理数",
        description: "(天地总数 - 阳数) % 384",
      ),
      const VerseRowData(
        id: "7788",
        watermark: "柒柒捌捌",
        verseText: "千里之行，始于足下。",
        tags: ["月支"],
        seal: "平",
        sealColor: _sealNeutral,
        algorithm: "河洛数",
        subAlgorithm: "理数",
        description: "(天地总数 - 阳数) % 384",
      ),
      const VerseRowData(
        id: "11223",
        watermark: "壹万壹貳",
        verseText: "宁静致远，淡泊明志。",
        tags: ["月支"],
        seal: "小吉",
        sealColor: _sealGood,
        algorithm: "河洛数",
        subAlgorithm: "理数",
        description: "(天地总数 - 阳数) % 384",
      ),
    ];

    // 2. Group verses by Algo + SubAlgo
    final Map<String, List<VerseRowData>> groupedVerses = {};
    for (var verse in allVerses) {
      final key = "${verse.algorithm}|${verse.subAlgorithm}";
      if (!groupedVerses.containsKey(key)) {
        groupedVerses[key] = [];
      }
      groupedVerses[key]!.add(verse);
    }

    // 3. Build Card Widgets
    final cardWidgets = <Widget>[];
    int index = 0;

    groupedVerses.forEach((key, verses) {
      final parts = key.split('|');
      final algo = parts[0];
      final subAlgo = parts[1];
      final description =
          verses.first.description; // Use description from first verse

      // Determine colors based on Algorithm
      Color themeColor;
      if (algo.contains("皇极")) {
        themeColor = _huangjiPurple;
      } else if (algo.contains("太玄")) {
        themeColor = _taixuanRed;
      } else if (algo.contains("河洛")) {
        themeColor = _heluoGreen;
      } else {
        themeColor = Colors.blueGrey;
      }

      String addSpaces(String text) {
        return text.split('').join(' ');
      }

      cardWidgets.add(
        VerticalAlgorithmCard(
          key: index < _cardKeys.length
              ? _cardKeys[index]
              : GlobalKey(), // Reuse keys if available
          title: "${addSpaces(algo)} · ${addSpaces(subAlgo)}",
          formula: description,
          themeColor: themeColor,
          isTinyMode: _isTinyMode,
          isFlipLayout: false,
          verses: verses,
        ),
      );
      index++;
    });

    // 4. Add spacers (Normal mode only)
    if (_isTinyMode) {
      return cardWidgets;
    }

    final result = <Widget>[];
    for (int i = 0; i < cardWidgets.length; i++) {
      if (i > 0)
        result.add(const SizedBox(height: 32)); // Changed width to height
      result.add(cardWidgets[i]);
    }
    return result;
  }

  Widget _buildNavTopBar() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isTinyMode ? 0.5 : 1.0,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Nav dots match HTML: 皇极 -> card 0, 太玄 -> card 2, 河洛 -> card 3
            _buildNavDot("皇极经世", _huangjiPurple, 0),
            const SizedBox(width: 16),
            _buildNavDot("太玄数", _taixuanRed, 2),
            const SizedBox(width: 16),
            _buildNavDot("河洛数", _heluoGreen, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavDot(String label, Color color, int index) {
    return GestureDetector(
      onTap: () => _scrollToIndex(index),
      child: Tooltip(
        message: label,
        preferBelow: false,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
