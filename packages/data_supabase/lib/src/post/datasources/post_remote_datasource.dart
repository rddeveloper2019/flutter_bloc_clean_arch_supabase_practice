import '../models/post_display_model.dart';

abstract interface class PostRemoteDatasource {
  Future<List<PostDisplayModel>> getPosts({
    required int limit,
    required int offset,
  });
}
