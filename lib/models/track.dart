class Track {
  final String id;
  final String title;
  final String artist;
  final String url;
  final String thumbnail;
  final String category;
  final Duration duration;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    required this.thumbnail,
    required this.category,
    required this.duration,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String,
      category: json['category'] as String,
      duration: Duration(seconds: json['duration_seconds'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'url': url,
      'thumbnail': thumbnail,
      'category': category,
      'duration_seconds': duration.inSeconds,
    };
  }
}