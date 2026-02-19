
import 'package:equatable/equatable.dart';

class Track extends Equatable {
  final int id;
  final String title;
  final String artistName;
  final String albumCover;
  final int duration;

  final String? previewUrl;

  const Track({
    required this.id,
    required this.title,
    required this.artistName,
    required this.albumCover,
    required this.duration,
    this.previewUrl,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as int,
      title: json['title'] as String,
      artistName: json['artist']['name'] as String,
      albumCover: json['album']['cover_medium'] ?? json['album']['cover_small'] ?? '',
      duration: json['duration'] as int,
      previewUrl: json['preview'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, title, artistName, albumCover, duration, previewUrl];
}

class TrackDetails extends Track {
  final String lyrics;
  final String releaseDate;
  final String genre;

  const TrackDetails({
    required super.id,
    required super.title,
    required super.artistName,
    required super.albumCover,
    required super.duration,
    super.previewUrl,
    this.lyrics = '',
    this.releaseDate = 'Unknown',
    this.genre = 'Music',
  });

  factory TrackDetails.fromTrack(Track track, {String lyrics = '', String releaseDate = 'Unknown', String genre = 'Music'}) {
    return TrackDetails(
      id: track.id,
      title: track.title,
      artistName: track.artistName,
      albumCover: track.albumCover,
      duration: track.duration,
      previewUrl: track.previewUrl,
      lyrics: lyrics,
      releaseDate: releaseDate,
      genre: genre,
    );
  }
  
  @override
  List<Object?> get props => [...super.props, lyrics, releaseDate, genre];
}
