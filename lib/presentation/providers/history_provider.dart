import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/interaction.dart';
import '../../domain/entities/movie.dart';
import 'providers.dart';

class HistoryItem {
  final Interaction interaction;
  final Movie? movie;

  HistoryItem(this.interaction, this.movie);
}

class HistoryNotifier extends AsyncNotifier<List<HistoryItem>> {
  @override
  FutureOr<List<HistoryItem>> build() async {
    return _loadHistory();
  }

  Future<List<HistoryItem>> _loadHistory() async {
    final result = await ref
        .read(movieRepositoryProvider)
        .getUserInteractions('default_user_v1');

    return result.fold((failure) => throw failure.message, (
      interactions,
    ) async {
      List<HistoryItem> items = [];
      for (var interaction in interactions) {
        final movieResult = await ref
            .read(movieRepositoryProvider)
            .getMovieDetails(interaction.movieId);
        final movie = movieResult.fold((l) => null, (r) => r);
        items.add(HistoryItem(interaction, movie));
      }
      items.sort(
        (a, b) => b.interaction.updatedAt.compareTo(a.interaction.updatedAt),
      );
      return items;
    });
  }

  Future<void> revertInteraction(int movieId) async {
    final repo = ref.read(movieRepositoryProvider);
    await repo.deleteInteraction('default_user_v1', movieId);
    // Refresh the state
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadHistory());
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<HistoryItem>>(() {
      return HistoryNotifier();
    });
