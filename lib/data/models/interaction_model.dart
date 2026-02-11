import '../../domain/entities/interaction.dart';

class InteractionModel extends Interaction {
  const InteractionModel({
    super.id,
    required super.profileId,
    required super.movieId,
    required super.status,
    required super.updatedAt,
  });

  factory InteractionModel.fromJson(Map<String, dynamic> json) {
    return InteractionModel(
      id: json['id'],
      profileId: json['profile_id'],
      movieId: json['movie_id'],
      status: _parseStatus(json['status']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'profile_id': profileId,
      'movie_id': movieId,
      'status': status.name, // 'watched' or 'ignored'
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static InteractionStatus _parseStatus(String status) {
    switch (status) {
      case 'watched':
        return InteractionStatus.watched;
      case 'ignored':
        return InteractionStatus.ignored;
      default:
        return InteractionStatus.none;
    }
  }
}
