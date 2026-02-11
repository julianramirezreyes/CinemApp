import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/interaction.dart';
import '../providers/history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Watched'),
              Tab(text: 'Ignored'),
            ],
          ),
        ),
        body: historyState.when(
          data: (items) {
            final watched = items
                .where((i) => i.interaction.status == InteractionStatus.watched)
                .toList();
            final ignored = items
                .where((i) => i.interaction.status == InteractionStatus.ignored)
                .toList();

            return TabBarView(
              children: [
                _buildList(context, ref, watched),
                _buildList(context, ref, ignored),
              ],
            );
          },
          error: (err, stack) => Center(child: Text('Error: $err')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<HistoryItem> items,
  ) {
    if (items.isEmpty) {
      return const Center(child: Text('No items yet'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final movie = item.movie;
        if (movie == null) return const SizedBox.shrink();

        return ListTile(
          leading: movie.posterPath != null
              ? Image.network(
                  'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                  width: 50,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.movie),
          title: Text(movie.title),
          subtitle: Text('Rated: ${movie.voteAverage}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ref.read(historyProvider.notifier).revertInteraction(movie.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Removed ${movie.title} from history')),
              );
            },
          ),
        );
      },
    );
  }
}
