import 'package:flutter/material.dart';

import '../../core/widgets/image_card.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('相册')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          return ImageCard(
            title: '照片 ${index + 1}',
            subtitle: '之后接入 gallery.json',
          );
        },
        itemCount: 8,
      ),
    );
  }
}
