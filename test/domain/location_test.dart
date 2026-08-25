import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/domain/location.dart';

/// 接縫 1：查詢正規化——輸入查詢字串，觀察得到縣市或失敗。（#14）
///
/// 上游對錯誤輸入完全靜默（F11），所以這裡是本專案唯一的輸入有效性判定來源。
void main() {
  group('正規化', () {
    test('22 個官方名稱都對應到自己', () {
      for (final name in taiwanLocations) {
        expect(normaliseQuery(name), name, reason: name);
      }
    });

    test('不是縣市的文字對應不到任何縣市', () {
      expect(normaliseQuery('火星'), isNull);
    });

    test('寫成「台」也找得到官方的「臺」', () {
      expect(normaliseQuery('台北市'), '臺北市');
      expect(normaliseQuery('台中市'), '臺中市');
      expect(normaliseQuery('台南市'), '臺南市');
      expect(normaliseQuery('台東縣'), '臺東縣');
    });

    test('前後空白不影響結果', () {
      expect(normaliseQuery('  臺北市 '), '臺北市');
      expect(normaliseQuery('\n台北市\t'), '臺北市');
    });

    test('省略「市」「縣」的簡稱會被補全', () {
      expect(normaliseQuery('臺北'), '臺北市');
      expect(normaliseQuery('台北'), '臺北市');
      expect(normaliseQuery('高雄'), '高雄市');
      expect(normaliseQuery('南投'), '南投縣');
    });

    test('簡稱同時對得上一縣一市時不猜，交給建議清單', () {
      // 新竹縣與新竹市、嘉義縣與嘉義市都存在，補全會是擲骰子。
      expect(normaliseQuery('新竹'), isNull);
      expect(normaliseQuery('嘉義'), isNull);
    });

    test('空字串對應不到任何縣市', () {
      expect(normaliseQuery(''), isNull);
      expect(normaliseQuery('   '), isNull);
    });
  });

  group('建議清單', () {
    test('打一個字就找得到——比對的是包含而不是開頭', () {
      // 22 個縣市裡有四個以「臺」開頭，前綴比對會讓打「南」的人找不到臺南市。
      expect(suggestLocations('南'), ['臺南市', '南投縣']);
      expect(suggestLocations('北'), ['臺北市', '新北市']);
    });

    test('寫成「台」也列得出來', () {
      expect(suggestLocations('台'), containsAll(['臺北市', '臺中市', '臺南市', '臺東縣']));
    });

    test('曖昧的簡稱把兩個選項都列出來', () {
      expect(suggestLocations('新竹'), ['新竹縣', '新竹市']);
    });

    test('還沒輸入就沒有建議', () {
      expect(suggestLocations(''), isEmpty);
      expect(suggestLocations('   '), isEmpty);
    });

    test('對應不到任何縣市時建議為空', () {
      expect(suggestLocations('火星'), isEmpty);
    });
  });
}
