import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/search_result.dart';
import '../providers/catalog_provider.dart';
import '../providers/search_provider.dart';
import '../providers/providers.dart'; // For watched/ignored
import '../widgets/movie_grid.dart';
import '../widgets/filter_panel.dart';
import '../widgets/movie_poster_card.dart';
import '../widgets/person_card.dart';
import 'dart:async'; // For Debounce

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // UI state immediate update
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      ref.read(globalSearchProvider.notifier).clear();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(globalSearchProvider.notifier).search(query);
    });
  }

  // ...
  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogProvider);
    final searchState = ref.watch(globalSearchProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _buildSearchBar(),
        actions: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
        ],
      ),
      endDrawer: !isDesktop && !_isSearching
          ? Drawer(
              width: 300,
              child: FilterPanel(
                currentFilters: catalogState.filters,
                onApply: (params) {
                  ref.read(catalogProvider.notifier).updateFilters(params);
                  Navigator.pop(context);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar Filters (Only when NOT searching and Desktop)
          if (isDesktop && !_isSearching)
            FilterPanel(
              currentFilters: catalogState.filters,
              onApply: (params) =>
                  ref.read(catalogProvider.notifier).updateFilters(params),
            ),

          if (isDesktop && !_isSearching) const VerticalDivider(width: 1),

          // Main Content
          Expanded(
            child: _isSearching
                ? _buildSearchResults(searchState)
                : _buildCatalogContent(catalogState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48, // Adjust height
      margin: const EdgeInsets.symmetric(vertical: 8), // Padding inside AppBar
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar películas, actores...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null) {
      return Center(child: Text('Error: ${state.errorMessage}'));
    }
    if (state.results.isEmpty) {
      return const Center(child: Text('No se encontraron resultados.'));
    }

    return _buildMixedGrid(state.results);
  }

  Widget _buildCatalogContent(CatalogState state) {
    final notifier = ref.read(catalogProvider.notifier);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent * 0.8) {
          notifier.fetchNextPage();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async => notifier.resetFilters(),
        child: state.movies.isEmpty && state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null && state.movies.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${state.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => notifier.fetchNextPage(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            : state.movies.isEmpty
            ? const Center(child: Text('No se encontraron películas'))
            : Column(
                children: [
                  Expanded(
                    child: MovieGrid(
                      movies: state.movies,
                      onTap: (movie) =>
                          context.push('/movie/${movie.id}', extra: movie),
                      onWatched: (movie) async {
                        await ref
                            .read(markMovieWatchedUseCaseProvider)
                            .call('default_user_v1', movie.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Marcada como vista: ${movie.title}',
                              ),
                            ),
                          );
                        }
                      },
                      onIgnored: (movie) async {
                        await ref
                            .read(markMovieIgnoredUseCaseProvider)
                            .call('default_user_v1', movie.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ignorada: ${movie.title}')),
                          );
                        }
                      },
                    ),
                  ),
                  if (state.isLoading && state.movies.isNotEmpty)
                    const LinearProgressIndicator(),
                ],
              ),
      ),
    );
  }

  Widget _buildMixedGrid(List<SearchResult> results) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 2;
        if (width >= 1200) {
          crossAxisCount = 5;
        } else if (width >= 900) {
          crossAxisCount = 4;
        } else if (width >= 600) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2 / 3.4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            if (item is MovieSearchResult) {
              return Column(
                children: [
                  Expanded(
                    child: MoviePosterCard(
                      movie: item.movie,
                      onTap: () => context.push(
                        '/movie/${item.movie.id}',
                        extra: item.movie,
                      ),
                      // No logic for search results to mark as watched yet from here
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            } else if (item is PersonSearchResult) {
              return Column(
                children: [
                  Expanded(
                    child: PersonCard(
                      person: item.person,
                      onTap: () => context.push('/person/${item.person.id}'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.person.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}
