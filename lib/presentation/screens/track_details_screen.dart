import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../data/models/track.dart';
import '../../logic/blocs/details_bloc.dart';
import '../../core/di/injection_container.dart' as di;

class TrackDetailsScreen extends StatefulWidget {
  final Track track;

  const TrackDetailsScreen({super.key, required this.track});

  @override
  State<TrackDetailsScreen> createState() => _TrackDetailsScreenState();
}

class _TrackDetailsScreenState extends State<TrackDetailsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isAudioLoading = false;

  // Audio timing states
  Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: 30); // Fixed for iTunes preview

  @override
  void initState() {
    super.initState();
    _setupAudio();
  }

  void _setupAudio() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    // Duration change listener
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    // Position change listener (Timer updates here)
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    // Player State listener
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    // Reset on completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });

    // Auto-play when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _togglePlay();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (!mounted) return;
    if (widget.track.previewUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No preview available.'))
      );
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(widget.track.previewUrl!));
      }
    } catch (e) {
      debugPrint('Audio Error: $e');
    }
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<DetailsBloc>()..add(LoadTrackDetails(widget.track)),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // Background Blur
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.track.albumCover,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(color: Colors.black),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(color: Colors.black.withOpacity(0.6)),
              ),
            ),

            BlocBuilder<DetailsBloc, DetailsState>(
              builder: (context, state) {
                String lyrics = 'Lyrics not available';
                bool isLoading = state is DetailsLoading;

                if (state is DetailsLoaded) {
                  lyrics = state.trackDetails.lyrics.isNotEmpty
                      ? state.trackDetails.lyrics
                      : "Music playing...\n\nEnjoy the rhythm.";
                }

                return SafeArea(
                  child: Column(
                    children: [
                      // TOP SECTION (Album Art & Info)
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Album Cover
                                Hero(
                                  tag: 'album_${widget.track.id}',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 15))
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CachedNetworkImage(
                                        imageUrl: widget.track.albumCover,
                                        width: 280, // Reduced slightly to prevent overflow
                                        height: 280,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25), // Reduced from 40

                                // Title & Artist
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30),
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.track.title,
                                        style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        widget.track.artistName,
                                        style: GoogleFonts.outfit(fontSize: 16, color: Colors.white70),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 15),
                                if (_isPlaying) MusicVisualizer(isPlaying: _isPlaying),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // BOTTOM SECTION (Controls)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             // --- SLIDER & TIMER ---
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                child: Column(
                                  children: [
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 4,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                        activeTrackColor: Colors.white,
                                        inactiveTrackColor: Colors.white24,
                                        thumbColor: Colors.white,
                                      ),
                                      child: Slider(
                                        max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 30.0,
                                        value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 30.0),
                                        onChanged: (value) async {
                                          await _audioPlayer.seek(Duration(seconds: value.toInt()));
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_formatDuration(_position), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                                          Text(_formatDuration(_duration.inSeconds > 0 ? _duration : const Duration(seconds: 30)), 
                                               style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // --- MAIN CONTROLS ---
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 45),
                                    ),

                                    GestureDetector(
                                      onTap: _togglePlay,
                                      child: Container(
                                        height: 80, // Slightly bigger
                                        width: 80,
                                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.black, size: 50),
                                      ),
                                    ),

                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 45),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Visualizer Component
class MusicVisualizer extends StatefulWidget {
  final bool isPlaying;
  const MusicVisualizer({super.key, required this.isPlaying});

  @override
  State<MusicVisualizer> createState() => _MusicVisualizerState();
}

class _MusicVisualizerState extends State<MusicVisualizer> with TickerProviderStateMixin {
  late List<AnimationController> controllers;
  final List<int> durations = [900, 700, 600, 800, 500];

  @override
  void initState() {
    super.initState();
    controllers = List.generate(5, (index) {
      return AnimationController(vsync: this, duration: Duration(milliseconds: durations[index]))..repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    for (var c in controllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return AnimatedBuilder(
            animation: controllers[index],
            builder: (context, child) {
              return Container(
                width: 5,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: widget.isPlaying ? 8 + (25 * controllers[index].value) : 4,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(5)),
              );
            },
          );
        }),
      ),
    );
  }
}