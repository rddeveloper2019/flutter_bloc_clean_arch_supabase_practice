import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../post.dart';

class CreatePostParams extends Equatable {
  const CreatePostParams({
    required this.title,
    required this.content,
    this.postId,
    this.imageUrl,
  });

  final String title;
  final String content;
  final String? postId;
  final String? imageUrl;

  @override
  List<Object?> get props => [title, content, postId, imageUrl];
}

class CreatePostUsecase implements UseCase<PostDisplay, CreatePostParams> {
  CreatePostUsecase({required PostRepository postRepository})
    : _postRepository = postRepository;
  final PostRepository _postRepository;

  @override
  Future<Either<Failure, PostDisplay>> call(CreatePostParams params) {
    return _postRepository.createPost(
      title: params.title,
      content: params.content,
      postId: params.postId,
      imageUrl: params.imageUrl,
    );
  }
}
