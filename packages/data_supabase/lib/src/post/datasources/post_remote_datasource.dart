import 'dart:io';

import 'package:domain/post.dart';

import '../models/post_display_model.dart';

abstract interface class PostRemoteDatasource {
  Future<List<PostDisplayModel>> getPosts({
    required int limit,
    required int offset,
  });

  Future<PostDisplayModel> createPost({
    required String title,
    required String content,
    String? postId,
    String? imageUrl,
  });
  Future<ImageUploadResult> uploadPostImage({
    required File image,
    String? postId,
  });
}
