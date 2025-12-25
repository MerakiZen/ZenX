import '../../../../core/domain/entity.dart';
import '../../../auth/domain/entities/user.dart';

/// Suggested athlete entity - for suggested profiles
class SuggestedAthlete extends Entity {
  final String id;
  final User user;
  final String? reason; // e.g., "Featured", "Mutual", "Popular"
  final int? mutualFollowersCount;

  const SuggestedAthlete({
    required this.id,
    required this.user,
    this.reason,
    this.mutualFollowersCount,
  });

  @override
  List<Object?> get props => [
        id,
        user,
        reason,
        mutualFollowersCount,
      ];
}







