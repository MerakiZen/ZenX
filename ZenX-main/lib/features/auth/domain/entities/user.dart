import '../../../../core/domain/entity.dart';

/// User entity (from Auth Service)
class User extends Entity {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, email, name, avatarUrl, createdAt, updatedAt];
}

