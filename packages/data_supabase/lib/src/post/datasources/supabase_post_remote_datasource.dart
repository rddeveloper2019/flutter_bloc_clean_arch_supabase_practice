import 'dart:io';

import 'package:core/constants.dart';
import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/post_display_model.dart';
import 'post_remote_datasource.dart';

class SupabasePostRemoteDatasource implements PostRemoteDatasource {
  SupabasePostRemoteDatasource({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  Future<List<PostDisplayModel>> getPosts({
    required int limit,
    required int offset,
  }) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }

      final to = offset + limit - 1;
      final postsMaps = await _supabaseClient
          .from(Views.postDisplayView)
          .select()
          .order('post_created_at', ascending: false)
          .range(offset, to);

      return postsMaps.map((p) => PostDisplayModel.fromJson(p)).toList();
    } on AuthenticationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == PostgresErrors.insufficientPrivilege) {
        throw PermissionException(message: e.message);
      }

      throw DatabaseException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<PostDisplayModel> createPost({
    required String title,
    required String content,
    String? postId,
    String? imageUrl,
  }) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }

      final finalPostId = postId ?? const Uuid().v4();
      final result = await _supabaseClient
          .rpc(
            DBFunctions.createPostAndReturnPostDisplayView,
            params: {
              "p_post_id": finalPostId,
              "p_title": title,
              "p_content": content,
              "p_image_url": imageUrl,
            },
          )
          .single();

      return PostDisplayModel.fromJson(result);
    } on AuthenticationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == PostgresErrors.insufficientPrivilege) {
        throw PermissionException(message: e.message);
      }

      if (e.code == PostgresErrors.moreThanOneOrNoItemsReturned) {
        throw NotFoundException(message: e.message);
      }

      throw DatabaseException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<ImageUploadResult> uploadPostImage({
    required File image,
    String? postId,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;

      if (userId == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated for image upload',
        );
      }
      final finalPostId = postId ?? const Uuid().v4();
      final imageExtension = image.path.split('.').last.toLowerCase();
      final imageFileName = '${const Uuid().v4()}.$imageExtension';
      final imagePath = 'public/$userId/$finalPostId/$imageFileName';

      await _supabaseClient.storage
          .from(Storage.postImages)
          .upload(imagePath, image);

      final imageUrl = _supabaseClient.storage
          .from(Storage.postImages)
          .getPublicUrl(imagePath);

      return ImageUploadResult(postId: finalPostId, imageUrl: imageUrl);
    } on AuthenticationException {
      rethrow;
    } on StorageException catch (e) {
      throw StorageServerException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }
}
