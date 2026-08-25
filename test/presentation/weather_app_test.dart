import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/presentation/app_theme.dart';
import 'package:weather_forecast/presentation/forecast_display.dart';
import 'package:weather_forecast/presentation/weather_app.dart';

/// 驗收條件：配色是經過設計的，而且深色模式跟著系統走。（#10／Q31）
void main() {
  testWidgets('系統設成深色時，app 跟著變成深色，而不是一片刺眼的白', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const ProviderScope(child: WeatherApp()));

    expect(themeOnScreen(tester).brightness, Brightness.dark);
  });

  testWidgets('系統是亮色時維持亮色', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const ProviderScope(child: WeatherApp()));

    expect(themeOnScreen(tester).brightness, Brightness.light);
  });

  test('亮暗兩套主題都不是框架的預設配色', () {
    final framework = ThemeData();

    expect(
      appLightTheme.colorScheme.primary,
      isNot(framework.colorScheme.primary),
    );
    expect(
      appDarkTheme.colorScheme.primary,
      isNot(framework.colorScheme.primary),
    );
  });

  test('四個狀態 widget 裡沒有任何硬編碼顏色', () {
    // 硬編碼一個顏色的當下不會有人發現，要到審閱者開著深色模式打開 app、
    // 看到深底上一塊白字的時候才會。顏色只能從主題來，這條線只有掃描守得住。
    final colourLiteral = RegExp(r'Colors\.|Color\(0x|Color\.from');
    final comment = RegExp(r'^\s*(///?|\*)');
    final offenders = [
      for (final line in File(
        'lib/presentation/forecast_display.dart',
      ).readAsLinesSync())
        if (colourLiteral.hasMatch(line) && !comment.hasMatch(line))
          line.trim(),
    ];

    expect(offenders, isEmpty);
  });
}

ThemeData themeOnScreen(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(ForecastDisplay)));
