import 'package:dartz/dartz.dart';
import '../repositories/movie_repository.dart';
import '../entities/daily_selection.dart';
import '../entities/interaction.dart';
import '../../core/errors/failures.dart';

class GetDailySelection {
  final MovieRepository repository;

  GetDailySelection(this.repository);

  /// This usecase orchestrates the logic:
  /// 1. Check DB for today's selection
  /// 2. If exists, return it
  /// 3. If not, fetch from TMDB, filter, select random, save to DB, return it
  Future<Either<Failure, DailySelection>> call(String profileId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Check DB
    final dbResult = await repository.getDailySelection(today, profileId);

    return dbResult.fold((failure) => Left(failure), (selection) async {
      if (selection != null) {
        return Right(selection);
      } else {
        // 2. Generate new selection
        return _generateNewSelection(profileId, today);
      }
    });
  }

  Future<Either<Failure, DailySelection>> _generateNewSelection(
    String profileId,
    DateTime date,
  ) async {
    // Get interactions to filter
    final interactionsResult = await repository.getUserInteractions(profileId);

    return interactionsResult.fold((failure) => Left(failure), (
      interactions,
    ) async {
      final excludedMovieIds = interactions.map((i) => i.movieId).toSet();

      // Fetch candidates from TMDB
      // Rule 8 says: Generate seed based on date, select random page.
      // Using a fixed algo based on date hash to pick a page 1-50.
      final pageToCheck = (date.day * date.month * date.year) % 50 + 1;

      final tmdbResult = await repository.discoverMovies(page: pageToCheck);

      return tmdbResult.fold((failure) => Left(failure), (movies) async {
        // Filter
        final candidates = movies
            .where((m) => !excludedMovieIds.contains(m.id))
            .toList();

        // Should select 3 or 5.
        if (candidates.isEmpty) {
          return const Left(ServerFailure('No movies found to select'));
        }

        candidates.shuffle();

        final selected = candidates.take(3).toList();

        final newSelection = DailySelection(
          profileId: profileId,
          date: date,
          movies: selected,
        );

        // Save
        await repository.saveDailySelection(newSelection);

        return Right(newSelection);
      });
    });
  }
}

class MarkMovieWatched {
  final MovieRepository repository;
  MarkMovieWatched(this.repository);

  Future<Either<Failure, void>> call(String profileId, int movieId) {
    return repository.saveInteraction(
      Interaction(
        profileId: profileId,
        movieId: movieId,
        status: InteractionStatus.watched,
        updatedAt: DateTime.now(),
      ),
    );
  }
}

class MarkMovieIgnored {
  final MovieRepository repository;
  MarkMovieIgnored(this.repository);

  Future<Either<Failure, void>> call(String profileId, int movieId) {
    return repository.saveInteraction(
      Interaction(
        profileId: profileId,
        movieId: movieId,
        status: InteractionStatus.ignored,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
