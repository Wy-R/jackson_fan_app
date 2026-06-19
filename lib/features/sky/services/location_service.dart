import 'package:geolocator/geolocator.dart';

/// 设备定位服务:请求权限并获取当前经纬度。
///
/// 只负责「拿到坐标」这一件事;拿不到时抛异常,由调用方(WeatherService)
/// 决定如何降级(如回退到默认城市)。
class LocationService {
  const LocationService();

  /// 获取当前位置经纬度。任一环节失败(服务未开/权限被拒/超时)都会抛异常。
  Future<({double lat, double lon})> getCurrentCoordinates() async {
    // 1. 定位服务是否开启(系统级开关)
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('定位服务未开启');
    }

    // 2. 检查/请求权限
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('定位权限被拒绝');
    }

    // 3. 取当前位置
    final pos = await Geolocator.getCurrentPosition();
    return (lat: pos.latitude, lon: pos.longitude);
  }
}
