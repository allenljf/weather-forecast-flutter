import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/domain/failure.dart';

/// 接縫：輸入一個失敗，觀察使用者會看到的文案與有沒有重試按鈕。（#14 接縫 ③ 的純邏輯半邊）
/// 「底層例外／狀態碼 → 失敗」那半邊是 data 層的事，不在這裡測。
///
/// 文案只斷言足以辨識成因的關鍵詞與使用者輸入，不鎖定整句——
/// 措辭會被調整，而「哪一種失敗說哪一件事」才是規格。（Q20）
void main() {
  group('無效查詢', () {
    test('文案指名使用者打的字並引導去建議清單，重試沒有意義', () {
      final copy = failureCopy(const InvalidQuery(query: '台北縣'));

      expect(copy.message, contains('台北縣'));
      expect(copy.message, contains('建議'));
      expect(copy.canRetry, isFalse);
    });
  });

  group('憑證錯誤', () {
    test('文案說明問題出在授權碼而不是網路，重試沒有意義', () {
      final copy = failureCopy(
        InvalidToken(
          statusCode: 401,
          responseBody: '無效的授權碼',
          requestUri: Uri.parse('$_endpoint?locationName=臺北市'),
        ),
      );

      expect(copy.message, contains('授權碼'));
      expect(copy.canRetry, isFalse);
    });

    test('診斷資訊帶著狀態碼、原始回應與請求網址', () {
      // 憑證錯誤時上游回的是純文字而非 JSON（F3），所以原樣留著。
      final failure = InvalidToken(
        statusCode: 401,
        responseBody: '無效的授權碼',
        requestUri: Uri.parse('$_endpoint?locationName=臺北市'),
      );

      expect(failure.diagnostics, contains('401'));
      expect(failure.diagnostics, contains('無效的授權碼'));
      expect(failure.diagnostics, contains(_endpoint));
    });
  });

  group('連線失敗或逾時', () {
    test('文案說明是連線問題，可以重試', () {
      final copy = failureCopy(
        ConnectionFailure(
          detail: 'connection timeout after 15s',
          requestUri: Uri.parse('$_endpoint?locationName=臺北市'),
        ),
      );

      expect(copy.message, contains('連線'));
      expect(copy.canRetry, isTrue);
    });
  });

  group('上游服務異常', () {
    test('文案說明問題不在使用者這邊，可以稍後重試', () {
      final copy = failureCopy(
        UpstreamFailure(
          statusCode: 503,
          responseBody: 'Service Unavailable',
          requestUri: Uri.parse('$_endpoint?locationName=臺北市'),
        ),
      );

      expect(copy.message, contains('氣象署'));
      expect(copy.canRetry, isTrue);
    });
  });

  group('回應格式無法解析', () {
    test('文案說明是資料格式的問題，可以重試', () {
      final copy = failureCopy(
        MalformedResponse(
          detail: '時段 1 缺少天氣要素 CI',
          requestUri: Uri.parse('$_endpoint?locationName=臺北市'),
        ),
      );

      expect(copy.message, contains('資料格式'));
      expect(copy.canRetry, isTrue);
    });
  });

  group('上游查無此縣市', () {
    test('文案對使用者誠實——是氣象署沒資料，不是他打錯字，重試沒有意義', () {
      final copy = failureCopy(
        UpstreamMissingLocation(
          locationName: '臺北市',
          requestUri: Uri.parse('$_endpoint?locationName=臺北市'),
        ),
      );

      expect(copy.message, contains('氣象署'));
      expect(copy.message, contains('臺北市'));
      expect(copy.canRetry, isFalse);
    });

    test('診斷資訊註明本地縣市清單可能已過期', () {
      // 白名單擋在前面，所以空陣列在本專案只有這一個成因。（Q24）
      final failure = UpstreamMissingLocation(
        locationName: '臺北市',
        requestUri: Uri.parse('$_endpoint?locationName=臺北市'),
      );

      expect(failure.diagnostics, contains('本地縣市清單'));
      expect(failure.diagnostics, contains('過期'));
    });
  });

  group('六種失敗合起來', () {
    test('每一種都說不一樣的話——否則這套分類在畫面上不產生任何價值', () {
      final messages = _allFailures.map((f) => failureCopy(f).message);

      expect(messages.toSet(), hasLength(_allFailures.length));
    });

    test('每一種都帶得出可展開的診斷資訊', () {
      for (final failure in _allFailures) {
        expect(
          failure.diagnostics,
          isNotEmpty,
          reason: '${failure.runtimeType} 沒有診斷資訊',
        );
      }
    });

    test('恰好六種，使用端可用無 default 分支的 switch 窮舉', () {
      // 這個 switch 沒有 default：出現第七種失敗時它會編譯失敗，
      // 逼 data 與 presentation 兩層的使用端一起更新。
      String kindOf(Failure failure) => switch (failure) {
        InvalidQuery() => '無效查詢',
        InvalidToken() => '憑證錯誤',
        ConnectionFailure() => '連線失敗或逾時',
        UpstreamFailure() => '上游服務異常',
        MalformedResponse() => '回應格式無法解析',
        UpstreamMissingLocation() => '上游查無此縣市',
      };

      expect(_allFailures.map(kindOf).toSet(), hasLength(6));
    });
  });
}

final _requestUri = Uri.parse('$_endpoint?locationName=臺北市');

final _allFailures = <Failure>[
  const InvalidQuery(query: '台北縣'),
  InvalidToken(
    statusCode: 401,
    responseBody: '無效的授權碼',
    requestUri: _requestUri,
  ),
  ConnectionFailure(
    detail: 'connection timeout after 15s',
    requestUri: _requestUri,
  ),
  UpstreamFailure(
    statusCode: 503,
    responseBody: 'Service Unavailable',
    requestUri: _requestUri,
  ),
  MalformedResponse(detail: '時段 1 缺少天氣要素 CI', requestUri: _requestUri),
  UpstreamMissingLocation(locationName: '臺北市', requestUri: _requestUri),
];

const _endpoint =
    'https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001';
