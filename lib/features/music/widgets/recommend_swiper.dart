import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../models/day_period.dart';
import '../models/song.dart';
import 'song_card.dart';

/// 推荐卡片堆叠：从当前时段歌池里抽若干首，用 [CardSwiper] 堆叠展示。
///
/// 本组件只负责「展示传入的歌单」。抽歌逻辑放在这里的 [initState]，
/// 后续「换一换」会复用同样的抽样方法重新抽。
class RecommendSwiper extends StatefulWidget {
  const RecommendSwiper({
    super.key,
    required this.period,
    required this.pool,
    this.count = 5,
  });

  /// 当前时段（卡片背景渐变按此区分）。
  final MusicPeriod period;

  /// 当前时段的歌池（通常 ≥5 首）。
  final List<Song> pool;

  /// 每次推荐展示几首。
  final int count;

  @override
  State<RecommendSwiper> createState() => _RecommendSwiperState();
}

class _RecommendSwiperState extends State<RecommendSwiper> {
  /// 当前抽中展示的歌曲。
  late List<Song> _picks;

  @override
  void initState() {
    super.initState();
    _picks = _pick();
  }

  /// 从歌池随机抽 [widget.count] 首（池子不足则全取）。
  List<Song> _pick() {
    final pool = List<Song>.of(widget.pool);
    if (pool.length <= widget.count) return pool;
    pool.shuffle(Random());
    return pool.take(widget.count).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_picks.isEmpty) {
      return const SizedBox.shrink();
    }

    // 堆叠展示张数不能超过卡片总数。
    final displayed = min(3, _picks.length);

    return CardSwiper(
      cardsCount: _picks.length,
      numberOfCardsDisplayed: displayed,
      isLoop: true,
      // 只允许左右滑（上下滑动留给页面滚动）。
      allowedSwipeDirection: const AllowedSwipeDirection.only(
        left: true,
        right: true,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      scale: 0.92,
      backCardOffset: const Offset(0, 36),
      cardBuilder: (context, index, _, _) =>
          SongCard(song: _picks[index], period: widget.period),
    );
  }
}
