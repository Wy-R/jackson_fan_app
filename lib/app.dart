import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'features/shell/home_shell.dart';

class JacksonFanApp extends StatelessWidget {
  const JacksonFanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jackson Fan App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary, // 黄,派生出一套协调色
          brightness: Brightness.dark, // 你是深色调,这里要 dark
          surface: AppColors.background,
        ),
        useMaterial3: true,
        fontFamily: 'Space Mono',
        fontFamilyFallback: const ['DM Sans'],
      ),
      // 调试首页时先绕过开屏页。要恢复开屏页时改回 WelcomeScreen。
      home: const HomeShell(),
    );
  }
}
