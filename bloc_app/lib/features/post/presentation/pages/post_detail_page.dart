import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.postId});

  final String postId;
  @override
  Widget build(BuildContext context) {
    print('(**) => widget.postId:  ${postId}');
    return const PostDetailView();
  }
}

class PostDetailView extends StatelessWidget {
  const PostDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.chevron_left, size: 32),
        ),
        automaticallyImplyLeading: false,
      ),
      body: const Center(child: Text('Post Detail Page View')),
    );
  }
}
