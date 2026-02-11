import '../../domain/entities/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.releaseDate,
    required super.voteAverage,
    super.genreIds,
    super.runtime,
    super.budget,
    super.genres,
    super.productionCompanies,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'],
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      genreIds: json['genre_ids'] != null
          ? List<String>.from(
              (json['genre_ids'] as List).map((e) => e.toString()),
            )
          : [],
      // Details fields
      runtime: json['runtime'],
      budget: json['budget'],
      genres: json['genres'] != null
          ? List<String>.from((json['genres'] as List).map((e) => e['name']))
          : null,
      productionCompanies: json['production_companies'] != null
          ? List<String>.from(
              (json['production_companies'] as List).map((e) => e['name']),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'genre_ids': genreIds,
      'runtime': runtime,
      'budget': budget,
      'genres': genres,
      'production_companies': productionCompanies,
    };
  }
}
