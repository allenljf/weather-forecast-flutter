import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 驗收條件：domain 層不 import 任何 `package:flutter/*`。（Q9）
/// 這條界線是「領域層零框架依賴、可獨立測試」的唯一可自動檢查的證據，
/// 因此用測試守住，而不是靠人記得。
void main() {
  final sources = Directory('lib/domain')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  test('domain 層有東西可檢查', () {
    expect(sources, isNotEmpty);
  });

  test('domain 層不依賴 Flutter', () {
    final flutterImport = RegExp('''^\\s*import\\s+['"]package:flutter/''');
    final offenders = [
      for (final source in sources)
        for (final line in source.readAsLinesSync())
          if (flutterImport.hasMatch(line)) '${source.path}: ${line.trim()}',
    ];
    expect(offenders, isEmpty);
  });
}
