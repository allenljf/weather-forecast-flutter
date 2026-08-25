import 'package:flutter/material.dart';
import 'package:weather_forecast/presentation/app_theme.dart';
import 'package:weather_forecast/presentation/forecast_display.dart';

/// App 外殼：套上主題，並讓顯示區塊有個地方可以站。
///
/// 深色主題跟著系統走（[ThemeMode.system]）——審閱者的模擬器若開著深色，
/// 沒處理的 app 會看起來像沒測過。（Q31 2(b)）
///
/// 上方的搜尋列由 #9 接上；在那之前這裡只掛得住顯示區塊。
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '今明 36 小時天氣預報',
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.system,
      home: Scaffold(
        appBar: AppBar(title: const Text('今明 36 小時天氣預報')),
        body: const SafeArea(child: ForecastDisplay()),
      ),
    );
  }
}
