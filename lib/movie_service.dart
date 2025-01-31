import 'package:groupassignment/movie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieService {
  final String? apiKey = '81ae0fd9dd1c71d78386f41d690a2475';
  final String baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> getPopularMovies() async {
    return _fetchMovies('$baseUrl/movie/popular?api_key=$apiKey');
  }

  Future<List<Movie>> searchMovies(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    return _fetchMovies('$baseUrl/search/movie?api_key=$apiKey&query=$encodedQuery');
  }

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
}