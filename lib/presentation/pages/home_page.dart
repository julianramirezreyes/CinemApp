import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/daily_selection_provider.dart';
import '../providers/providers.dart';
import '../widgets/movie_grid.dart'; // Use the new grid

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailySelectionState = ref.watch(dailySelectionProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('lib/assets/icons/Cinemapp.png'),
        ),
        title: Text(
          dailySelectionState.asData?.value != null
              ? 'CinemApp (${dailySelectionState.asData!.value!.remainingRefreshes}/3)'
              : 'CinemApp',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                !dailySelectionState.isLoading &&
                    dailySelectionState.asData?.value != null &&
                    dailySelectionState.asData!.value!.remainingRefreshes > 0
                ? () => ref
                      .read(dailySelectionProvider.notifier)
                      .refreshSelection()
                : null,
            tooltip: 'Refrescar selección (Consume 1 token)',
          ),
        ],
      ),
      body: dailySelectionState.when(
        data: (selection) {
          if (selection == null || selection.movies.isEmpty) {
            return const Center(child: Text('No selection for today'));
          }

          return MovieGrid(
            movies: selection.movies,
            onTap: (movie) => context.push('/movie/${movie.id}', extra: movie),
            onWatched: (movie) async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              await ref
                  .read(markMovieWatchedUseCaseProvider)
                  .call('default_user_v1', movie.id);
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Marked "${movie.title}" as Watched')),
              );
              // Refresh selection if needed, or just visual feedback
            },
            onIgnored: (movie) async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              await ref
                  .read(markMovieIgnoredUseCaseProvider)
                  .call('default_user_v1', movie.id);
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Marked "${movie.title}" as Ignored')),
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
