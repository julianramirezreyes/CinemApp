import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/movie.dart';

class MoviePosterCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback? onWatched;
  final VoidCallback? onIgnored;

  const MoviePosterCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.onWatched,
    this.onIgnored,
  });

  @override
  State<MoviePosterCard> createState() => _MoviePosterCardState();
}

class _MoviePosterCardState extends State<MoviePosterCard> {
  bool _isHovered = false;

  @override
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => setState(() => _isHovered = !_isHovered),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? Matrix4.translationValues(0, -5, 0)
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Background Poster
                Positioned.fill(
                  child: widget.movie.posterPath != null
                      ? CachedNetworkImage(
                          imageUrl:
                              'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[900]),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white24,
                            ),
                          ),
                        )
                      : Container(color: Colors.grey[800]),
                ),

                // Rating Badge (Always visible)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.amber, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          widget.movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Hover / Action Overlay
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isHovered ? 1.0 : 0.0,
                  curve: Curves.easeInOut,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Actions
                          if (widget.onWatched != null ||
                              widget.onIgnored != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.onWatched != null)
                                  _ActionButton(
                                    icon: Icons.check_circle,
                                    color: Colors.green,
                                    label: 'Visto',
                                    onPressed: widget.onWatched!,
                                  ),
                                if (widget.onWatched != null &&
                                    widget.onIgnored != null)
                                  const SizedBox(width: 16),
                                if (widget.onIgnored != null)
                                  _ActionButton(
                                    icon: Icons.cancel,
                                    color: Colors.red,
                                    label: 'Saltar',
                                    onPressed: widget.onIgnored!,
                                  ),
                              ],
                            ),
                          if (widget.onWatched != null ||
                              widget.onIgnored != null)
                            const SizedBox(height: 12),

                          // Details Button
                          ActionChip(
                            label: const Text('Detalles'),
                            backgroundColor: Colors.white24,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            onPressed: widget.onTap,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: color, size: 32),
          tooltip: label,
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

// Wrapper to include the text below the card
class MoviePosterItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback? onWatched;
  final VoidCallback? onIgnored;

  const MoviePosterItem({
    super.key,
    required this.movie,
    required this.onTap,
    this.onWatched,
    this.onIgnored,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: MoviePosterCard(
            movie: movie,
            onTap: onTap,
            onWatched: onWatched,
            onIgnored: onIgnored,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movie.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          movie.releaseDate.split('-')[0], // Year
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }
}
