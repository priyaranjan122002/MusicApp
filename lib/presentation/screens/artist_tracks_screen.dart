
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di/injection_container.dart' as di;
import '../../data/models/track.dart';
import '../../data/repositories/track_repository.dart';
import 'track_details_screen.dart';

class ArtistTracksScreen extends StatefulWidget {
  final String artistName;

  const ArtistTracksScreen({super.key, required this.artistName});

  @override
  State<ArtistTracksScreen> createState() => _ArtistTracksScreenState();
}

class _ArtistTracksScreenState extends State<ArtistTracksScreen> {
  List<Track> _tracks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTracks();
  }

  Future<void> _fetchTracks() async {
    try {
      final repository = di.sl<TrackRepository>();
      // Search for tracks by this artist
      final tracks = await repository.searchTracks(widget.artistName, 0);
      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      print('Artist Fetch Error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.black,
       appBar: AppBar(
         backgroundColor: Colors.transparent,
         title: Text(widget.artistName, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
         leading: const BackButton(color: Colors.white),
       ),
       body: _isLoading 
         ? const Center(child: CircularProgressIndicator())
         : _error != null 
             ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
             : _tracks.isEmpty 
                 ? const Center(child: Text('No tracks found', style: TextStyle(color: Colors.white)))
                 : ListView.builder(
                     padding: const EdgeInsets.all(16),
                     itemCount: _tracks.length,
                     itemBuilder: (context, index) {
                       final track = _tracks[index];
                       return ListTile(
                         contentPadding: const EdgeInsets.symmetric(vertical: 8),
                         leading: ClipRRect(
                           borderRadius: BorderRadius.circular(8),
                           child: CachedNetworkImage(
                             imageUrl: track.albumCover,
                             width: 50, height: 50, fit: BoxFit.cover,
                             errorWidget: (context, url, error) => Container(color: Colors.grey),
                           ),
                         ),
                         title: Text(track.title, style: GoogleFonts.outfit(color: Colors.white)),
                         subtitle: Text(track.artistName, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                         trailing: const Icon(Icons.play_circle_fill, color: Color(0xFFBB86FC)),
                         onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (_) => TrackDetailsScreen(track: track)),
                           );
                         },
                       );
                     },
                   ),
    );
  }
}
