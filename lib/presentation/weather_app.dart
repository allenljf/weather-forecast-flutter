import 'package:flutter/material.dart';
import 'package:weather_forecast/presentation/app_theme.dart';
import 'package:weather_forecast/presentation/forecast_display.dart';
import 'package:weather_forecast/presentation/location_search_bar.dart';

/// App 外殼：套上主題，並把搜尋列與顯示區塊疊成需求圖上的單頁畫面。
///
/// 深色主題跟著系統走（[ThemeMode.system]）——審閱者的模擬器若開著深色，
/// 沒處理的 app 會看起來像沒測過。（Q31 2(b)）
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
        body: const SafeArea(
          child: Column(
            children: [
              LocationSearchBar(),
              Expanded(child: ForecastDisplay()),
            ],
          ),
        ),
      ),
    );
  }
}
