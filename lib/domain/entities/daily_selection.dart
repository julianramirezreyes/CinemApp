import 'package:equatable/equatable.dart';
import 'movie.dart';

class DailySelection extends Equatable {
  final String? id;
  final String profileId;
  final DateTime date;
  final List<Movie> movies;

  const DailySelection({
    this.id,
    required this.profileId,
    required this.date,
    required this.movies,
  });

  @override
  List<Object?> get props => [id, profileId, date, movies];
}
