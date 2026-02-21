import 'package:json_annotation/json_annotation.dart';
import 'package:domain/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_model.g.dart';

@JsonSerializable(createToJson: false)
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.role,
    super.avatarUrl,
  });

  factory UserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? {};

    return UserModel(
      id: user.id,
      username: metadata['username'] ?? '',
      role: metadata['role'] ?? 'user',
      avatarUrl: metadata['avatar_url'],
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @JsonKey(name: 'avatar_url')
  @override
  String? get avatarUrl;
}
