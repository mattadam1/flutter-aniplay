class Movie {
  final int id;
  final String title;
  final String posterpath;
  final String overview;
  final double rating;
  final String releaseDate;
  final int duration;
  final List<Torrent>? torrents; // New field for torrent links

  Movie({
    required this.id,
    required this.title,
    required this.posterpath,
    required this.overview,
    required this.rating,
    required this.releaseDate,
    required this.duration,
    this.torrents, // Optional field
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterpath: json['poster_path'] ?? '',
      overview: json['overview'] ?? '',
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] ?? '',
      duration: json['runtime'] ?? 0,
      torrents: (json['torrents'] as List<dynamic>?)
          ?.map((torrentJson) => Torrent.fromJson(torrentJson))
          .toList(),
    );
  }
}

class Torrent {
  final String url;
  final String quality;
  final String type;

  Torrent({
    required this.url,
    required this.quality,
    required this.type,
  });

  factory Torrent.fromJson(Map<String, dynamic> json) {
    return Torrent(
      url: json['url'] ?? '',
      quality: json['quality'] ?? '',
      type: json['type'] ?? '',
    );
  }
}