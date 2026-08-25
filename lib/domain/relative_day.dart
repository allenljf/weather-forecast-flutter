/// 把預報時段的時間點以「今日／明日／後天 + HH:mm」呈現。（Q19）
///
/// 今明 36 小時預報最多跨到後天，只需要三個詞，因此不引入 `intl`。
/// 相對日一律以**日曆日**相減，不用 24 小時的時間差——否則 23:59 與隔天 00:05
/// 只差 6 分鐘卻分屬兩天的情況會被算成同一天。
String formatRelativeDayTime(DateTime time, {required DateTime now}) {
  final label = _relativeDayLabels[_calendarDaysBetween(now, time)];
  final clock = _clock(time);
  return label == null ? '${time.month}/${time.day} $clock' : '$label $clock';
}

const _relativeDayLabels = <int, String>{0: '今日', 1: '明日', 2: '後天'};

int _calendarDaysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

String _clock(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';
