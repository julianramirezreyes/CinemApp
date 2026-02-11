import 'package:equatable/equatable.dart';
import 'movie.dart';

class DailySelection extends Equatable {
  final String? id;
  final String profileId;
  final DateTime date;
  final List<Movie> movies;
  final int remainingRefreshes;
  final List<int> shownMovieIds;

  const DailySelection({
    this.id,
    required this.profileId,
    required this.date,
    required this.movies,
    this.remainingRefreshes = 3,
    this.shownMovieIds = const [],
  });

  @override
  List<Object?> get props => [
    id,
    profileId,
    date,
    movies,
    remainingRefreshes,
    shownMovieIds,
  ];
}
