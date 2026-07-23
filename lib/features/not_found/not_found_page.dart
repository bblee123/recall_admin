import 'package:flutter/material.dart';

/// 404 页（对照 Vue 项目 NotFound/index.vue）。
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('notFound')),
    );
  }
}
