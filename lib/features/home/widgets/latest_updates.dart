import 'package:flutter/material.dart';

import '../../../core/widgets/app_section_title.dart';

class LatestUpdates extends StatelessWidget {
  const LatestUpdates({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(title: '最新动态'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '之后这里会从本地 JSON 读取动态内容。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
