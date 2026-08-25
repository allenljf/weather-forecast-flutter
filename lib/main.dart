import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_forecast/core/app_config.dart';
import 'package:weather_forecast/presentation/weather_app.dart';

void main() {
  // 授權碼缺失是設定錯誤，不是四種畫面狀態中的任何一種，所以在啟動瞬間就中止。（Q2）
  AppConfig.ensureLoaded();
  runApp(const ProviderScope(child: WeatherApp()));
}
