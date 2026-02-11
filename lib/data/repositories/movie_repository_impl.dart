import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/daily_selection.dart';
import '../../domain/entities/interaction.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/tmdb_remote_datasource.dart';
import '../datasources/supabase_datasource.dart';
import '../models/daily_selection_model.dart';
import '../models/interaction_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  final TMDbRemoteDataSource remoteDataSource;
  final SupabaseLocalDataSource localDataSource;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Movie>>> discoverMovies({
    required int page,
    String? language,
  }) async {
    try {
      final result = await remoteDataSource.discoverMovies(page);
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query) async {
    try {
      final result = await remoteDataSource.searchMovies(query);
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Movie>> getMovieDetails(int movieId) async {
    try {
      final result = await remoteDataSource.getMovieDetails(movieId);
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DailySelection?>> getDailySelection(
    DateTime date,
    String profileId,
  ) async {
    try {
      final result = await localDataSource.getDailySelection(profileId, date);
      if (result != null) {
        // Need to fetch full movie details for the IDs?
        // The selection model only stores IDs.
        // We can fetch details from TMDB for these IDs.
        final movieIds = List<int>.from(result['movie_ids']);
        final List<Movie> movies = [];
        for (var id in movieIds) {
          try {
            final movie = await remoteDataSource.getMovieDetails(id);
            movies.add(movie);
          } catch (e) {
            // If one movie fails, we might want to skip or fail?
            // Let's skip for robustness
          }
        }

        return Right(DailySelectionModel.fromJson(result, movies));
      }
      return const Right(null);
    } on DatabaseException {
      return const Left(DatabaseFailure());
    } catch (e) {
      // If fetching movies fails
      return const Left(
        ServerFailure('Failed to fetch selected movie details'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveDailySelection(
    DailySelection selection,
  ) async {
    try {
      final model = DailySelectionModel(
        profileId: selection.profileId,
        date: selection.date,
        movies: selection.movies,
      );
      await localDataSource.saveDailySelection(model);
      return const Right(null);
    } on DatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<Interaction>>> getUserInteractions(
    String profileId,
  ) async {
    try {
      final result = await localDataSource.getInteractions(profileId);
      return Right(result);
    } on DatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveInteraction(Interaction interaction) async {
    try {
      final model = InteractionModel(
        id: interaction.id,
        profileId: interaction.profileId,
        movieId: interaction.movieId,
        status: interaction.status,
        updatedAt: interaction.updatedAt,
      );
      await localDataSource.saveInteraction(model);
      return const Right(null);
    } on DatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteInteraction(
    String profileId,
    int movieId,
  ) async {
    try {
      await localDataSource.deleteInteraction(profileId, movieId);
      return const Right(null);
    } on DatabaseException {
      return const Left(DatabaseFailure());
    }
  }
}
