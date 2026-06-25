import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/section_title.dart';
import 'models/day_period.dart';
import 'models/period_content.dart';
import 'services/music_service.dart';
import 'widgets/period_greeting.dart';
import 'widgets/recommend_swiper.dart';

/// 音乐页:底部导航「音乐」tab 对应的页面。
///
/// 已实现:顶部标题 + 时段问候 + 时段推荐卡片(堆叠 swiper)。
/// 数据通过 [MusicService] 异步加载,用 [FutureBuilder] 处理加载态。
class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  static const _service = MusicService();

  /// 进入页面时按当前系统时间确定时段(整页生命周期内固定)。
  final _period = MusicPeriod.current();

  /// 数据加载 Future。放在 initState 里只创建一次,避免 build 重复触发加载。
  late final Future<Map<MusicPeriod, PeriodContent>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.loadPeriods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TitleBar(),
              const SizedBox(height: 28),
              PeriodGreeting(period: _period),
              const SizedBox(height: 24),
              // 推荐卡片区:占据剩余空间。
              Expanded(child: _buildSwiperArea()),
            ],
          ),
        ),
      ),
    );
  }

  /// 根据加载状态渲染推荐卡片区。
  Widget _buildSwiperArea() {
    return FutureBuilder<Map<MusicPeriod, PeriodContent>>(
      future: _future,
      builder: (context, snapshot) {
        // 加载中
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // 取当前时段的歌池
        final content = snapshot.data?[_period];
        final pool = content?.songs ?? const [];

        if (pool.isEmpty) {
          return Center(
            child: Text(
              '暂无推荐',
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
            ),
          );
        }

        return RecommendSwiper(period: _period, pool: pool);
      },
    );
  }
}

/// 顶部标题栏。
class _TitleBar extends StatelessWidget {
  const _TitleBar();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SectionTitle(eyebrow: 'MUSIC', title: '音乐'),
      ],
    );
  }
}
