/// 日期格式化工具(纯函数,无第三方依赖)。
///
/// 简单格式自己拼即可,无需引入 intl 等包。需要本地化/复杂模板时再考虑。
library;

/// 月份英文缩写表(下标 0 = 1 月)。
const _monthAbbr = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
];

/// 格式化成 "JUN 19" 形式(月份英文缩写 + 日)。
///
/// [padDay] 为 true 时日补零,如 "JUN 09";默认 false → "JUN 9"。
String formatMonthDay(DateTime date, {bool padDay = false}) {
  final month = _monthAbbr[date.month - 1];
  final day = padDay ? date.day.toString().padLeft(2, '0') : '${date.day}';
  return '$month $day';
}
