import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/models/daily_quote.dart';
import '../../../core/services/favorites_service.dart';
import '../../../core/stores/quotes_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/widget_capture.dart';
import '../../../core/widgets/section_title.dart';

/// 每日一言轮播模块:异步加载数据 → 渲染标题区 + 可切换卡片 + 操作区。
///
/// 数据来自 [AssetDataService](现为写死,将来可换 Firebase/接口),
/// 用 FutureBuilder 处理加载态。加载完成后交给 [_SwiperView] 做切换。
class DailyCardSwiper extends StatefulWidget {
  const DailyCardSwiper({super.key});

  @override
  State<DailyCardSwiper> createState() => _DailyCardSwiperState();
}

class _DailyCardSwiperState extends State<DailyCardSwiper> {
  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final quotes = QuotesStore.instance.quotes.value;
      if (quotes.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      return _SwiperView(quotes: quotes);
    });
  }
}

/// 拿到数据后的轮播视图:持有「当前第几张」状态并处理切换。
class _SwiperView extends StatefulWidget {
  const _SwiperView({required this.quotes});

  final List<DailyQuote> quotes;

  @override
  State<_SwiperView> createState() => _SwiperViewState();
}

class _SwiperViewState extends State<_SwiperView> {
  /// 当前展示的卡片索引。
  int _index = 0;

  /// 标记卡片截图区域(放在 AnimatedSwitcher 外层,始终指向当前卡)。
  final _cardKey = GlobalKey();

  /// 当前卡片是否已收藏。
  bool _isFavorited = false;

  static const _favoritesService = FavoritesService();

  bool get _canPrev => _index > 0;
  bool get _canNext => _index < widget.quotes.length - 1;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  /// 检查当前卡片是否已收藏。
  Future<void> _checkFavorite() async {
    final source = widget.quotes[_index].source;
    final fav = await _favoritesService.isFavorited(source);
    if (mounted) setState(() => _isFavorited = fav);
  }

  /// 切换收藏状态：已收藏则取消，未收藏则截图保存。
  Future<void> _toggleFavorite() async {
    final quote = widget.quotes[_index];

    if (_isFavorited) {
      // 取消收藏
      final fav = await _favoritesService.findBySource(quote.source);
      if (fav != null) {
        await _favoritesService.remove(fav.id);
      }
      if (mounted) {
        setState(() => _isFavorited = false);
        _toast('已取消收藏');
      }
    } else {
      // 截图并收藏
      final bytes = await captureBoundaryToPng(_cardKey);
      if (bytes == null) {
        _toast('收藏失败,请重试');
        return;
      }
      await _favoritesService.save(
        imageBytes: bytes,
        source: quote.source,
        lines: quote.lines,
      );
      if (mounted) {
        setState(() => _isFavorited = true);
        _toast('已收藏');
      }
    }
  }

  void _prev() {
    if (_canPrev) {
      setState(() => _index--);
      _checkFavorite();
    }
  }

  void _next() {
    if (_canNext) {
      setState(() => _index++);
      _checkFavorite();
    }
  }

  /// 截取当前卡片为图片并调起系统分享。失败时给出提示。
  Future<void> _share() async {
    try {
      // 1. 卡片渲染成 PNG 字节
      final bytes = await captureBoundaryToPng(_cardKey);
      if (bytes == null) {
        _toast('生成图片失败,请重试');
        return;
      }

      // 2. 写入临时文件(分享需要文件路径)
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/daily_quote_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      // 3. 调起系统分享面板
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: '来自 Jackson Wang 粉丝 App 的每日一言',
        ),
      );
    } catch (e) {
      // 当前平台/环境不支持分享,或截图、写文件出错,统一兜底提示
      _toast('当前环境不支持分享功能');
    }
  }

  /// 截取当前卡片并保存到系统相册。失败/无权限时给出提示。
  Future<void> _download() async {
    try {
      // 1. 卡片渲染成 PNG 字节
      final bytes = await captureBoundaryToPng(_cardKey);
      if (bytes == null) {
        _toast('生成图片失败,请重试');
        return;
      }

      // 2. 直接把字节存进相册(gal 内部会按需请求权限)
      await Gal.putImageBytes(bytes, name: 'daily_quote_${DateTime.now().millisecondsSinceEpoch}');
      _toast('已保存到相册');
    } on GalException catch (e) {
      // gal 的已知异常:多为权限被拒
      _toast(e.type == GalExceptionType.accessDenied ? '没有相册权限,无法保存' : '保存失败');
    } catch (e) {
      _toast('当前环境不支持保存到相册');
    }
  }

  /// 底部轻提示(类似前端 toast)。await 后用 context 前先判断 mounted。
  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 标题区:高度由内容撑开,不固定
        _TitleBar(current: _index + 1, total: widget.quotes.length),
        // 卡片区:撑满中部,上下各留 10
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            // RepaintBoundary 包在 AnimatedSwitcher 外层:
            // GlobalKey 固定指向此边界,截图即当前显示的卡片。
            child: RepaintBoundary(
              key: _cardKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                // 自定义过渡:新卡从右侧滑入 + 淡入(旧卡反向:往左滑出 + 淡出)
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0.15, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: _QuoteCard(
                  // key 变化触发切换动画
                  key: ValueKey(_index),
                  quote: widget.quotes[_index],
                ),
              ),
            ),
          ),
        ),
        // 操作区
        SizedBox(
          height: 56,
          child: _ActionBar(
            canPrev: _canPrev,
            canNext: _canNext,
            isFavorited: _isFavorited,
            onPrev: _prev,
            onNext: _next,
            onShare: _share,
            onDownload: _download,
            onToggleFavorite: _toggleFavorite,
          ),
        ),
      ],
    );
  }
}

