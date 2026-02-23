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
}
