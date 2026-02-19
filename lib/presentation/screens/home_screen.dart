
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/track.dart';
import '../../logic/blocs/home_bloc.dart';
import 'track_details_screen.dart';
import '../../core/di/injection_container.dart' as di;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<HomeBloc>()..add(LoadHomeData()),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HomeError) {
                return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
              } else if (state is HomeLoaded) {
                 return RefreshIndicator(
                   onRefresh: () async {
                     context.read<HomeBloc>().add(LoadHomeData());
                   },
                   child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Music for You', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                                    onPressed: () {},
                                  ),
                                  const SizedBox(width: 8),
                                   const CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Section 1: Top Artists (Using Real Tracks as proxy for now)
                        if (state.topArtists.isNotEmpty) ...[
                          _buildSectionHeader('Top Hits (Drake)'),
                          SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: state.topArtists.length,
                              itemBuilder: (context, index) {
                                final track = state.topArtists[index];
                                return GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackDetailsScreen(track: track))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundImage: CachedNetworkImageProvider(track.albumCover),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            track.artistName, 
                                            maxLines: 1, 
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        // Section 2: Featured Album (First item from recommended)
                        if (state.recommended.isNotEmpty) ...[
                          _buildSectionHeader('New Release'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackDetailsScreen(track: state.recommended.first))),
                              child: Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(state.recommended.first.albumCover.replaceAll('100x100', '600x600')), // High res attempt
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  alignment: Alignment.bottomLeft,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                       Text(state.recommended.first.title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                       Text(state.recommended.first.artistName, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Section 3: Recently Played
                        if (state.recent.isNotEmpty) ...[
                          _buildSectionHeader('Recently Played'),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: state.recent.length,
                              itemBuilder: (context, index) {
                                final track = state.recent[index];
                                return GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackDetailsScreen(track: track))),
                                  child: Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: CachedNetworkImage(
                                            imageUrl: track.albumCover,
                                            height: 110,
                                            width: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                        Text(track.artistName, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ] else ...[
                           _buildSectionHeader('Recently Played'),
                           const Padding(
                             padding: EdgeInsets.symmetric(horizontal: 16),
                             child: Text("No recently played songs yet.", style: TextStyle(color: Colors.grey)),
                           ),
                        ],

                        // Section 4: Recommended
                        if (state.recommended.isNotEmpty) ...[
                          _buildSectionHeader('Trending Now'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: state.recommended.skip(1).take(5).map((track) {
                                return GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackDetailsScreen(track: track))),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: track.albumCover,
                                          width: 50, height: 50, fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(color: Colors.white)),
                                      subtitle: Text(track.artistName, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                                      trailing: const Icon(Icons.play_circle_fill, color: Color(0xFFBB86FC)),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                 );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}
