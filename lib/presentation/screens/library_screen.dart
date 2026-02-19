import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/library_bloc.dart';
import '../../data/models/track.dart';
import '../widgets/track_item.dart';
import 'track_details_screen.dart';
import 'artist_tracks_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<LibraryBloc>().add(LoadMoreTracks());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFBB86FC),
          backgroundColor: Colors.grey[900],
          onRefresh: () async {
            context.read<LibraryBloc>().add(LoadTracks());
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Custom Header for Library Tab
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Your Library', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                          const Icon(Icons.add, color: Colors.white, size: 28),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search tracks, artists...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.search, color: Colors.white54),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: (query) {
                           context.read<LibraryBloc>().add(SearchTracks(query));
                        },
                      ),
                      const SizedBox(height: 20),
                      // Recent Songs Horizontal
                      Text('Recent Songs', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                final dummyTrack = Track(
                                  id: index,
                                  title: 'Liked Song $index',
                                  artistName: 'Unknown Artist',
                                  albumCover: 'https://picsum.photos/seed/librecent/200/200',
                                  duration: 200,
                                );
                                Navigator.push(context, MaterialPageRoute(builder: (_) => TrackDetailsScreen(track: dummyTrack)));
                              },
                              child: Container(
                                width: 110,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 100, width: 110,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(8),
                                        image: const DecorationImage(image: NetworkImage('https://picsum.photos/seed/librecent/200/200'), fit: BoxFit.cover),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Liked Song $index', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Filter Chips Row
                      SizedBox(
                        height: 40,
                        child: BlocBuilder<LibraryBloc, LibraryState>(
                          builder: (context, state) {
                            final selected = (state is LibraryLoaded) ? state.selectedFilter : 'All';
                            return ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildFilterChip('All', selected == 'All'),
                                _buildFilterChip('Playlists', selected == 'Playlists'),
                                _buildFilterChip('Albums', selected == 'Albums'),
                                _buildFilterChip('Artists', selected == 'Artists'),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                   // 1. Loading
                  if (state is LibraryLoading || state is LibraryInitial) {
                     return SliverList(
                       delegate: SliverChildBuilderDelegate(
                         (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              height: 80,
                              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                            );
                         },
                         childCount: 6,
                       ),
                     );
                  }

                  // 2. Offline
                  if (state is LibraryNoInternet) {
                     return SliverFillRemaining(
                       child: Center(
                         child: Column(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Icon(Icons.wifi_off, size: 50, color: Colors.grey[400]),
                             const Text('NO INTERNET CONNECTION', style: TextStyle(color: Colors.red)),
                             TextButton(onPressed: () => context.read<LibraryBloc>().add(LoadTracks()), child: const Text('Retry'))
                           ],
                         ),
                       ),
                     );
                  }
                  
                  // 3. Error
                  if (state is LibraryError) {
                      return const SliverFillRemaining(child: Center(child: Text('Error loading library', style: TextStyle(color: Colors.red))));
                  }

                  if (state is LibraryLoaded) {
                    // --- PLAYLISTS VIEW ---
                    if (state.selectedFilter == 'Playlists') {
                       final playlists = ['Liked Songs', 'Trending', 'Valentine Special', '90s Hits', 'Gym Motivation', 'Sleep', 'Party Mix'];
                       final playlistImages = [
                         'https://picsum.photos/seed/liked/300/300',
                         'https://picsum.photos/seed/trend/300/300',
                         'https://picsum.photos/seed/val/300/300',
                         'https://picsum.photos/seed/90s/300/300',
                         'https://picsum.photos/seed/gym/300/300',
                         'https://picsum.photos/seed/sleep/300/300',
                         'https://picsum.photos/seed/party/300/300',
                       ];

                       return SliverList(
                         delegate: SliverChildBuilderDelegate(
                           (context, index) {
                             return ListTile(
                               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                               leading: Container(
                                 width: 60, height: 60,
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(8),
                                   image: DecorationImage(image: NetworkImage(playlistImages[index]), fit: BoxFit.cover),
                                 ),
                               ),
                               title: Text(playlists[index], style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                               subtitle: Text('${(index + 5) * 10} Songs', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                               trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                               onTap: () {},
                             );
                           },
                           childCount: playlists.length,
                         ),
                       );
                    }
                    
                    // --- ALBUMS VIEW ---
                    if (state.selectedFilter == 'Albums') {
                       return SliverPadding(
                         padding: const EdgeInsets.all(16),
                         sliver: SliverGrid(
                           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                             crossAxisCount: 2,
                             childAspectRatio: 0.75,
                             crossAxisSpacing: 16,
                             mainAxisSpacing: 16,
                           ),
                           delegate: SliverChildBuilderDelegate(
                             (context, index) {
                               return Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Expanded(
                                     child: Container(
                                       decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(12),
                                         image: DecorationImage(
                                           image: NetworkImage('https://picsum.photos/seed/album$index/300/300'),
                                           fit: BoxFit.cover,
                                         ),
                                       ),
                                     ),
                                   ),
                                   const SizedBox(height: 8),
                                   Text('Album Name $index', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                   Text('Artist Name', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                                 ],
                               );
                             },
                             childCount: 10,
                           ),
                         ),
                       );
                    }

                    // --- ARTISTS VIEW ---
                    if (state.selectedFilter == 'Artists') {
                       final artists = ['The Weeknd', 'Drake', 'Taylor Swift', 'BTS', 'Ariana Grande', 'Post Malone', 'Ed Sheeran', 'Justin Bieber'];
                       final artistImages = List.generate(artists.length, (i) => 'https://i.pravatar.cc/150?img=${i + 10}');
                       
                       return SliverToBoxAdapter(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                               Padding(
                                 padding: const EdgeInsets.all(16.0),
                                 child: TextField(
                                   decoration: InputDecoration(
                                     hintText: 'Search artists...',
                                     prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                     fillColor: Colors.white10,
                                     filled: true,
                                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                     contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                   ),
                                 ),
                               ),
                               ...List.generate(artists.length, (index) {
                                 return ListTile(
                                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                   leading: CircleAvatar(
                                     radius: 30,
                                     backgroundImage: NetworkImage(artistImages[index]),
                                   ),
                                   title: Text(artists[index], style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                   subtitle: Text('Artist', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                                   trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                   onTap: () {
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(builder: (_) => ArtistTracksScreen(artistName: artists[index])),
                                     );
                                   },
                                 );
                               }),
                           ],
                         ),
                       );
                    }
                    
                    // --- ALL TRACKS VIEW ---
                    final tracks = state.tracks;
                    if (tracks.isEmpty) {
                       return const SliverFillRemaining(child: Center(child: Text('No tracks found', style: TextStyle(color: Colors.white))));
                    }
                    
                    final groups = <String, List<Track>>{};
                    for (var track in tracks) {
                        String key = track.title.isNotEmpty ? track.title[0].toUpperCase() : '#';
                        final validKey = RegExp(r'[A-Z]').hasMatch(key) ? key : '#';
                        if (!groups.containsKey(validKey)) groups[validKey] = [];
                        groups[validKey]!.add(track);
                    }
                    final sortedKeys = groups.keys.toList()..sort();

                    return SliverMainAxisGroup(
                      slivers: sortedKeys.map((key) {
                        return SliverMainAxisGroup(
                          slivers: [
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _HeaderDelegate(key),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final track = groups[key]![index];
                                  return TrackItem(
                                    track: track,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => TrackDetailsScreen(track: track),
                                        ),
                                      );
                                    },
                                  );
                                },
                                childCount: groups[key]!.length,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  }
                  
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Loading More Indicator
              BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  if (state is LibraryLoaded && !state.hasReachedMax && state.selectedFilter == 'All') {
                     return SliverToBoxAdapter(
                       child: Padding(
                         padding: const EdgeInsets.all(20.0),
                         child: Center(
                           child: Column(
                             children: const [
                               CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFBB86FC)),
                               SizedBox(height: 8),
                               Text('Loading more...', style: TextStyle(color: Colors.grey)),
                             ],
                           ),
                         ),
                       ),
                     );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
             context.read<LibraryBloc>().add(FilterTracks(label));
          },
          borderRadius: BorderRadius.circular(30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFBB86FC) : const Color(0xFF1E1E1E), 
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? const Color(0xFFBB86FC) : Colors.white12,
                width: 1,
              ),
              boxShadow: isSelected ? [
                 BoxShadow(color: const Color(0xFFBB86FC).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
              ] : [],
            ),
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  _HeaderDelegate(this.title);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black, 
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold, 
          fontSize: 20, 
          color: const Color(0xFFBB86FC)
        ),
      ),
    );
  }

  @override
  double get maxExtent => 45;

  @override
  double get minExtent => 45;

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) {
    return oldDelegate.title != title;
  }
}
