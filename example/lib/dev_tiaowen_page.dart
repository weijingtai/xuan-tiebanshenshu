import 'package:flutter/material.dart';
import 'package:tiebanshenshu/presentation/pages/vertical_layout/widgets/vertical_verse_row.dart'; // For VerseRowData
import 'package:tiebanshenshu/presentation/pages/vertical_layout/widgets/horizontal_algorithm_card.dart';

class DevTiaoWenPage extends StatefulWidget {
  const DevTiaoWenPage({super.key});

  @override
  State<DevTiaoWenPage> createState() => _DevTiaoWenPageState();
}

class _DevTiaoWenPageState extends State<DevTiaoWenPage> {
  bool _isTinyState = false;

  // ─── Theme Colors ───
  static const _huangjiPurple = Color(0xFF512E5F);
  static const _taixuanRed = Color(0xFFA62B1F);
  static const _heluoGreen = Color(0xFF145A32);

  // ─── Seal Colors ───
  static const _sealGreatGood = Color(0xFF1B5E20);
  static const _sealGood = Color(0xFF43A047);
  static const _sealNeutral = Color(0xFF757575);
  static const _sealBad = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Horizontal Card Demo (Base 18)"),
        actions: [
          Switch(
            value: _isTinyState,
            onChanged: (v) => setState(() => _isTinyState = v),
          ),
          const SizedBox(width: 8),
          const Center(child: Text("Tiny")),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: const Color(0xFFE8E4DD),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // ━━━ Card 1: 皇极经世 · 方案一 ━━━
          HorizontalAlgorithmCard(
            title: "皇极经世 · 方案一",
            formula: "(年干 × 12 + 月支) ÷ 360",
            themeColor: _huangjiPurple,
            isTinyMode: _isTinyState,
            verses: const [
              VerseRowData(
                id: "1245",
                watermark: "壹貳肆伍",
                verseText: "宏图大展在此时，四海昇平见太平。",
                tags: ["月支"],
                ageBadge: "(45,54)",
                yearRange: "2040,2049",
                seal: "大吉",
                sealColor: _sealGreatGood,
                algorithm: "皇极经世",
                subAlgorithm: "方案一",
                versions: const [
                  VerseVersion(
                    source: "刻本",
                    content: "宏图大展在此时，四海昇平见太平。",
                    isPrimary: true,
                  ),
                  VerseVersion(source: "抄本", content: "宏图大展在此时，四海升平见太平。"),
                ],
              ),
              VerseRowData(
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
                description: "",
              ),
              VerseRowData(
                id: "5432",
                watermark: "伍肆叁貳",
                verseText: "时来天地皆同力，运去英雄不自由。",
                tags: ["月支"],
                seal: "吉",
                sealColor: _sealGood,
                algorithm: "皇极经世",
                subAlgorithm: "方案一",
                description: "",
              ),
              VerseRowData(
                id: "9108",
                watermark: "玖壹零捌",
                verseText: "梅花香自苦寒来，宝剑锋从磨砺出。",
                tags: ["月支"],
                seal: "大吉",
                sealColor: _sealGreatGood,
                algorithm: "皇极经世",
                subAlgorithm: "方案一",
                description: "",
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ━━━ Card 2: 皇极经世 · 方案二 ━━━
          HorizontalAlgorithmCard(
            title: "皇极经世 · 方案二",
            formula: "(值年卦 × 卦象) % 384",
            themeColor: _huangjiPurple,
            isTinyMode: _isTinyState,
            verses: const [
              VerseRowData(
                id: "8912",
                watermark: "捌玖壹貳",
                verseText: "云深不知处，静待有缘人。",
                tags: ["月支"],
                ageBadge: "(25)",
                yearRange: "2025",
                seal: "平",
                sealColor: _sealNeutral,
                algorithm: "皇极经世",
                subAlgorithm: "方案二",
                description: "",
              ),
              VerseRowData(
                id: "2234",
                watermark: "貳貳叁肆",
                verseText: "石中藏美玉，淘沙见真金。",
                tags: ["月支"],
                ageBadge: "(42)",
                yearRange: "2037",
                seal: "小凶",
                sealColor: _sealBad,
                algorithm: "皇极经世",
                subAlgorithm: "方案二",
                description: "",
              ),
              VerseRowData(
                id: "11567",
                watermark: "壹万壹伍陸柒",
                verseText: "进德修业，水到渠成。",
                tags: ["月支"],
                seal: "中平",
                sealColor: _sealNeutral,
                algorithm: "皇极经世",
                subAlgorithm: "方案二",
                description: "",
              ),
              VerseRowData(
                id: "4567",
                watermark: "肆伍陸柒",
                verseText: "海阔凭鱼跃，天高任鸟飞。",
                tags: ["月支"],
                seal: "小吉",
                sealColor: _sealGood,
                algorithm: "皇极经世",
                subAlgorithm: "方案二",
                description: "",
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ━━━ Card 3: 太玄数 · 方案一 ━━━
          HorizontalAlgorithmCard(
            title: "太玄数 · 方案一",
            formula: "(先天 + 后天) % 12 + 1000",
            themeColor: _taixuanRed,
            isTinyMode: _isTinyState,
            verses: const [
              VerseRowData(
                id: "5621",
                watermark: "伍陸貳壹",
                verseText: "命有定数，运有变数。",
                tags: ["月支"],
                ageBadge: "(28,37)",
                yearRange: "2023,2032",
                seal: "小吉",
                sealColor: _sealGood,
                algorithm: "太玄数",
                subAlgorithm: "方案一",
                description: "",
              ),
              VerseRowData(
                id: "10452",
                watermark: "壹萬零肆貳",
                verseText: "风雨袭来莫惊慌，定心坐禅避祸殃。",
                tags: ["月支"],
                seal: "凶",
                sealColor: _sealBad,
                algorithm: "太玄数",
                subAlgorithm: "方案一",
                description: "",
              ),
              VerseRowData(
                id: "7890",
                watermark: "柒捌玖零",
                verseText: "山重水复疑无路，柳暗花明又一村。",
                tags: ["月支"],
                seal: "凶",
                sealColor: _sealBad,
                algorithm: "太玄数",
                subAlgorithm: "方案一",
                description: "",
              ),
              VerseRowData(
                id: "1234",
                watermark: "壹貳叁肆",
                verseText: "读书破万卷，下笔如有神。",
                tags: ["月支"],
                seal: "吉",
                sealColor: _sealGood,
                algorithm: "太玄数",
                subAlgorithm: "方案一",
                description: "",
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ━━━ Card 4: 河洛数 ━━━
          HorizontalAlgorithmCard(
            title: "河洛数",
            formula: "(天地总数 - 阳数) % 384",
            themeColor: _heluoGreen,
            isTinyMode: _isTinyState,
            verses: const [
              VerseRowData(
                id: "12891",
                watermark: "壹萬貳捌玖壹",
                verseText: "龙腾四海势不凡，功成名就指日看。",
                tags: ["月支"],
                ageBadge: "(24)",
                yearRange: "2024",
                seal: "大吉",
                sealColor: _sealGreatGood,
                algorithm: "河洛数",
                description: "",
              ),
              VerseRowData(
                id: "3344",
                watermark: "叁叁肆肆",
                verseText: "春江水暖鸭先知，细察秋毫得先机。",
                tags: ["月支"],
                seal: "吉",
                sealColor: _sealGood,
                algorithm: "河洛数",
                description: "",
              ),
              VerseRowData(
                id: "7788",
                watermark: "柒柒捌捌",
                verseText: "千里之行，始于足下。",
                tags: ["月支"],
                seal: "平",
                sealColor: _sealNeutral,
                algorithm: "河洛数",
                description: "",
              ),
              VerseRowData(
                id: "11223",
                watermark: "壹萬壹貳貳叁",
                verseText: "宁静致远，淡泊明志。",
                tags: ["月支"],
                seal: "小吉",
                sealColor: _sealGood,
                algorithm: "河洛数",
                description: "",
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
