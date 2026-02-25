import 'dart:io';

import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:fpdart/fpdart.dart';

import '../../../post.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({required PostRemoteDatasource postRemoteDatasource})
    : _postRemoteDatasource = postRemoteDatasource;

  final PostRemoteDatasource _postRemoteDatasource;

  @override
  Future<Either<Failure, List<PostDisplay>>> getPosts({
    required int limit,
    required int offset,
  }) async {
    try {
      final posts = await _postRemoteDatasource.getPosts(
        limit: limit,
        offset: offset,
      );
      return Right(posts);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnknownFailure catch (e) {
      return Left(UnknownFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PostDisplay>> createPost({
    String? postId,
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final post = await _postRemoteDatasource.createPost(
        postId: postId,
        title: title,
        content: content,
        imageUrl: imageUrl,
      );

      return Right(post);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ImageUploadResult>> uploadPostImage({
    required File image,
    String? postId,
  }) async {
    try {
      final imageUploadResult = await _postRemoteDatasource.uploadPostImage(
        image: image,
        postId: postId,
      );
      return Right(imageUploadResult);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on StorageServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(message: e.message));
    }
  }
}
