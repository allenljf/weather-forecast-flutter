import 'package:flutter/material.dart';

/// 種子色：一顆顏色衍生出整套配色，深色只是同一顆種子換一種亮度。（Q31 1(b)/2(b)）
///
/// 這是全 app 唯一容許出現顏色字面值的地方；其餘一切顏色都從主題取得。
const appSeedColor = Color(0xFF0B6FB4);

final appLightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: appSeedColor),
);

final appDarkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: appSeedColor,
    brightness: Brightness.dark,
  ),
);
