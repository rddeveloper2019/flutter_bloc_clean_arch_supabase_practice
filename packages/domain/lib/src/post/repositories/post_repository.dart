import 'dart:io';

import 'package:core/errors.dart';
import 'package:fpdart/fpdart.dart';

import '../../../post.dart';

abstract class PostRepository {
  Future<Either<Failure, List<PostDisplay>>> getPosts({
    required int limit,
    required int offset,
  });
  Future<Either<Failure, PostDisplay>> createPost({
    required String title,
    required String content,
    String? postId,
    String? imageUrl,
  });
  Future<Either<Failure, ImageUploadResult>> uploadPostImage({
    required File image,
    String? postId,
  });
}
