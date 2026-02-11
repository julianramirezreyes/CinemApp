import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/movie.dart';
import '../entities/movie_detail.dart';
import '../entities/person.dart';
import '../entities/search_result.dart';
import '../entities/daily_selection.dart';
import '../entities/interaction.dart';

abstract class MovieRepository {
  // Remote Data (TMDB)
  Future<Either<Failure, List<Movie>>> discoverMovies({
    required int page,
    String? sortBy,
    String? withGenres,
    String? releaseDateGte,
    String? releaseDateLte,
    double? voteAverageGte,
    String? withOriginalLanguage,
  });

  Future<Either<Failure, List<Movie>>> searchMovies(String query);
  Future<Either<Failure, List<SearchResult>>> searchMulti(String query);
  Future<Either<Failure, MovieDetail>> getMovieDetails(int movieId);
  Future<Either<Failure, Person>> getPersonDetails(int personId);

  // Local Data (Supabase)
  Future<Either<Failure, DailySelection?>> getDailySelection(
    DateTime date,
    String profileId,
  );
  Future<Either<Failure, DailySelection>> refreshDailySelection(
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
