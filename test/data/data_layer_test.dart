import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 驗收條件：`dio` 止於 data 層，呈現層對它零 import。（#7）
///
/// Repository 抽象的全部價值就在這條界線上——上層只看得到領域模型或失敗。
/// 界線寫在文件裡沒有人會記得，所以用測試守住。
void main() {
  /// #15 tracer bullet 的殘留：`main.dart` 目前自己打 API。#10 換掉它之後，
  /// 這一條例外要一起刪掉。
  const tracerBullet = 'lib/main.dart';

  final dioImport = RegExp('''^\\s*import\\s+['"]package:dio/''');

  List<String> importsDioIn(String directory) => [
    for (final source in Directory(directory)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart')))
      if (source.readAsLinesSync().any(dioImport.hasMatch)) source.path,
  ];

  test('偵測得到 dio 的 import——否則下面那條界線是空的', () {
    expect(importsDioIn('lib/data'), isNotEmpty);
  });

  test('dio 只出現在 lib/data', () {
    final offenders = importsDioIn('lib')
        .where((path) => !path.startsWith('lib/data/'))
        .where((path) => path != tracerBullet)
        .toList();
    expect(offenders, isEmpty);
  });
}
