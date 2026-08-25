import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/domain/relative_day.dart';

void main() {
  group('預報時段的相對日格式化', () {
    test('與基準時間同一天，標成今日', () {
      expect(
        formatRelativeDayTime(
          DateTime(2026, 8, 25, 6),
          now: DateTime(2026, 8, 25, 5, 30),
        ),
        '今日 06:00',
      );
    });

    test('基準時間的隔天，標成明日', () {
      expect(
        formatRelativeDayTime(
          DateTime(2026, 8, 26, 18),
          now: DateTime(2026, 8, 25, 5, 30),
        ),
        '明日 18:00',
      );
    });

    test('只差幾分鐘但跨過午夜，算明日而不是今日', () {
      expect(
        formatRelativeDayTime(
          DateTime(2026, 8, 26, 0, 5),
          now: DateTime(2026, 8, 25, 23, 59),
        ),
        '明日 00:05',
      );
    });

    test('差了將近一整天但沒跨過午夜，仍是今日', () {
      expect(
        formatRelativeDayTime(
          DateTime(2026, 8, 25, 23, 55),
          now: DateTime(2026, 8, 25, 0, 5),
        ),
        '今日 23:55',
      );
    });

    test('跨兩個午夜，標成後天', () {
      expect(
        formatRelativeDayTime(
          DateTime(2026, 8, 27, 6),
          now: DateTime(2026, 8, 25, 6),
        ),
        '後天 06:00',
      );
    });

    test('只差 25 小時但跨了兩個午夜，算後天而不是明日', () {
      expect(
        formatRelativeDayTime(
          DateTime(2026, 8, 27),
          now: DateTime(2026, 8, 25, 23),
        ),
        '後天 00:00',
      );
    });

    test('跨月的隔天照樣是明日', () {
      expect(
        formatRelativeDayTime(
          DateTime(2026, 9, 1, 6),
          now: DateTime(2026, 8, 31, 18),
        ),
        '明日 06:00',
      );
    });

    test('三個詞不夠用時退回日期，不會謊報成後天', () {
      expect(
        formatRelativeDayTime(
          DateTime(2026, 8, 28, 6),
          now: DateTime(2026, 8, 25, 6),
        ),
        '8/28 06:00',
      );
      expect(
        formatRelativeDayTime(
          DateTime(2026, 8, 24, 18),
          now: DateTime(2026, 8, 25, 6),
        ),
        '8/24 18:00',
      );
    });

    test('實測的三個時段在查詢當下讀起來是連續的', () {
      final now = DateTime(2026, 8, 25, 13);
      expect(
        [
          DateTime(2026, 8, 25, 6),
          DateTime(2026, 8, 25, 18),
          DateTime(2026, 8, 26, 6),
          DateTime(2026, 8, 26, 18),
        ].map((time) => formatRelativeDayTime(time, now: now)).toList(),
        ['今日 06:00', '今日 18:00', '明日 06:00', '明日 18:00'],
      );
    });
  });
}
