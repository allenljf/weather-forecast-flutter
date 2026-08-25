/// 失敗：導致畫面進入「錯誤」狀態的具體原因，恰好六種。（Q3(b)、Q24(c)）
///
/// 用 sealed 而非字串或列舉，是因為每一種失敗攜帶的診斷欄位本來就不一樣——
/// 無效查詢根本沒發出請求，自然沒有狀態碼可帶。使用端以 exhaustive switch
/// 窮舉，新增第七種時編譯器會逼所有使用端一起更新。
sealed class Failure {
  const Failure();

  /// 給可展開區塊看的底層診斷資訊。（Q20 2(b)）
  ///
  /// 授權碼走 header 而非查詢參數（Q27），因此請求網址可以原樣顯示。
  String get diagnostics;
}

/// 無效查詢：正規化失敗，本地白名單擋下，未發出任何請求。（Q1）
class InvalidQuery extends Failure {
  const InvalidQuery({required this.query});

  /// 使用者實際打進去的原始文字。
  final String query;

  @override
  String get diagnostics => '查詢字串：「$query」\n本地縣市白名單未命中，未發出請求。';
}

/// 憑證錯誤：授權碼缺失、錯誤或過期，上游以 401 回絕。（Q3）
class InvalidToken extends Failure {
  const InvalidToken({
    required this.statusCode,
    required this.responseBody,
    required this.requestUri,
  });

  final int statusCode;

  /// 上游的原始回應。憑證錯誤時它是純文字而非 JSON（F3），因此以字串保留。
  final String responseBody;

  final Uri requestUri;

  @override
  String get diagnostics => 'HTTP $statusCode\n$requestUri\n上游回應：$responseBody';
}

/// 連線失敗或逾時：請求沒能抵達上游，或在 15 秒內沒拿到回應。（Q18）
class ConnectionFailure extends Failure {
  const ConnectionFailure({required this.detail, required this.requestUri});

  /// 底層例外的原始訊息。
  final String detail;

  final Uri requestUri;

  @override
  String get diagnostics => '$requestUri\n$detail';
}

/// 上游服務異常：氣象署以 5xx 回絕。
class UpstreamFailure extends Failure {
  const UpstreamFailure({
    required this.statusCode,
    required this.responseBody,
    required this.requestUri,
  });

  final int statusCode;

  /// 上游的原始回應。失敗時不保證是 JSON（F3），因此以字串保留。
  final String responseBody;

  final Uri requestUri;

  @override
  String get diagnostics => 'HTTP $statusCode\n$requestUri\n上游回應：$responseBody';
}

/// 回應格式無法解析：上游回 200，但內容不是合法 JSON，
/// 或五個天氣要素缺了任一、或數值轉型失敗。（Q23 嚴格解析）
class MalformedResponse extends Failure {
  const MalformedResponse({required this.detail, required this.requestUri});

  /// 到底是哪裡不合規格。
  final String detail;

  final Uri requestUri;

  @override
  String get diagnostics => '$requestUri\n$detail';
}

/// 上游查無此縣市：白名單命中、上游卻回 200 加空陣列。（Q24(c)）
///
/// 上游對錯誤輸入完全靜默（F11），空陣列是唯一可觀察的訊號；
/// 但因為白名單擋在前面（Q1），能走到這裡的輸入必定是合法縣市，
/// 所以它在本專案只有一個成因：本地清單與上游脫鉤。
class UpstreamMissingLocation extends Failure {
  const UpstreamMissingLocation({
    required this.locationName,
    required this.requestUri,
  });

  /// 送給上游的縣市正式名稱。
  final String locationName;

  final Uri requestUri;

  @override
  String get diagnostics =>
      '$requestUri\n'
      '上游回 HTTP 200，但 records.location 為空陣列。\n'
      '本地縣市清單可能已過期：「$locationName」不再是上游認得的名稱。';
}

/// 文案與「是否可重試」的對應。（Q20 1(a)）
///
/// 刻意做成純函式而非型別上的欄位：這組對應是規格的一部分、會被單獨驗證，
/// 而 switch 的窮舉性讓「漏掉一種失敗」變成編譯錯誤。
typedef FailureCopy = ({String message, bool canRetry});

FailureCopy failureCopy(Failure failure) => switch (failure) {
  InvalidQuery(:final query) => (
    message: '找不到「$query」，請從建議清單選擇縣市',
    canRetry: false,
  ),
  InvalidToken() => (message: '授權碼無效，請更新後再試', canRetry: false),
  ConnectionFailure() => (message: '連線失敗，請檢查網路後重試', canRetry: true),
  UpstreamFailure() => (message: '氣象署服務暫時無法使用，請稍後再試', canRetry: true),
  MalformedResponse() => (message: '資料格式無法解析', canRetry: true),
  UpstreamMissingLocation(:final locationName) => (
    message: '氣象署目前沒有「$locationName」的預報資料',
    canRetry: false,
  ),
};
