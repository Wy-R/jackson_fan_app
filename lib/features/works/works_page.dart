import 'package:flutter/material.dart';

import 'work_detail_page.dart';
import 'widgets/work_card.dart';

class WorksPage extends StatelessWidget {
  const WorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('作品集')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          return WorkCard(
            title: '作品 ${index + 1}',
            subtitle: '之后从 assets/data/works.json 读取',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => WorkDetailPage(title: '作品 ${index + 1}'),
              ),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemCount: 3,
      ),
    );
  }
}
