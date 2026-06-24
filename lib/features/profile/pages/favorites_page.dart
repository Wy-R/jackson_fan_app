import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/models/favorite.dart';
import '../../../core/services/favorites_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/sub_page.dart';

/// 我的收藏:二级页面(从「我的」push 进来)。
///
/// 加载本地收藏记录，展示截图 + 日期，支持左滑删除。
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  static const _favoritesService = FavoritesService();

  List<Favorite> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final list = await _favoritesService.loadAll();
    if (mounted) {
      setState(() {
        _favorites = list;
        _loading = false;
      });
    }
  }

  Future<void> _removeFavorite(Favorite fav) async {
    await _favoritesService.remove(fav.id);
    await _loadFavorites();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已取消收藏'), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: '我的收藏',
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _favorites.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.heart, size: 48, color: AppColors.border),
          const SizedBox(height: 16),
          Text(
            '还没有收藏',
            style: TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '在每日一言中点击心形按钮收藏',
            style: TextStyle(
              color: AppColors.mutedForeground.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final fav = _favorites[index];
        return _FavoriteCard(
          favorite: fav,
          onRemove: () => _removeFavorite(fav),
        );
      },
    );
  }
}

/// 单张收藏卡片：截图 + 日期 + 出处。
class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.favorite,
    required this.onRemove,
  });

  final Favorite favorite;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(favorite.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(LucideIcons.trash_2, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 截图
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.file(
                  File(favorite.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.input,
                    child: const Center(
                      child: Icon(LucideIcons.image_off, color: AppColors.mutedForeground),
                    ),
                  ),
                ),
              ),
            ),
            // 底部信息
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(LucideIcons.calendar, size: 14, color: AppColors.mutedForeground),
                  const SizedBox(width: 6),
                  Text(
                    favorite.date,
                    style: TextStyle(
                      fontFamily: 'Barlow Condensed',
                      color: AppColors.mutedForeground,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      favorite.source,
                      style: TextStyle(
                        fontFamily: 'Barlow Condensed',
                        color: AppColors.mutedForeground,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
