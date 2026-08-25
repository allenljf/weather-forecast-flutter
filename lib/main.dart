// Tracer bullet (#15)：證明「設定 → 網路 → 解析 → 畫面」整條線與上游契約是通的。
// 這個檔案會被 #6–#10 整個取代，因此刻意沒有抽象、沒有狀態管理、沒有錯誤處理。
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:weather_forecast/core/app_config.dart';

const _endpoint =
    'https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001';
const _location = '臺北市';

Future<void> main() async {
  AppConfig.ensureLoaded();
  WidgetsFlutterBinding.ensureInitialized();

  // 失敗直接往外拋（#15 不處理任何錯誤），所以在 runApp 之前就把資料抓完。
  final slots = await _fetchWxSlots();
  runApp(_TracerApp(slots: slots));
}

Future<List<String>> _fetchWxSlots() async {
  final dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 驗收條件：授權碼只能在 header，網址裡不能有。
          debugPrint('[tracer] request uri: ${options.uri}');
          debugPrint('[tracer] header keys: ${options.headers.keys.toList()}');
          debugPrint(
            '[tracer] token leaked into uri: '
            '${options.uri.toString().contains(AppConfig.weatherApiToken)}',
          );
          handler.next(options);
        },
      ),
    );

  final response = await dio.getUri<Map<String, dynamic>>(
    Uri.parse(_endpoint).replace(queryParameters: {'locationName': _location}),
    options: Options(headers: {'Authorization': AppConfig.weatherApiToken}),
  );

  final location =
      (response.data!['records'] as Map<String, dynamic>)['location'] as List;
  final elements =
      (location.single as Map<String, dynamic>)['weatherElement'] as List;
  final wx = elements.firstWhere(
    (e) => (e as Map<String, dynamic>)['elementName'] == 'Wx',
  ) as Map<String, dynamic>;

  return [
    for (final slot in wx['time'] as List)
      '${(slot as Map<String, dynamic>)['startTime']} ~ ${slot['endTime']}  '
          '${(slot['parameter'] as Map<String, dynamic>)['parameterName']}',
  ];
}

class _TracerApp extends StatelessWidget {
  const _TracerApp({required this.slots});

  final List<String> slots;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('tracer #15 — $_location')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [for (final slot in slots) Text(slot)],
        ),
      ),
    );
  }
}
