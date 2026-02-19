import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Search', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'What do you want to listen to?',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
              
              const SizedBox(height: 24),
              Text('Browse All', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5, // rectangular cards
                  ),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    final genres = ['Pop', 'Rock', 'Hip-Hop', 'Jazz', 'Electronic', 'Classical', 'Indie', 'Workout'];
                    final images = [
                      'https://picsum.photos/seed/pop/200/200',
                      'https://picsum.photos/seed/rock/200/200',
                      'https://picsum.photos/seed/hiphop/200/200',
                      'https://picsum.photos/seed/jazz/200/200',
                      'https://picsum.photos/seed/electro/200/200',
                      'https://picsum.photos/seed/classic/200/200',
                      'https://picsum.photos/seed/indie/200/200',
                      'https://picsum.photos/seed/workout/200/200',
                    ];
                    
                    return GestureDetector(
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exploring ${genres[index]}...')));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(images[index]),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          genres[index], 
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
