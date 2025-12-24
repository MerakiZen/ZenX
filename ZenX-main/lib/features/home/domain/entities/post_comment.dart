import '../../../../core/domain/entity.dart';
import '../../../auth/domain/entities/user.dart';

/// Post comment entity
class PostComment extends Entity {
  final String id;
  final String postId;
  final User author;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostComment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        postId,
        author,
        content,
        createdAt,
        updatedAt,
      ];

  factory PostComment.fromGraphql(Map<String, dynamic> json) {
    DateTime _parse(String value) => DateTime.parse(value).toLocal();
    final profile = json['authorProfile'] as Map<String, dynamic>?;
    final user = User(
      id: json['userId'] as String,
      email: '${json['userId']}@zenx.local',
      name: (profile?['displayName'] as String?) ?? 'Athlete',
      avatarUrl: profile?['avatarUrl'] as String?,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return PostComment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      author: user,
      content: json['body'] as String? ?? '',
      createdAt: _parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: _parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}







