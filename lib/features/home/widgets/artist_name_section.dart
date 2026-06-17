import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// 艺人名字模块:屏幕中部的大号艺人名。
///
/// 占位版本:显示"JACKSON WANG"大字,样式待细化。
class ArtistNameSection extends StatelessWidget {
  const ArtistNameSection({super.key});

  @override
  Widget build(BuildContext context) {

    final nameStyle = GoogleFonts.anton(
      fontSize: 50,
      fontWeight: FontWeight.w700,
      letterSpacing: 3,
      height: 1.0 // 行高收紧,让两行名字贴近
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,  // 整列靠左 ← 关键
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '★ ARTIST · CREATOR · TEAM WANG',
            style: GoogleFonts.barlowCondensed(
              fontSize: 10,
              color: AppColors.accent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'JACKSON',
            style: nameStyle.copyWith(color: AppColors.foreground),
          ),
         
          Text(
            'WANG',
            style: nameStyle.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
