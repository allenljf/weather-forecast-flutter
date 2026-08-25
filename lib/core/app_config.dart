/// 授權碼是組態而非領域資料：缺少它是設定錯誤，在啟動瞬間就中止，
/// 不會變成四種畫面狀態中的任何一種。（Q2／Q28）
abstract final class AppConfig {
  /// 全 app 唯一讀取編譯期環境值的位置。
  static const weatherApiToken = String.fromEnvironment(_tokenKey);

  static const _tokenKey = 'WEATHER_API_TOKEN';

  /// 在 `main()` 第一行呼叫；授權碼缺失時丟出 [StateError]，訊息本身即說明書。
  static void ensureLoaded() {
    if (weatherApiToken.isNotEmpty) return;
    throw StateError(_missingTokenMessage);
  }

  static const _missingTokenMessage =
      '''
$_tokenKey 未設定，無法呼叫中央氣象署 API。

審閱者請直接用 repo 內附的授權碼執行：

    flutter run --dart-define-from-file=dart_defines/reviewer.json

想改用自己的授權碼，請到中央氣象署開放資料平臺 https://opendata.cwa.gov.tw/
免費申請，複製 dart_defines/dev.example.json 為 dart_defines/dev.json
（此檔已被 .gitignore 排除），填入授權碼後執行：

    flutter run --dart-define-from-file=dart_defines/dev.json
''';
}
