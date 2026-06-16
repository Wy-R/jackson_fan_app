import 'package:flutter/material.dart';

import '../../core/widgets/app_section_title.dart';
import '../gallery/gallery_page.dart';
import '../works/works_page.dart';
import 'widgets/hero_banner.dart';
import 'widgets/latest_updates.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const HeroBanner(),
            const SizedBox(height: 28),
            const AppSectionTitle(title: '快速入口'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _HomeShortcut(
                  icon: Icons.album_outlined,
                  label: '作品集',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const WorksPage()),
                  ),
                ),
                _HomeShortcut(
                  icon: Icons.photo_library_outlined,
                  label: '相册',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const GalleryPage(),
                    ),
                  ),
                ),
                const _HomeShortcut(
                  icon: Icons.timeline_outlined,
                  label: '时间轴',
                ),
                const _HomeShortcut(icon: Icons.favorite_border, label: '收藏'),
              ],
            ),
            const SizedBox(height: 28),
            const LatestUpdates(),
          ],
        ),
      ),
    );
  }
}

class _HomeShortcut extends StatelessWidget {
  const _HomeShortcut({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
