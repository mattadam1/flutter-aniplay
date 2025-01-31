import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'movie.dart';
import 'movie_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Movie>> _moviesFuture;
  final MovieService _movieService = MovieService();
  bool _showSearch = false;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _moviesFuture = _movieService.getPopularMovies();
  }

  void _handleSearch(String text) {
    setState(() {
      _searchText = text;
      if (_searchText.isNotEmpty) {
        _moviesFuture = _movieService.searchMovies(_searchText);
      } else {
        _moviesFuture = _movieService.getPopularMovies(); // Reset to popular
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Aniplay',
          style: TextStyle(
            fontFamily: 'Pacifico',
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search, color: Colors.white), // Change icon
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _handleSearch(''); // Clear search and reset view
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
        bottom: _showSearch ? _buildSearchBar() : null,
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Movie>>(
            future: _moviesFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final movies = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 80.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    final posterUrl =
                        'https://image.tmdb.org/t/p/w500${movie.posterpath}';
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/movieDetails',
                            arguments: movie);
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Hero(
                              tag: movie.id,
                              child: CachedNetworkImage(
                                imageUrl: posterUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              movie.title,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return const Center(child: Text('Failed to load movies'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.grey[800],
                  child: const Text(
                    "Made with ❤️ by Aniplay",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(4.0),
                  child: const Text(
                    "© 2025 Aniplay. All Rights Reserved. | Made by hnfsyhmi",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildSearchBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        color: Colors.grey[800],
        child: TextField(
          onChanged: _handleSearch,
          autofocus: true, // Autofocus for better UX
          decoration: InputDecoration(
            hintText: 'Search movies...',
            hintStyle: const TextStyle(color: Colors.white),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: Colors.white),
            suffixIcon: _searchText.isNotEmpty // Add clear icon conditionally
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _handleSearch(''); // Clear search
                    },
                  )
                : null,
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}