import '../../domain/entities/daily_selection.dart';
import '../../domain/entities/movie.dart';

class DailySelectionModel extends DailySelection {
  const DailySelectionModel({
    super.id,
    required super.profileId,
    required super.date,
    required super.movies,
    required super.remainingRefreshes,
    required super.shownMovieIds,
  });

  factory DailySelectionModel.fromJson(
    Map<String, dynamic> json,
    List<Movie> movies,
  ) {
    return DailySelectionModel(
      id: json['id'],
      profileId: json['profile_id'],
      date: DateTime.parse(json['date']),
      movies: movies,
      remainingRefreshes: json['remaining_refreshes'] ?? 3,
      shownMovieIds: json['shown_movie_ids'] != null
          ? List<int>.from(json['shown_movie_ids'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'profile_id': profileId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      'movie_ids': movies.map((m) => m.id).toList(),
      'remaining_refreshes': remainingRefreshes,
      'shown_movie_ids': shownMovieIds,
    };
  }
}
