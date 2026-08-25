// 一次性工具：把 Material 天氣圖示畫成 app icon 的母圖。
// 用 `flutter test test/generate_app_icon.dart` 執行（檔名沒有 _test 後綴，不會進一般測試）。
// 產出的兩張母圖還要再縮成各尺寸才會進 android/ios，那一步是手動的：本專案沒有裝
// flutter_launcher_icons，icon 也不預期再改，不值得為一次性的動作多一個依賴。
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _size = 1024.0;

/// 太陽＋雲：Material 沒有現成的「多雲時晴」，兩個圖示疊出來。
const _art = Stack(
  children: [
    Positioned(
      left: 220,
      top: 140,
      child: Icon(Icons.wb_sunny, size: 400, color: Color(0xFFFFC44D)),
    ),
    Positioned(
      left: 195,
      top: 380,
      child: Icon(Icons.cloud, size: 620, color: Colors.white),
    ),
  ],
);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // flutter test 預設不套用 MaterialIcons，圖示會變成空白方框；字型本身則已經
    // 被 bundle 進測試資產，所以從 rootBundle 取而不是去猜 SDK 的安裝路徑。
    final loader = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await loader.load();
  });

  testWidgets('master', (tester) async {
    await _render(
      tester,
      'build/app_icon_master.png',
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B8FD8), Color(0xFF0A5C96)],
          ),
        ),
        child: _art,
      ),
    );
  });

  testWidgets('adaptive foreground', (tester) async {
    // Android adaptive icon 只保證中央 2/3 不被遮罩裁掉，所以縮小置中。
    await _render(
      tester,
      'build/app_icon_foreground.png',
      Transform.scale(scale: 0.64, child: _art),
    );
  });
}

Future<void> _render(WidgetTester tester, String path, Widget child) async {
  final key = GlobalKey();
  tester.view.physicalSize = const Size(_size, _size);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(width: _size, height: _size, child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path).writeAsBytesSync(data!.buffer.asUint8List());
  });
}
