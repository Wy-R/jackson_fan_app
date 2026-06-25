import 'package:flutter_test/flutter_test.dart';
import 'package:jackson_fan_app/features/music/models/day_period.dart';
import 'package:jackson_fan_app/features/music/services/music_service.dart';

void main() {
  // MusicPeriod.fromHour 是纯函数，直接验证时段边界。
  group('MusicPeriod.fromHour', () {
    test('06:00–11:59 → 早晨', () {
      expect(MusicPeriod.fromHour(6), MusicPeriod.morning);
      expect(MusicPeriod.fromHour(11), MusicPeriod.morning);
    });

    test('12:00–17:59 → 午后', () {
      expect(MusicPeriod.fromHour(12), MusicPeriod.afternoon);
      expect(MusicPeriod.fromHour(17), MusicPeriod.afternoon);
    });

    test('18:00–05:59（跨午夜）→ 夜间', () {
      expect(MusicPeriod.fromHour(18), MusicPeriod.night);
      expect(MusicPeriod.fromHour(23), MusicPeriod.night);
      expect(MusicPeriod.fromHour(0), MusicPeriod.night);
      expect(MusicPeriod.fromHour(5), MusicPeriod.night);
    });
  });

  // MusicService 从 assets 读 JSON。需要初始化测试绑定才能用 rootBundle。
  group('MusicService.loadPeriods', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    const service = MusicService();

    test('能读到三个时段，且每段歌单 ≥5 首', () async {
      final map = await service.loadPeriods();

      // 三个时段都有
      expect(map.keys.toSet(), MusicPeriod.values.toSet());

      // 每段歌池足够支撑「推荐 5 首 + 换一换」
      for (final period in MusicPeriod.values) {
        expect(map[period]!.songs.length, greaterThanOrEqualTo(5),
            reason: '${period.name} 歌池不足 5 首');
      }
    });

    test('文案与 JSON 一致（早晨）', () async {
      final map = await service.loadPeriods();
      final morning = map[MusicPeriod.morning]!;

      expect(morning.label, '早晨');
      expect(morning.emoji, '🌅');
      expect(morning.description, '新的一天，先来点节奏');
      expect(morning.songs.first.title, '100 Ways');
    });
  });
}