/// 标题区:左侧两行标题,右侧当前页码指示(如 1 / 6)。
class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SectionTitle(eyebrow: 'DAILY DROP', title: '每日一言'),
        Text(
          '$current / $total',
          style: TextStyle(
            fontFamily: 'Barlow Condensed',
            color: AppColors.primary,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

/// 单张语录卡:背景图铺满 + 顶部标签/日期 + 底部引文/出处。
class _QuoteCard extends StatelessWidget {
  const _QuoteCard({super.key, required this.quote});

  final DailyQuote quote;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 背景图(支持网络 URL 和本地资源)
          quote.background.startsWith('http')
              ? Image.network(quote.background, fit: BoxFit.cover)
              : Image.asset(quote.background, fit: BoxFit.cover),
          // 底部渐变遮罩,保证文字清晰
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.input,
                  AppColors.background.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          // 内容层
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部:左 LYRICS 标签,右 日期(当前系统日期)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.dot, color: AppColors.primary, size: 14),
                        Text(
                          'DROPS',
                          style: TextStyle(
                            fontFamily: 'Barlow Condensed',
                            color: AppColors.foreground,
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      formatMonthDay(DateTime.now()),
                      style: TextStyle(
                        fontFamily: 'Barlow Condensed',
                        color: AppColors.mutedForeground,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // 底部:引文
                for (final line in quote.lines)
                  Text(
                    line,
                    style: const TextStyle(
                      fontFamily: 'Anton',
                      color: AppColors.foreground,
                      fontSize: 22,
                      height: 1.3,
                    ),
                  ),
                const SizedBox(height: 12),
                // 出处(左) + 水印(右)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(width: 24, height: 1, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          quote.source,
                          style: TextStyle(
                            fontFamily: 'Barlow Condensed',
                            color: AppColors.mutedForeground,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    // 右下角水印
                    Text(
                      '粉丝自制·不可商用',
                      style: TextStyle(
                        color: AppColors.mutedForeground.withValues(alpha: 0.6),
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 操作区:上一张 / 收藏 / 下载 / 分享 / 下一张。
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.canPrev,
    required this.canNext,
    required this.isFavorited,
    required this.onPrev,
    required this.onNext,
    required this.onShare,
    required this.onDownload,
    required this.onToggleFavorite,
  });

  final bool canPrev;
  final bool canNext;
  final bool isFavorited;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onShare;
  final VoidCallback onDownload;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 上一张:到头则禁用
        _SquareButton(
          icon: LucideIcons.chevron_left,
          enabled: canPrev,
          onTap: onPrev,
        ),
        const SizedBox(width: 12),
        // 收藏按钮:已收藏时填充主色
        _CircleButton(
          icon: isFavorited ? LucideIcons.heart : LucideIcons.heart,
          highlight: isFavorited,
          onTap: onToggleFavorite,
        ),
        const SizedBox(width: 12),
        Expanded(child: _DownloadButton(onTap: onDownload)),
        const SizedBox(width: 12),
        _CircleButton(icon: LucideIcons.share_2, onTap: onShare),
        const SizedBox(width: 12),
        // 下一张:可用时高亮(主色),到尾则禁用
        _SquareButton(
          icon: LucideIcons.chevron_right,
          highlight: canNext,
          enabled: canNext,
          onTap: onNext,
        ),
      ],
    );
  }
}

/// 方形描边按钮(上/下一张)。
/// - highlight:主色描边+主色图标
/// - enabled=false:变灰且不可点
class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.onTap,
    this.highlight = false,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final Color borderColor;
    if (!enabled) {
      // 禁用态:整体压暗
      iconColor = AppColors.border;
      borderColor = AppColors.border;
    } else if (highlight) {
      iconColor = AppColors.primary;
      borderColor = AppColors.primary;
    } else {
      iconColor = AppColors.mutedForeground;
      borderColor = AppColors.border;
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(border: Border.all(color: borderColor, width: 0.5)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

/// 圆形描边按钮(收藏/分享)。
/// - highlight:主色填充+主色图标(用于已收藏状态)
class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: highlight ? AppColors.destructive : Colors.transparent,
          border: Border.all(
            color: highlight ? AppColors.destructive : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: highlight ? AppColors.destructiveForeground : AppColors.mutedForeground,
          size: 20,
        ),
      ),
    );
  }
}

/// 下载卡片:黄色实心主按钮(图标 + 文字)。
class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: const BoxDecoration(color: AppColors.primary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.download, color: AppColors.primaryForeground, size: 18),
            const SizedBox(width: 8),
            Text(
              '下载卡片',
              style: TextStyle(
                color: AppColors.primaryForeground,
                fontSize: 14,
                fontWeight: AppColors.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
