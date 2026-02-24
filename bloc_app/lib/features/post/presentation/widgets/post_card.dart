import 'package:domain/post.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.onToggleLike});
  final PostDisplay post;
  final void Function() onToggleLike;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
