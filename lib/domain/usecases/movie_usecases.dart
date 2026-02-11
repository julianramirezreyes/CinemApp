import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/daily_selection.dart';
import '../entities/interaction.dart';

import '../entities/movie_detail.dart';
import '../entities/person.dart';
import '../entities/search_result.dart';
import '../repositories/movie_repository.dart';

// Existing UseCases
class GetDailySelection {
  final MovieRepository repository;
  GetDailySelection(this.repository);

  Future<Either<Failure, DailySelection>> call(String profileId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Check DB
    final dbResult = await repository.getDailySelection(today, profileId);

    return dbResult.fold((failure) => Left(failure), (selection) async {
      // Enforce 10 movies.
      if (selection != null && selection.movies.length >= 10) {
        return Right(selection);
      } else {
        return _generateNewSelection(profileId, today);
      }
    });
  }

  Future<Either<Failure, DailySelection>> _generateNewSelection(
    String profileId,
    DateTime date,
  ) async {
    final interactionsResult = await repository.getUserInteractions(profileId);

    return interactionsResult.fold((failure) => Left(failure), (
      interactions,
    ) async {
      final excludedMovieIds = interactions.map((i) => i.movieId).toSet();

      int pageToCheck = (date.day * date.month * date.year) % 50 + 1;

      // Fetch page 1
      final tmdbResult = await repository.discoverMovies(page: pageToCheck);

      return tmdbResult.fold((failure) => Left(failure), (movies) async {
        final candidates = movies
            .where((m) => !excludedMovieIds.contains(m.id))
            .toList();

        // Try fetch page 2 if needed
        if (candidates.length < 10) {
          final extraPageResult = await repository.discoverMovies(
            page: pageToCheck + 1,
          );
          if (extraPageResult.isRight()) {
            final extraMovies = extraPageResult.getOrElse(() => []);
            final extraCandidates = extraMovies.where(
              (m) => !excludedMovieIds.contains(m.id),
            );
            candidates.addAll(extraCandidates);
          }
        }

        if (candidates.isEmpty) {
          return const Left(ServerFailure('No movies found to select'));
        }

        candidates.shuffle();
        final selected = candidates.take(10).toList();
        final selectedIds = selected.map((m) => m.id).toList();

        final newSelection = DailySelection(
          profileId: profileId,
          date: date,
          movies: selected,
          shownMovieIds: selectedIds,
        );

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

// New UseCases (Phase 3)

class GetMovieDetails {
  final MovieRepository repository;
  GetMovieDetails(this.repository);
  Future<Either<Failure, MovieDetail>> call(int movieId) {
    return repository.getMovieDetails(movieId);
  }
}

class GetPersonDetails {
  final MovieRepository repository;
  GetPersonDetails(this.repository);
  Future<Either<Failure, Person>> call(int personId) {
    return repository.getPersonDetails(personId);
  }
}

class SearchMulti {
  final MovieRepository repository;
  SearchMulti(this.repository);
  Future<Either<Failure, List<SearchResult>>> call(String query) {
    return repository.searchMulti(query);
  }
}
