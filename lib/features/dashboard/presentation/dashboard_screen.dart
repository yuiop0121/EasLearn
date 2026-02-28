import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart'; // NEW: Firebase Auth
import 'physics.dart';
import 'login_page.dart'; // NEW: Import Login Page

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showAll = false;

  final List<Map<String, dynamic>> _subjects = [
    {
      'title': 'Mathematics',
      'subtitle': 'Algebra & Geometry',
      'icon': 'Σ',
      'color': Colors.blue,
      'image': 'assets/mathematics.png'
    },
    {
      'title': 'Add. Mathematics',
      'subtitle': 'Calculus & Vectors',
      'icon': '∫',
      'color': Colors.purple,
      'image': 'assets/addmaths.png'
    },
    {
      'title': 'Physics',
      'subtitle': 'Forces & Motion',
      'icon': '⚡',
      'color': Colors.amber,
      'image': 'assets/physics.png'
    },
    {
      'title': 'Chemistry',
      'subtitle': 'Organic Compounds',
      'icon': '⚗',
      'color': Colors.cyan,
      'image': 'assets/chemistry.png'
    },
    {
      'title': 'Biology',
      'subtitle': 'Cell Structure',
      'icon': '🧬',
      'color': Colors.greenAccent,
      'image': 'assets/biology.png'
    },
    {
      'title': 'Science',
      'subtitle': 'General Concepts',
      'icon': '🔬',
      'color': Colors.orange,
      'image': 'assets/science.png'
    },
    {
      'title': 'Sejarah',
      'subtitle': 'Malaysian History',
      'icon': '📜',
      'color': Colors.brown,
      'image': 'assets/sejarah.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.5))),
          SafeArea(
            // NEW: Listen to Firebase Auth state to update UI dynamically
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data; // Get current user

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopNavBar(context, user),
                      const SizedBox(height: 50),
                      _buildCenteredGreetingPanel(context, user),
                      const SizedBox(height: 50),
                      _buildSubjectsHeader(context),
                      const SizedBox(height: 16),
                      _buildSubjectsGrid(context),
                      
                      // NEW: Bottom Sign Out Button (Only visible if signed in)
                      if (user != null) ...[
                        const SizedBox(height: 48),
                        Center(
                          child: TextButton.icon(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                            icon: const Icon(Icons.logout, color: Colors.white54),
                            label: const Text(
                              'Sign Out of EasLearn',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavBar(BuildContext context, User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Powered By Firebase',
                style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 10)),
            SizedBox(height: 4),
            Text('EasLearn',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 26)),
          ],
        ),
        Row(
          children: [
            _buildIconButton(Icons.notifications_outlined),
            const SizedBox(width: 12),
            _buildProfileAvatar(context, user), // Pass context and user here
          ],
        ),
      ],
    );
  }

  Widget _buildCenteredGreetingPanel(BuildContext context, User? user) {
    // NEW: Get the first name of the user or default to "Student"
    final displayName = user?.displayName?.split(' ').first ?? 'Student';

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(0.4),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hello, $displayName,', // NEW: Dynamic Name
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 10),
            Text(
              "Welcome back. Let's start learning!",
              style:
                  TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
            ),
            const SizedBox(height: 50),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.cyanAccent.withOpacity(0.7), width: 1.5),
                  color: Colors.cyanAccent.withOpacity(0.05),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.15),
                        blurRadius: 10,
                        spreadRadius: 1),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Start Learning',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0)),
                    SizedBox(width: 8),
                    Icon(Icons.lightbulb_outline,
                        color: Colors.cyanAccent, size: 14),
                    Icon(Icons.chevron_right,
                        color: Colors.cyanAccent, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Current Subjects',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        TextButton(
            onPressed: () => setState(() => _showAll = !_showAll),
            child: Text(_showAll ? 'Show Less' : 'View All',
                style: const TextStyle(color: Colors.cyanAccent))),
      ],
    );
  }

  Widget _buildSubjectsGrid(BuildContext context) {
    final displayedItems = _showAll ? _subjects : _subjects.take(4).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayedItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85),
      itemBuilder: (context, index) {
        final subject = displayedItems[index];
        return _buildSubjectCard(context, subject['title'], subject['subtitle'],
            subject['icon'], subject['color'], subject['image']);
      },
    );
  }

  Widget _buildSubjectCard(BuildContext context, String title, String subtitle,
      String icon, Color color, String? imagePath) {
    return GestureDetector(
      onTap: () {
        if (title == 'Physics') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PhysicsChaptersScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title is coming soon!'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.4),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          image: imagePath != null
              ? DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5), BlendMode.darken))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                    child: Text(icon,
                        style: TextStyle(
                            fontSize: 22,
                            color: color,
                            fontWeight: FontWeight.bold)))),
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                    value: 0.6,
                    backgroundColor: Colors.white10,
                    color: color,
                    minHeight: 4)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
        child: IconButton(
            onPressed: () {}, icon: Icon(icon, color: Colors.white, size: 20)));
  }

  // NEW: Dynamic Profile Avatar handling Sign In / Sign Out states
  Widget _buildProfileAvatar(BuildContext context, User? user) {
    if (user == null) {
      // Not signed in: Show clickable avatar that goes to login page
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
              color: Colors.cyanAccent, shape: BoxShape.circle),
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF1E293B),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      );
    }

    // Signed in: Show PopupMenu with user info and Logout option
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      color: const Color(0xFF1E293B), // Match your dark theme
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
            color: Colors.cyanAccent, shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF1E293B),
          backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child: user.photoURL == null
              ? const Icon(Icons.person, color: Colors.white, size: 20)
              : null,
        ),
      ),
      onSelected: (value) async {
        if (value == 'logout') {
          await FirebaseAuth.instance.signOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName ?? 'Student',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                user.email ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(color: Colors.white24),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.redAccent, size: 20),
              SizedBox(width: 8),
              Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    );
  }
}
