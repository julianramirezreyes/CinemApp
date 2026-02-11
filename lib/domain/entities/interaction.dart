import 'package:equatable/equatable.dart';

enum InteractionStatus { watched, ignored, none }

class Interaction extends Equatable {
  final String? id;
  final String profileId;
  final int movieId;
  final InteractionStatus status;
  final DateTime updatedAt;

  const Interaction({
    this.id,
    required this.profileId,
    required this.movieId,
    required this.status,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, profileId, movieId, status, updatedAt];
}
