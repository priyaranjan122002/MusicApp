
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _dataSaver = false;
  bool _highQualityAudio = true;
  bool _offlineMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Profile Card
             Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 gradient: LinearGradient(colors: [Colors.grey[900]!, Colors.black]),
                 borderRadius: BorderRadius.circular(20),
                 boxShadow: [BoxShadow(color: const Color(0xFFBB86FC).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
                 border: Border.all(color: Colors.white12),
               ),
               child: Row(
                 children: [
                   const CircleAvatar(
                     radius: 35,
                     backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                   ),
                   const SizedBox(width: 20),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('John Doe', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                         const SizedBox(height: 4),
                         Text('john.doe@email.com', style: GoogleFonts.outfit(fontSize: 14, color: Colors.white54)),
                         const SizedBox(height: 8),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                           decoration: BoxDecoration(color: const Color(0xFFBB86FC), borderRadius: BorderRadius.circular(10)),
                           child: Text('PREMIUM', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                         ),
                       ],
                     ),
                   ),
                   IconButton(onPressed: () {}, icon: const Icon(Icons.edit, color: Colors.white54)),
                 ],
               ),
             ),
             
             const SizedBox(height: 30),
             
             _buildSectionHeader('Preferences'),
             _buildSwitchTile('Data Saver', _dataSaver, (v) => setState(() => _dataSaver = v)),
             _buildSwitchTile('High Quality Audio', _highQualityAudio, (v) => setState(() => _highQualityAudio = v)),
             _buildSwitchTile('Offline Mode', _offlineMode, (v) => setState(() => _offlineMode = v)),

             const SizedBox(height: 20),
             _buildSectionHeader('Account'),
             _buildActionTile(Icons.person_outline, 'Edit Profile'),
             _buildActionTile(Icons.notifications_outlined, 'Notifications'),
             _buildActionTile(Icons.lock_outline, 'Privacy & Security'),

             const SizedBox(height: 20),
             _buildSectionHeader('Support'),
             _buildActionTile(Icons.help_outline, 'Help & FAQ'),
             _buildActionTile(Icons.info_outline, 'About Us'),
             
             const SizedBox(height: 40),
             SizedBox(
               width: double.infinity,
               child: OutlinedButton(
                 onPressed: () {},
                 style: OutlinedButton.styleFrom(
                   side: const BorderSide(color: Colors.redAccent),
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 ),
                 child: Text('Sign Out', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold)),
               ),
             ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Text(title, style: GoogleFonts.outfit(color: const Color(0xFFBB86FC), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        activeColor: const Color(0xFFBB86FC),
        title: Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: () {},
      ),
    );
  }
}
