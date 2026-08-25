import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_forecast/data/cwa_forecast_parser.dart';
import 'package:weather_forecast/domain/failure.dart';
import 'package:weather_forecast/domain/forecast_slot.dart';

/// 中央氣象署「今明 36 小時天氣預報」的用戶端。
///
/// 這一層只認得 HTTP 與 JSON：它把上游的實際行為（而非它的文件）忠實封裝起來，
/// 對外只丟出 [CwaApiException]，不外洩 [DioException] 或 [Response]。
class CwaApiClient {
  CwaApiClient({required String token, HttpClientAdapter? httpClientAdapter})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: timeout,
          receiveTimeout: timeout,
          // 授權碼走 header 而非查詢參數，因此它不會進入網址、log 與錯誤畫面
          // 的可展開技術細節。（Q27(b)）
          //
          // 反直覺點：token 必須**原樣**送出，加上 `Bearer ` 前綴實測會 401。
          headers: {'Authorization': token},
          // 自己解碼，才能讓「憑證錯誤回的是純文字而非 JSON」（F3）
          // 落在下面的映射裡，而不是變成 dio 內部的二次解析失敗。
          responseType: ResponseType.plain,
        ),
      ) {
    if (httpClientAdapter != null) _dio.httpClientAdapter = httpClientAdapter;
  }

  static const baseUrl = 'https://opendata.cwa.gov.tw/api/v1/rest/datastore/';

  /// 一般天氣預報－今明 36 小時天氣預報。
  static const datasetPath = 'F-C0032-001';

  /// 連線與接收各 15 秒。（Q18(iii)）
  static const timeout = Duration(seconds: 15);

  final Dio _dio;

  /// 查詢單一縣市。空清單代表上游回了空陣列，由呼叫端決定那算什麼失敗。
  Future<List<ForecastSlot>> fetchForecast(String locationName) async {
    final Response<String> response;
    try {
      response = await _dio.get<String>(
        datasetPath,
        // 每次查詢只帶一個縣市（Q26(a)）。
        queryParameters: {'locationName': locationName},
      );
    } on DioException catch (error) {
      throw CwaApiException(_failureFrom(error));
    }

    final uri = response.realUri;
    final Object? decoded;
    try {
      decoded = jsonDecode(response.data ?? '');
    } on FormatException catch (error) {
      throw CwaApiException(
        MalformedResponse(
          detail: '回應不是合法 JSON：${error.message}',
          requestUri: uri,
        ),
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw CwaApiException(
        MalformedResponse(detail: '回應的最外層不是 JSON 物件', requestUri: uri),
      );
    }

    try {
      return parseForecastSlots(decoded, locationName: locationName);
    } on FormatException catch (error) {
      throw CwaApiException(
        MalformedResponse(detail: error.message, requestUri: uri),
      );
    } on CheckedFromJsonException catch (error) {
      throw CwaApiException(
        MalformedResponse(
          detail: '${error.className}.${error.key}：${error.message}',
          requestUri: uri,
        ),
      );
    }
  }

  Failure _failureFrom(DioException error) {
    final uri = error.requestOptions.uri;
    final response = error.response;
    if (response == null) {
      // 逾時、DNS、斷線都在這裡；dio 沒給訊息時退回類型名稱。
      return ConnectionFailure(
        detail: error.message ?? error.type.name,
        requestUri: uri,
      );
    }

    final statusCode = response.statusCode ?? 0;
    // 憑證錯誤的 body 是純文字而非 JSON（F3），所以原樣以字串保留。
    final body = '${response.data ?? ''}'.trim();
    return statusCode == 401
        ? InvalidToken(
            statusCode: statusCode,
            responseBody: body,
            requestUri: uri,
          )
        : UpstreamFailure(
            statusCode: statusCode,
            responseBody: body,
            requestUri: uri,
          );
  }
}

/// 用戶端唯一的對外失敗管道，攜帶一個已經分類好的 [Failure]。
class CwaApiException implements Exception {
  const CwaApiException(this.failure);

  final Failure failure;

  @override
  String toString() => 'CwaApiException(${failure.diagnostics})';
}
