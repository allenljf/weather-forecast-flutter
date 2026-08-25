/// 天氣分類：把氣象署的天氣分類代碼收斂成畫面用得上的六類。（Q11）
///
/// 分桶依據是官方「預報產品天氣描述代碼表」（D0047.pdf，2026-08-25 取得）：
/// 官方已把數百句中文描述收斂成 41 個代碼，這裡只是再把代碼收成六類，
/// 不對中文描述做關鍵字比對。代碼本身也隱含了優先序——同時提到多種天氣時，
/// 官方是以雪 > 霧 > 雷雨 > 雨 > 陰多雲 > 晴 的順序給代碼的，
/// 例如 35「多雲有霧有雷陣雨」與 37「多雲局部雨或雪有霧」分別落在霧與雪。
enum WeatherCategory {
  clear,
  cloudy,
  rain,
  thunderstorm,
  fog,
  snow;

  /// 代碼不在官方表內（例如官方表跳過的 40）時回傳 `null`。
  ///
  /// 這裡刻意不視為格式錯誤：代碼解析得出來，只是本地這張表沒收錄，
  /// 與縣市白名單一樣屬於「可能與上游脫鉤」的靜態資料，
  /// 讓畫面退回中性圖示比整筆預報作廢合理。
  static WeatherCategory? forCode(int code) => _byCode[code];

  static const _byCode = <int, WeatherCategory>{
    // 晴：1–3，描述以「晴」為主體。
    1: clear,
    2: clear,
    3: clear,
    // 多雲陰：4–7，從多雲一路到陰天，無降水。
    4: cloudy,
    5: cloudy,
    6: cloudy,
    7: cloudy,
    // 雨：陰晴各色的降雨（8–14）、午後降雨（19–20）、局部降雨（29–30）。
    8: rain,
    9: rain,
    10: rain,
    11: rain,
    12: rain,
    13: rain,
    14: rain,
    19: rain,
    20: rain,
    29: rain,
    30: rain,
    // 雷雨：與上面三組雨一一對應的帶雷版本（15–18、21–22、33–34）。
    15: thunderstorm,
    16: thunderstorm,
    17: thunderstorm,
    18: thunderstorm,
    21: thunderstorm,
    22: thunderstorm,
    33: thunderstorm,
    34: thunderstorm,
    // 霧：純霧（24–28）、霧加雨（31、32、38、39）、霧加雷雨（35、36、41）。
    24: fog,
    25: fog,
    26: fog,
    27: fog,
    28: fog,
    31: fog,
    32: fog,
    35: fog,
    36: fog,
    38: fog,
    39: fog,
    41: fog,
    // 雪：只要提到雪就歸雪，即使同時有霧（37）。
    23: snow,
    37: snow,
    42: snow,
  };
}
