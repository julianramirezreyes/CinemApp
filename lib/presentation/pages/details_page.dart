import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';

class DetailsPage extends StatelessWidget {
  final Movie
  movie; // In a real app complexity, might pass ID and fetch, but passing object is fine for MVP

  const DetailsPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (movie.backdropPath != null)
              Image.network(
                'https://image.tmdb.org/t/p/w780${movie.backdropPath}',
                fit: BoxFit.cover,
                height: 250,
                width: double.infinity,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Rating: ${movie.voteAverage}/10'),
                  const SizedBox(height: 8),
                  Text('Release: ${movie.releaseDate}'),
                  const SizedBox(height: 16),
                  Text(movie.overview),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
