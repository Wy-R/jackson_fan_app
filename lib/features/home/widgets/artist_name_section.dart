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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TODO: 用粗体特殊字体显示"JACKSON WANG"
          Text(
            'JACKSON WANG',
            style: GoogleFonts.anton(
              fontSize: 48,
              color: AppColors.foreground,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
