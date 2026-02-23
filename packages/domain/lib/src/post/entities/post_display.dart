import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class PostDisplay extends Equatable {
  PostDisplay({
    required this.postId,
    required this.title,
    required this.content,
    required this.postCreatedAt,
    required this.postUpdatedAt,
    required this.authorId,
    required this.authorUsername,
    required this.authorRole,
    required this.likesCount,
    required this.commentsCount,
    required this.currentUserLiked,
    this.imageUrl,
    this.authorAvatarUrl,
  });

  final String postId;
  final String title;
  final String content;
  final DateTime postCreatedAt;
  final DateTime postUpdatedAt;
  final String authorId;
  final String authorUsername;
  final String authorRole;
  final int likesCount;
  final int commentsCount;
  final bool currentUserLiked;
  final String? imageUrl;
  final String? authorAvatarUrl;

  @override
  List<Object?> get props => [
    postId,
    title,
    content,
    postCreatedAt,
    postUpdatedAt,
    authorId,
    authorUsername,
    authorRole,
    likesCount,
    commentsCount,
    currentUserLiked,
    imageUrl,
    authorAvatarUrl,
  ];
  PostDisplay copyWith({
    String? postId,
    String? title,
    String? content,
    DateTime? postCreatedAt,
    DateTime? postUpdatedAt,
    String? authorId,
    String? authorUsername,
    String? authorRole,
    int? likesCount,
    int? commentsCount,
    bool? currentUserLiked,
    String? Function()? imageUrl,
    String? Function()? authorAvatarUrl,
  }) {
    return PostDisplay(
      postId: postId ?? this.postId,
      title: title ?? this.title,
      content: content ?? this.content,
      postCreatedAt: postCreatedAt ?? this.postCreatedAt,
      postUpdatedAt: postUpdatedAt ?? this.postUpdatedAt,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      authorRole: authorRole ?? this.authorRole,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      currentUserLiked: currentUserLiked ?? this.currentUserLiked,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      authorAvatarUrl: authorAvatarUrl != null
          ? authorAvatarUrl()
          : this.authorAvatarUrl,
    );
  }
}
