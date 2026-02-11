import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/daily_selection_provider.dart';
import '../providers/providers.dart';
import '../widgets/movie_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailySelectionState = ref.watch(dailySelectionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Selection')),
      body: dailySelectionState.when(
        data: (selection) {
          if (selection == null || selection.movies.isEmpty) {
            return const Center(child: Text('No selection for today'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: selection.movies.length,
            itemBuilder: (context, index) {
              final movie = selection.movies[index];
              return MovieCard(
                movie: movie,
                onTap: () {
                  context.push('/details', extra: movie);
                },
                onWatched: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  // In a real app we'd get profileId from auth state
                  await ref
                      .read(markMovieWatchedUseCaseProvider)
                      .call('default_user_v1', movie.id);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Marked "${movie.title}" as Watched'),
                    ),
                  );
                  // Refresh selection?? Requirements trigger state change but maybe not remove from daily list visually immediately?
                  // "Estado de Película: Neutral. Acciones: Insertar..."
                  // "Debe existir opcion revertir estado".
                  // Visual feedback only for now.
                },
                onIgnored: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  await ref
                      .read(markMovieIgnoredUseCaseProvider)
                      .call('default_user_v1', movie.id);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Marked "${movie.title}" as Ignored'),
                    ),
                  );
                },
              );
            },
          );
        },
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading selection: $err',
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: () => ref.refresh(dailySelectionProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
