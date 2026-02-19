
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../models/track.dart';
import '../providers/music_service.dart';

class TrackRepository {
  final MusicService musicService;
  final NetworkInfo networkInfo;

  TrackRepository({required this.musicService, required this.networkInfo});

  Future<List<Track>> fetchTracks(int offset, int limit) async {
    // Default to 'pop' or 'top' if just fetching generic tracks
    return await musicService.fetchTracks('pop', offset, limit);
  }

  Future<List<Track>> searchTracks(String query, int offset) async {
    return await musicService.fetchTracks(query, offset, 50);
  }

  final List<Track> _recentTracks = [];

  List<Track> getRecentTracks() => List.unmodifiable(_recentTracks);

  void addToRecent(Track track) {
    _recentTracks.removeWhere((t) => t.id == track.id);
    _recentTracks.insert(0, track);
    if (_recentTracks.length > 20) {
      _recentTracks.removeLast();
    }
  }

  Future<TrackDetails> getTrackDetails(Track track) async {
    // Add to Recent when details are fetched (implies user viewing/playing)
    addToRecent(track);

    final details = await musicService.fetchTrackDetails(track.id);
    
    String lyricsText = '';
    try {
      final lyrics = await musicService.fetchLyrics(
        CleanString.clean(track.title), 
        CleanString.clean(track.artistName), 
        track.duration
      );
      lyricsText = lyrics.plainLyrics.isNotEmpty ? lyrics.plainLyrics : lyrics.syncedLyrics;
    } catch (e) {
      // Lyrics failure shouldn't block details
      lyricsText = 'Lyrics not available';
    }

    // Return new TrackDetails with lyrics
    return TrackDetails(
      id: details.id,
      title: details.title,
      artistName: details.artistName,
      albumCover: details.albumCover,
      duration: details.duration,
      previewUrl: details.previewUrl,
      lyrics: lyricsText,
      releaseDate: details.releaseDate,
      genre: details.genre,
    );
  }
}

class CleanString {
  static String clean(String s) {
    // Remove content in brackets usually not needed for lyrics search
    return s.replaceAll(RegExp(r'\(.*?\)|\[.*?\]'), '').trim();
  }
}
