import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie.dart';

class MovieService {
  final String? apiKey = '81ae0fd9dd1c71d78386f41d690a2475'; // TMDb API Key
  final String baseUrl = 'https://api.themoviedb.org/3';

  // Fetch popular movies with torrent links
  Future<List<Movie>> getPopularMoviesWithTorrents() async {
    final tmdbMovies = await getPopularMovies();
    return _addTorrentsToMovies(tmdbMovies);
  }

  // Search movies with torrent links
  Future<List<Movie>> searchMoviesWithTorrents(String query) async {
    final tmdbMovies = await searchMovies(query);
    return _addTorrentsToMovies(tmdbMovies);
  }

  // Fetch movies from TMDb
  Future<List<Movie>> getPopularMovies() async {
    return _fetchMovies('$baseUrl/movie/popular?api_key=$apiKey');
  }

  Future<List<Movie>> searchMovies(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    return _fetchMovies('$baseUrl/search/movie?api_key=$apiKey&query=$encodedQuery');
  }

  // Helper method to fetch movies from TMDb
  Future<List<Movie>> _fetchMovies(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      final List<dynamic> results = decodedData['results'];
      return results.map((movieJson) => Movie.fromJson(movieJson)).toList();
    } else {
      print('Error fetching data: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load movies');
    }
  }

  // Add torrent links to movies using YTS API
  Future<List<Movie>> _addTorrentsToMovies(List<Movie> movies) async {
    final moviesWithTorrents = <Movie>[];
    for (final movie in movies) {
      final torrentData = await _fetchTorrents(movie.title);
      moviesWithTorrents.add(movie.copyWith(torrents: torrentData));
    }
    return moviesWithTorrents;
  }

  // Fetch torrent links from YTS API
  Future<List<Torrent>> _fetchTorrents(String movieTitle) async {
    final encodedQuery = Uri.encodeComponent(movieTitle);
    final response = await http.get(Uri.parse('https://yts.mx/api/v2/list_movies.json?query_term=$encodedQuery'));

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      final List<dynamic> results = decodedData['data']['movies'] ?? [];

      // Extract torrents from the results and map them to Torrent objects
      return results
          .expand((movieJson) => (movieJson['torrents'] as List<dynamic>?)
          ?.map((torrentJson) => Torrent.fromJson(torrentJson))
          .toList() ??
          [])
          .toList()
          .cast<Torrent>(); // Explicitly cast the list to List<Torrent>
    } else {
      print('Error fetching torrents: ${response.statusCode}');
      print('Response body: ${response.body}');
      return []; // Return an empty list in case of an error
    }
  }
}

// Extension to add a copyWith method to the Movie class
extension MovieExtensions on Movie {
  Movie copyWith({List<Torrent>? torrents}) {
    return Movie(
      id: this.id,
      title: this.title,
      posterpath: this.posterpath,
      overview: this.overview,
      rating: this.rating,
      releaseDate: this.releaseDate,
      duration: this.duration,
      torrents: torrents ?? this.torrents,
    );
  }
}