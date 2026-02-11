import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/errors/exceptions.dart';
import '../models/movie_model.dart';

abstract class TMDbRemoteDataSource {
  Future<List<MovieModel>> discoverMovies(int page);
  Future<List<MovieModel>> searchMovies(String query);
  Future<MovieModel> getMovieDetails(int movieId);
}

class TMDbRemoteDataSourceImpl implements TMDbRemoteDataSource {
  final http.Client client;

  TMDbRemoteDataSourceImpl({required this.client});

  final String _baseUrl = 'https://api.themoviedb.org/3';
  String get _readToken => dotenv.env['TMDB_READ_TOKEN'] ?? '';

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_readToken',
    'Content-Type': 'application/json',
  };

  @override
  Future<List<MovieModel>> discoverMovies(int page) async {
    final response = await client.get(
      Uri.parse(
        '$_baseUrl/discover/movie?language=es-ES&sort_by=popularity.desc&page=$page',
      ),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/search/movie?language=es-ES&query=$query'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<MovieModel> getMovieDetails(int movieId) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/movie/$movieId?language=es-ES'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return MovieModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}
