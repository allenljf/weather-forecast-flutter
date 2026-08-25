import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_forecast/domain/location.dart';
import 'package:weather_forecast/presentation/forecast_controller.dart';

/// 搜尋列：輸入框與「確認」按鈕。（#9）
///
/// `ConsumerStatefulWidget` 而非 hooks——需求明文禁用 hooks（Q5）。輸入框的內容
/// 是純粹的畫面狀態，不需要進 provider：沒有第二個 widget 需要讀它。
class LocationSearchBar extends ConsumerStatefulWidget {
  const LocationSearchBar({super.key});

  @override
  ConsumerState<LocationSearchBar> createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends ConsumerState<LocationSearchBar> {
  final _query = TextEditingController();

  /// 點過建議之後把清單收起來。下一次打字會再打開——收起的是「這一次的選擇」，
  /// 不是這個功能。
  var _suggestionsDismissed = false;

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() => _suggestionsDismissed = false));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  /// 空輸入時停用確認鈕：「還沒輸入」不是「無效查詢」，不該把使用者送進錯誤畫面。
  /// （Q10 4(a)）
  bool get _canSubmit => _query.text.trim().isNotEmpty;

  /// 點選建議只填入、不送出：選錯的人還有機會改，而且需求原文是「點擊確認後」
  /// 才從 API 取資料。（Q10 3(a)）
  void _pick(String name) {
    _query.text = name;
    setState(() => _suggestionsDismissed = true);
  }

  void _submit() {
    if (!_canSubmit) return;
    // 送出後收鍵盤：iOS/Android 點按鈕不會自動讓輸入框失焦，鍵盤會擋住結果。
    FocusScope.of(context).unfocus();
    unawaited(
      ref.read(forecastControllerProvider.notifier).search(_query.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestionsDismissed
        ? const <String>[]
        : suggestLocations(_query.text);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _query,
                  decoration: const InputDecoration(
                    labelText: '縣市名稱',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _canSubmit ? _submit : null,
                child: const Text('確認'),
              ),
            ],
          ),
          if (suggestions.isNotEmpty)
            // 高度上限讓建議清單不會把下方的顯示區塊擠掉：符合「臺」的有四個縣市。
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final name in suggestions)
                    ListTile(title: Text(name), onTap: () => _pick(name)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
