import 'package:flutter/material.dart';

class WorkDetailPage extends StatelessWidget {
  const WorkDetailPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('$title 的详情页之后放封面、简介和外链。'),
      ),
    );
  }
}
