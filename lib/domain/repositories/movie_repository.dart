import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/movie.dart';
import '../entities/daily_selection.dart';
import '../entities/interaction.dart';

abstract class MovieRepository {
  // Remote Data (TMDB)
  Future<Either<Failure, List<Movie>>> discoverMovies({
    required int page,
    String? language,
  });

  Future<Either<Failure, List<Movie>>> searchMovies(String query);

  Future<Either<Failure, Movie>> getMovieDetails(int movieId);

  // Local/Supabase Data
  Future<Either<Failure, DailySelection?>> getDailySelection(
    DateTime date,
    String profileId,
  );

  Future<Either<Failure, void>> saveDailySelection(DailySelection selection);

  Future<Either<Failure, List<Interaction>>> getUserInteractions(
    String profileId,
  );

  Future<Either<Failure, void>> saveInteraction(Interaction interaction);

  Future<Either<Failure, void>> deleteInteraction(
    String profileId,
    int movieId,
  );
}
