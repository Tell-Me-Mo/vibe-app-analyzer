import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String id;
  final String email;

  @JsonKey(name: 'display_name')
  final String? displayName;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  final int credits;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(name: 'has_seen_welcome')
  final bool hasSeenWelcome;

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.credits,
    required this.createdAt,
    required this.updatedAt,
    this.hasSeenWelcome = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    int? credits,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasSeenWelcome,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      credits: credits ?? this.credits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
    );
  }
}
