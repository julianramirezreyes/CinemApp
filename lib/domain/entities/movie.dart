import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final List<String> genreIds; // Simplified for list view

  // Details fields (nullable as they might not be fetched in list view)
  final int? runtime;
  final int? budget;
  final List<String>? genres;
  final List<String>? productionCompanies;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    this.genreIds = const [],
    this.runtime,
    this.budget,
    this.genres,
    this.productionCompanies,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    overview,
    posterPath,
    backdropPath,
    releaseDate,
    voteAverage,
    genreIds,
    runtime,
    budget,
    genres,
    productionCompanies,
  ];
}
