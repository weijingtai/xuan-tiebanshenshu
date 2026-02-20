import 'package:flutter/material.dart';
import 'models/base_18_models.dart';
import 'widgets/unified_algorithm_card.dart';
import 'widgets/unified_nav_rail.dart';

class Base18Page extends StatefulWidget {
  const Base18Page({super.key});

  @override
  State<Base18Page> createState() => _Base18PageState();
}

class _Base18PageState extends State<Base18Page> {
  bool _isTinyMode = false;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _cardKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(), // Heluo
  ];

  void _scrollToIndex(int index) {
    final context = _cardKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        alignment: 0.1, // Near top
      );
    }
  }

  void _toggleMode() {
    setState(() {
      _isTinyMode = !_isTinyMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Base18Theme.bgColor,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Center cards
              children: [
                const SizedBox(height: 60), // Space for controls
                // 1. Huangji Scheme 1
                UnifiedAlgorithmCard(
                  key: _cardKeys[0],
                  title: "皇极经世 · 方案一",
                  formula: "(年干 × 12 + 月支) ÷ 360",
                  themeColor: Base18Theme.huangjiPurple,
                  isTinyMode: _isTinyMode,
                  verses: const [
                    VerseData(
                      id: "1245",
                      watermark: "壹貳肆伍",
                      text: "宏图大展在此时，四海昇平见太平。",
                      tags: ["月支", "45-54 岁"],
                      seal: "大吉",
                      sealColor: Base18Theme.sealGreatGood,
                      versions: [
                        VerseVersion(
                          source: "刻本",
                          content: "宏图大展在此时，四海昇平见太平。",
                          isPrimary: true,
                        ),
                        VerseVersion(source: "抄本", content: "宏图大展在此时，四海升平见太平。"),
                      ],
                    ),
                    VerseData(
                      id: "3870",
                      watermark: "叁捌柒零",
                      text: "亢龙有悔，盈不可久。",
                      tags: ["月支", "2024"],
                      seal: "中平",
                      sealColor: Base18Theme.sealNeutral,
                    ),
                    VerseData(
                      id: "5432",
                      watermark: "伍肆叁貳",
                      text: "时来天地皆同力，运去英雄不自由。",
                      tags: ["月支", "32 岁"],
                      seal: "吉",
                      sealColor: Base18Theme.sealGood,
                    ),
                    VerseData(
                      id: "9108",
                      watermark: "玖壹零捌",
                      text: "梅花香自苦寒来，宝剑锋从磨砺出。",
                      tags: ["月支", "1995"],
                      seal: "大吉",
                      sealColor: Base18Theme.sealGreatGood,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Huangji Scheme 2
                UnifiedAlgorithmCard(
                  key: _cardKeys[1],
                  title: "皇极经世 · 方案二",
                  formula: "(值年卦 × 卦象) % 384",
                  themeColor: Base18Theme.huangjiPurple,
                  isTinyMode: _isTinyMode,
                  verses: const [
                    VerseData(
                      id: "8912",
                      watermark: "捌玖壹貳",
                      text: "云深不知处，静待有缘人。",
                      tags: ["月支", "2025"],
                      seal: "平",
                      sealColor: Base18Theme.sealNeutral,
                    ),
                    VerseData(
                      id: "2234",
                      watermark: "貳貳叁肆",
                      text: "石中藏美玉，淘沙见真金。",
                      tags: ["月支", "42 岁"],
                      seal: "小凶",
                      sealColor: Base18Theme.sealBad,
                    ),
                    VerseData(
                      id: "11567",
                      watermark: "壹万壹伍",
                      text: "进德修业，水到渠成。",
                      tags: ["月支"],
                      seal: "中平",
                      sealColor: Base18Theme.sealNeutral,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Taixuan
                UnifiedAlgorithmCard(
                  key: _cardKeys[2],
                  title: "太玄数 · 方案一",
                  formula: "(先天 + 后天) % 12 + 1000",
                  themeColor: Base18Theme.taixuanRed,
                  isTinyMode: _isTinyMode,
                  verses: const [
                    VerseData(
                      id: "5621",
                      watermark: "伍陸貳壹",
                      text: "命有定数，运有变数。",
                      tags: ["月支", "28-37 岁"],
                      seal: "小吉",
                      sealColor: Base18Theme.sealGood,
                    ),
                    VerseData(
                      id: "10452",
                      watermark: "壹万零肆",
                      text: "风雨袭来莫惊慌，定心坐禅避祸殃。",
                      tags: ["月支", "庚寅"],
                      seal: "凶",
                      sealColor: Base18Theme.sealBad,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. Heluo
                UnifiedAlgorithmCard(
                  key: _cardKeys[3],
                  title: "河洛数",
                  formula: "(天地总数 - 阳数) % 384",
                  themeColor: Base18Theme.heluoGreen,
                  isTinyMode: _isTinyMode,
                  verses: const [
                    VerseData(
                      id: "12891",
                      watermark: "壹万貳捌",
                      text: "龙腾四海势不凡，功成名就指日看。",
                      tags: ["月支", "24 岁"],
                      seal: "大吉",
                      sealColor: Base18Theme.sealGreatGood,
                    ),
                    VerseData(
                      id: "3344",
                      watermark: "叁叁肆肆",
                      text: "春江水暖鸭先知，细察秋毫得先机。",
                      tags: ["月支"],
                      seal: "吉",
                      sealColor: Base18Theme.sealGood,
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),

          // Navigation Rail
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: UnifiedNavRail(
                onTap: _scrollToIndex,
                isTinyMode: _isTinyMode,
              ),
            ),
          ),

          // Controls (Top Right)
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: _toggleMode,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "全量切换 (Switch All)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text("✨", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
