import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie.dart';
import 'providers.dart';

class CatalogState {
  final AsyncValue<List<Movie>> movies;
  final String searchQuery;
  final bool isSearching;

  CatalogState({
    required this.movies,
    this.searchQuery = '',
    this.isSearching = false,
  });

  CatalogState copyWith({
    AsyncValue<List<Movie>>? movies,
    String? searchQuery,
    bool? isSearching,
  }) {
    return CatalogState(
      movies: movies ?? this.movies,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class CatalogNotifier extends Notifier<CatalogState> {
  @override
  CatalogState build() {
    // Initial load
    Future.microtask(() => discoverMovies());
    return CatalogState(movies: const AsyncValue.loading());
  }

  Future<void> discoverMovies() async {
    state = state.copyWith(
      movies: const AsyncValue.loading(),
      isSearching: false,
    );
    final result = await ref
        .read(movieRepositoryProvider)
        .discoverMovies(page: 1);

    result.fold(
      (failure) => state = state.copyWith(
        movies: AsyncValue.error(failure.message, StackTrace.current),
      ),
      (movies) => state = state.copyWith(movies: AsyncValue.data(movies)),
    );
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      discoverMovies();
      return;
    }

    state = state.copyWith(
      movies: const AsyncValue.loading(),
      searchQuery: query,
      isSearching: true,
    );
    final result = await ref.read(movieRepositoryProvider).searchMovies(query);

    result.fold(
      (failure) => state = state.copyWith(
        movies: AsyncValue.error(failure.message, StackTrace.current),
      ),
      (movies) => state = state.copyWith(movies: AsyncValue.data(movies)),
    );
  }
}

final catalogProvider = NotifierProvider<CatalogNotifier, CatalogState>(() {
  return CatalogNotifier();
});
