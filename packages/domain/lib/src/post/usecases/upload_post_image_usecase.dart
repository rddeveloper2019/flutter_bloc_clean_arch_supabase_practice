import 'dart:io';

import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../post.dart';

class UploadPostImageParams extends Equatable {
  const UploadPostImageParams({required this.image, this.postId});

  final File image;
  final String? postId;

  @override
  List<Object?> get props => [image, postId];
}

class UploadPostImageUsecase
    implements UseCase<ImageUploadResult, UploadPostImageParams> {
  const UploadPostImageUsecase({required PostRepository postRepository})
    : _postRepository = postRepository;
  final PostRepository _postRepository;

  @override
  Future<Either<Failure, ImageUploadResult>> call(params) {
    return _postRepository.uploadPostImage(
      image: params.image,
      postId: params.postId,
    );
  }
}
