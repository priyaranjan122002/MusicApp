class Lyrics {
  final String plainLyrics;
  final String syncedLyrics;
  final int duration;

  const Lyrics({
    required this.plainLyrics,
    required this.syncedLyrics,
    required this.duration,
  });

  factory Lyrics.fromJson(Map<String, dynamic> json) {
    return Lyrics(
      plainLyrics: json['plainLyrics'] ?? '',
      syncedLyrics: json['syncedLyrics'] ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
    );
  }
}
