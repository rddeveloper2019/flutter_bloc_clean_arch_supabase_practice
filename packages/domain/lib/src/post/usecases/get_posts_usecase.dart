import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/post_display.dart';
import '../repositories/post_repository.dart';

class GetPostsParams extends Equatable {
  const GetPostsParams({required this.offset, this.limit = 10});

  final int offset;
  final int limit;

  @override
  List<Object?> get props => [offset, limit];
}

class GetPostsUsecase implements UseCase<List<PostDisplay>, GetPostsParams> {
  const GetPostsUsecase({required PostRepository postRepository})
    : _postRepository = postRepository;
  final PostRepository _postRepository;

  @override
  Future<Either<Failure, List<PostDisplay>>> call(GetPostsParams params) {
    return _postRepository.getPosts(limit: params.limit, offset: params.offset);
  }
}
