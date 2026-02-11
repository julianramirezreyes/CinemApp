import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/tmdb_remote_datasource.dart';
import '../../data/datasources/supabase_datasource.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/usecases/movie_usecases.dart';

// External Services
final httpClientProvider = Provider((ref) => http.Client());
final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

// Datasources
final tmdbRemoteDataSourceProvider = Provider<TMDbRemoteDataSource>((ref) {
  return TMDbRemoteDataSourceImpl(client: ref.read(httpClientProvider));
});

final supabaseLocalDataSourceProvider = Provider<SupabaseLocalDataSource>((
  ref,
) {
  return SupabaseLocalDataSourceImpl(
    supabase: ref.read(supabaseClientProvider),
  );
});

// Repository
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepositoryImpl(
    remoteDataSource: ref.read(tmdbRemoteDataSourceProvider),
    localDataSource: ref.read(supabaseLocalDataSourceProvider),
  );
});

// UseCases
final getDailySelectionUseCaseProvider = Provider((ref) {
  return GetDailySelection(ref.read(movieRepositoryProvider));
});

final markMovieWatchedUseCaseProvider = Provider((ref) {
  return MarkMovieWatched(ref.read(movieRepositoryProvider));
});

final markMovieIgnoredUseCaseProvider = Provider((ref) {
  return MarkMovieIgnored(ref.read(movieRepositoryProvider));
});
