import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/credit.dart';
import '../providers/details_provider.dart';
import '../widgets/movie_poster_card.dart';

class MovieDetailsPage extends ConsumerWidget {
  final int movieId;
  final Movie? placeholderMovie; // Optimistic UI

  const MovieDetailsPage({
    super.key,
    required this.movieId,
    this.placeholderMovie,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieDetailsAsync = ref.watch(movieDetailsProvider(movieId));

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: movieDetailsAsync.when(
        data: (details) => _buildContent(context, details),
        loading: () => placeholderMovie != null
            ? _buildPlaceholder(context, placeholderMovie!)
            : const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: $err', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(movieDetailsProvider(movieId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, Movie movie) {
    // Show partial data while loading full details
    return _buildContent(
      context,
      MovieDetail(
        id: movie.id,
        title: movie.title,
        overview: movie.overview,
        posterPath: movie.posterPath,
        backdropPath: movie.backdropPath,
        releaseDate: movie.releaseDate,
        voteAverage: movie.voteAverage,
        voteCount: movie.voteCount,
        popularity: movie.popularity,
        // Empty detail fields
      ),
      isLoading: true,
    );
  }

  Widget _buildContent(
    BuildContext context,
    MovieDetail details, {
    bool isLoading = false,
  }) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, details),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(context, details),
                const SizedBox(height: 16),
                _buildOverview(context, details),
                const SizedBox(height: 24),
                if (!isLoading) ...[
                  if (details.cast != null && details.cast!.isNotEmpty)
                    _buildCastSection(context, details.cast!),
                  const SizedBox(height: 24),
                  if (details.crew != null && details.crew!.isNotEmpty)
                    _buildCrewSection(context, details.crew!),
                  const SizedBox(height: 24),
                  if (details.videoKeys != null &&
                      details.videoKeys!.isNotEmpty)
                    _buildTrailerSection(
                      context,
                      details.videoKeys!.first,
                    ), // Show first trailer
                  const SizedBox(height: 24),
                  if (details.recommendations != null &&
                      details.recommendations!.isNotEmpty)
                    _buildRecommendationsSection(
                      context,
                      details.recommendations!,
                    ),
                ],
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, MovieDetail details) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return SliverAppBar(
      expandedHeight: isDesktop ? 500.0 : 350.0,
      pinned: true,
      backgroundColor: const Color(0xFF121212),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (details.backdropPath != null)
              Image.network(
                'https://image.tmdb.org/t/p/w1280${details.backdropPath}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[900]),
              )
            else
              Container(color: Colors.grey[900]),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF121212).withValues(alpha: 0.8),
                    const Color(0xFF121212),
                  ],
                  stops: const [0.5, 0.85, 1.0],
                ),
              ),
            ),

            // Poster & Basic Info (Desktop Layout) or just nice overlay
            // Let's keep it simple for header: just background.
            // Specifics in body.
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.canPop() ? context.pop() : context.go('/'),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, MovieDetail details) {
    final year = details.releaseDate.isNotEmpty
        ? DateTime.tryParse(details.releaseDate)?.year.toString() ?? ''
        : '';

    final runtime = details.runtime != null
        ? '${(details.runtime! / 60).floor()}h ${details.runtime! % 60}m'
        : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poster (Small, overlaid on top left of content or integrated)
        if (details.posterPath != null)
          Container(
            width: 120,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://image.tmdb.org/t/p/w500${details.posterPath}',
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (details.tagline != null && details.tagline!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    details.tagline!,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (year.isNotEmpty) ...[
                    Text(year, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(width: 8),
                    const Icon(Icons.circle, size: 4, color: Colors.white70),
                    const SizedBox(width: 8),
                  ],
                  if (details.genresList != null)
                    Expanded(
                      child: Text(
                        details.genresList!.map((g) => g.name).join(', '),
                        style: const TextStyle(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (runtime.isNotEmpty) ...[
                    Text(
                      runtime,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                  ],
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    details.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (details.voteCount != null)
                    Text(
                      ' (${details.voteCount} votos)',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              // Status
              if (details.status != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      details.status!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverview(BuildContext context, MovieDetail details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sinopsis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          details.overview,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCastSection(BuildContext context, List<Cast> cast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reparto Principal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // "Ver reparto completo" could go here or navigate to separate page
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cast.take(10).length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final person = cast[index];
              return InkWell(
                onTap: () => context.push('/person/${person.id}'),
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: person.profilePath != null
                              ? Image.network(
                                  'https://image.tmdb.org/t/p/w185${person.profilePath}',
                                  fit: BoxFit.cover,
                                  width: 100,
                                )
                              : Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white54,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        person.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        person.character ?? '',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCrewSection(BuildContext context, List<Crew> crew) {
    // Filter important crew: Director, Writer
    final importantCrew = crew
        .where(
          (c) =>
              c.job == 'Director' ||
              c.job == 'Screenplay' ||
              c.job == 'Writer' ||
              c.department == 'Production',
        )
        .take(6)
        .toList();

    if (importantCrew.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Equipo Técnico',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 20,
          runSpacing: 10,
          children: importantCrew.map((c) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _translateJob(c.job ?? c.department ?? ''),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  String _translateJob(String job) {
    switch (job) {
      case 'Director':
        return 'Director';
      case 'Screenplay':
      case 'Writer':
        return 'Guion';
      case 'Production':
        return 'Producción';
      default:
        return job;
    }
  }

  Widget _buildTrailerSection(BuildContext context, String videoKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tráiler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: Colors.black,
            child: YoutubePlayer(
              controller: YoutubePlayerController.fromVideoId(
                videoId: videoKey,
                autoPlay: false,
                params: const YoutubePlayerParams(
                  showFullscreenButton: true,
                  strictRelatedVideos: true,
                ),
              ),
              aspectRatio: 16 / 9,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () async {
              final url = Uri.parse(
                'https://www.youtube.com/watch?v=$videoKey',
              );
              try {
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  // Fallback to browser if app fails?
                  await launchUrl(url, mode: LaunchMode.platformDefault);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al abrir YouTube: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.open_in_new, color: Colors.white70),
            label: const Text(
              'Ver en YouTube (si falla la reproducción)',
              style: TextStyle(color: Colors.white70),
            ),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(
    BuildContext context,
    List<Movie> recommendations,
  ) {
    // Show a grid of ~6 items or a horizontal list
    // User asked "Mostrar en grid tipo catálogo" for recommendations.
    // We can use MovieGrid inside a Sliver?
    // Or just a Wrap/GridView.shrinkWrap

    // Let's us a horizontal list for recommendations to save vertical space,
    // or a small grid.
    // "Recomendaciones... Mostrar en grid tipo catálogo" typically implies a section below.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recomendaciones',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        // We can't use MovieGrid directly if it forces Sliver or specificdelegate easily inside a ListView column.
        // But MovieGrid uses SliverGridDelegate...
        // Let's reuse MoviePosterCard manually in a GridView.
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 0.65, // Poster ratio
            crossAxisSpacing: 10, // Tighter spacing
            mainAxisSpacing: 10,
          ),
          itemCount: recommendations.take(12).length,
          itemBuilder: (context, index) {
            final movie = recommendations[index];
            return MoviePosterCard(
              movie: movie,
              onTap: () {
                // Push new details page
                context.push('/movie/${movie.id}', extra: movie);
              },
            );
          },
        ),
      ],
    );
  }
}
