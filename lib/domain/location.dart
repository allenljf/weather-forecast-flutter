/// 臺灣 22 個縣市：天氣預報的唯一查詢單位，也是本專案的輸入正確性來源。
///
/// 上游對不存在的縣市回 200 加空陣列、從不告知輸入錯誤（F11），因此「這個輸入
/// 有沒有效」只能在本地判定。（Q1）
///
/// 來源：<https://opendata.cwa.gov.tw/apidoc/v1> F-C0032-001 的 `locationName`
/// 列舉值，取得日期 2026-08-25。寫死而非線上取得：行政區劃的變動頻率以十年計，
/// 不值得用一次網路往返換即時性。（Q25）
const taiwanLocations = <String>[
  '宜蘭縣',
  '花蓮縣',
  '臺東縣',
  '澎湖縣',
  '金門縣',
  '連江縣',
  '臺北市',
  '新北市',
  '桃園市',
  '臺中市',
  '臺南市',
  '高雄市',
  '基隆市',
  '新竹縣',
  '新竹市',
  '苗栗縣',
  '彰化縣',
  '南投縣',
  '雲林縣',
  '嘉義縣',
  '嘉義市',
  '屏東縣',
];

/// 把查詢字串轉成縣市正式名稱；對應不到任何縣市時回傳 `null`。
String? normaliseQuery(String query) {
  final canonical = _canonicalise(query);
  if (taiwanLocations.contains(canonical)) return canonical;

  // 簡稱補全。「新竹」「嘉義」同時對得上一縣一市，此時不猜——猜錯會讓使用者
  // 拿到另一個縣市的天氣，比查不到更糟；建議清單會把兩個都列出來讓他選。
  final completions = [
    for (final suffix in const ['市', '縣'])
      if (taiwanLocations.contains('$canonical$suffix')) '$canonical$suffix',
  ];
  return completions.length == 1 ? completions.single : null;
}

String _canonicalise(String query) => query.trim().replaceAll('台', '臺');

/// 輸入中即時列出符合的縣市，依 [taiwanLocations] 的順序。
///
/// 用包含比對而非前綴比對：22 個縣市裡有四個以「臺」開頭，前綴比對會讓打「南」
/// 的人找不到臺南市。至少要有一個字才給建議——空輸入不是無效查詢。（Q10）
List<String> suggestLocations(String query) {
  final canonical = _canonicalise(query);
  if (canonical.isEmpty) return const [];
  return [
    for (final name in taiwanLocations)
      if (name.contains(canonical)) name,
  ];
}
