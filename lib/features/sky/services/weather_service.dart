import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather.dart';
import 'location_service.dart';

/// 天气数据服务(数据源:Open-Meteo,免费、无需 key)。
///
/// 流程:先尝试定位拿当前坐标 → 拿天气;定位失败(未开/拒绝/超时)则
/// **优雅降级**到默认城市(上海),保证天气功能始终可用。
class WeatherService {
  WeatherService({this._location = const LocationService()});

  final LocationService _location;

  // 默认城市(定位失败时的兜底)
  static const _defaultLat = 31.23;
  static const _defaultLon = 121.47;
  static const _defaultCity = '上海';

  // 简单内存缓存:1 小时内重复请求直接返回上次结果,省调用。
  Weather? _cache;
  DateTime? _cacheAt;
  static const _cacheTtl = Duration(hours: 1);

  Future<Weather> loadWeather() async {
    // 命中有效缓存则直接返回
    final cachedAt = _cacheAt;
    if (_cache != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cacheTtl) {
      return _cache!;
    }

    // 尝试定位;失败则降级到默认城市
    double lat;
    double lon;
    String city;
    try {
      final coord = await _location.getCurrentCoordinates();
      lat = coord.lat;
      lon = coord.lon;
      city = '当前位置';
    } catch (_) {
      lat = _defaultLat;
      lon = _defaultLon;
      city = _defaultCity;
    }

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,weather_code',
    );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('天气请求失败: ${res.statusCode}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final weather = Weather.fromJson(json, city: city);

    // 写入缓存
    _cache = weather;
    _cacheAt = DateTime.now();
    return weather;
  }
}
