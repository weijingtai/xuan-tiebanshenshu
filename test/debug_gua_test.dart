import 'package:flutter_test/flutter_test.dart';
import 'package:xuan_gua_core/xuan_gua_core.dart';

void main() {
  test('debug guaToBinaryList', () {
    // 测试乾卦
    final qian = Enum64Gua.qian_wei_tian;
    print('乾卦: ${qian.name}');
    print('top: ${qian.top.name}, bottom: ${qian.bottom.name}');
    print('bottomTopBinaryStr: ${qian.bottomTopBinaryStr}');
    print('bottomTopBinaryList: ${qian.bottomTopBinaryList}');
    
    // 测试 PureSixYaoGua.by8Gua
    final gua = PureSixYaoGua.by8Gua(qian.top, qian.bottom);
    print('PureSixYaoGua: ${gua.gua.name}');
    print('topBotYaoBinStr: ${gua.topBotYaoBinStr}');
    
    // 测试 guaToBinaryList
    final binaryList = guaToBinaryList(qian);
    print('guaToBinaryList: $binaryList');
  });
}
