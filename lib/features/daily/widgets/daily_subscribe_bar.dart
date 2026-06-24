import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 底部订阅提示条:展示「每日推送已开启」及推送时间,右侧带开关状态。
///
/// 骨架版本:静态展示。后续接入本地通知开关后,ON/OFF 由真实状态驱动。
class DailySubscribeBar extends StatelessWidget {
  const DailySubscribeBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          // 左侧:标题 + 副标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '每日推送已开启',
                  style: TextStyle(
                    color: AppColors.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Barlow Condensed',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '每天 09:00 一句王嘉尔语录',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // 右侧:ON 状态(占位,后续接开关)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'ON',
                style: TextStyle(
                  color: AppColors.foreground,
                  fontSize: 12,
                  fontWeight: AppColors.fontWeightMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
