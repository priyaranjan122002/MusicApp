
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';
import '../models/lyrics.dart';
import '../../core/errors/failures.dart';

class MusicService {
  final http.Client client;

  MusicService({required this.client});

  Future<List<Track>> fetchTracks(String query, int index, int limit) async {
    final url = Uri.parse('https://itunes.apple.com/search?term=$query&entity=song&limit=$limit&offset=$index');
    print('Requesting: $url');
    try {
      final response = await client.get(url);
      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['results'];
        print('Found ${list.length} tracks');
        return list.map((item) {
          String cover = item['artworkUrl100'] ?? '';
          // Try to get higher resolution image
          cover = cover.replaceAll('100x100', '600x600');
          
          return Track(
            id: item['trackId'],
            title: item['trackName'],
            artistName: item['artistName'],
            albumCover: cover,
            duration: (item['trackTimeMillis'] as num).toInt() ~/ 1000,
            previewUrl: item['previewUrl'],
          );
        }).toList();
      } else {
        print('Server Error: ${response.body}');
        throw ServerFailure('Failed to load tracks');
      }
    } catch (e) {
      print('Error fetching tracks: $e');
      if (e is ServerFailure) rethrow;
      throw const NetworkFailure();
    }
  }

  Future<TrackDetails> fetchTrackDetails(int id) async {
    final url = Uri.parse('https://itunes.apple.com/lookup?id=$id');
    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        if (results.isEmpty) throw ServerFailure('Track not found');

        final item = results.first;
        
        String cover = item['artworkUrl100'] ?? '';
        cover = cover.replaceAll('100x100', '600x600');

        return TrackDetails(
          id: item['trackId'],
          title: item['trackName'],
          artistName: item['artistName'],
          albumCover: cover,
          duration: (item['trackTimeMillis'] as num).toInt() ~/ 1000,
          previewUrl: item['previewUrl'],
          releaseDate: item['releaseDate']?.substring(0, 10) ?? 'Unknown',
          genre: item['primaryGenreName'] ?? 'Pop',
        );
      } else {
        throw ServerFailure('Failed to load track details');
      }
    } catch (e) {
      print('Error fetching details: $e');
      if (e is ServerFailure) rethrow;
      throw const NetworkFailure();
    }
  }

  Future<Lyrics> fetchLyrics(String trackName, String artistName, int duration) async {
    try {
      final url = Uri.parse('https://lrclib.net/api/get-cached?track_name=$trackName&artist_name=$artistName&duration=$duration');
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Lyrics.fromJson(data);
      } else {
        throw ServerFailure('No lyrics found');
      }
    } catch (e) {
      print('Error fetching lyrics: $e');
      if (e is ServerFailure) rethrow;
      throw const NetworkFailure();
    }
  }
}
