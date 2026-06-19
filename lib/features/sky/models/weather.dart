/// 天气数据模型。
///
/// 数据源 Open-Meteo 的 current 字段:temperature_2m(温度)、weather_code
/// (天气代码,WMO 标准)。代码需自行映射成中文描述 + emoji 图标。
class Weather {
  const Weather({
    required this.temperature,
    required this.code,
    required this.city,
  });

  /// 当前温度(摄氏度)。
  final double temperature;

  /// WMO 天气代码。
  final int code;

  /// 城市名(本地传入,接口不返回)。
  final String city;

  /// 从 Open-Meteo 的 JSON 解析。传入 city 因为接口本身不带城市名。
  factory Weather.fromJson(Map<String, dynamic> json, {required String city}) {
    final current = json['current'] as Map<String, dynamic>;
    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      code: current['weather_code'] as int,
      city: city,
    );
  }

  /// 温度取整后的展示文本,如 "24°C"。
  String get temperatureText => '${temperature.round()}°C';

  /// 中文天气描述(按 WMO 代码映射)。
  String get description => _weatherInfo(code).$1;

  /// 天气 emoji 图标。
  String get emoji => _weatherInfo(code).$2;
}

/// WMO weather_code → (中文描述, emoji)。
/// 参考 https://open-meteo.com 的 weather code 定义,按区间归类。
(String, String) _weatherInfo(int code) {
  if (code == 0) return ('晴', '☀️');
  if (code <= 2) return ('多云', '⛅');
  if (code == 3) return ('阴', '☁️');
  if (code <= 48) return ('雾', '🌫️');
  if (code <= 57) return ('毛毛雨', '🌦️');
  if (code <= 65) return ('小雨', '🌧️');
  if (code <= 67) return ('冻雨', '🌧️');
  if (code <= 77) return ('雪', '🌨️');
  if (code <= 82) return ('阵雨', '🌧️');
  if (code <= 86) return ('阵雪', '🌨️');
  if (code <= 99) return ('雷雨', '⛈️');
  return ('未知', '🌡️');
}
