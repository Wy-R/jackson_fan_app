import 'package:flutter/material.dart';

/// 可复用的进场动画:延迟一小段时间后,从下方稍微「上滑 + 淡入」。
///
/// ```dart
/// EntranceAnimation(child: SomeCard())
/// ```
///
/// 只在「挂载时播放一次」。配合 HomeShell 的 AnimatedSwitcher:
/// 每次切回某个 tab,该页会重建 → 本组件重新挂载 → 进场动画自动重播。
class EntranceAnimation extends StatefulWidget {
  const EntranceAnimation({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 200),
    this.duration = const Duration(milliseconds: 500),
    this.beginOffset = const Offset(0, 0.15),
    this.curve = Curves.easeOut,
  });

  /// 要做进场动画的内容。
  final Widget child;

  /// 开始播放前的延迟。
  final Duration delay;

  /// 动画时长。
  final Duration duration;

  /// 起始位移(相对自身大小的比例,(0, 0.15) = 起始在下方 15% 处)。
  final Offset beginOffset;

  /// 缓动曲线。
  final Curve curve;

  @override
  State<EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<EntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _offset = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero)
        .animate(curved);

    // 延迟后开播;回调时先判断页面是否还在。
    Future.delayed(widget.delay, () {
      if (!mounted) return;
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
