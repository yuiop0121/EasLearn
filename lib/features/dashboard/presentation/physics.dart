import 'package:flutter/material.dart';
import 'pdf_viewer_screen.dart'; // 👈 Imports your new native PDF screen!

class PhysicsChaptersScreen extends StatelessWidget {
  const PhysicsChaptersScreen({super.key});

  final List<Map<String, String>> chapters = const [
    {
      'id': '1',
      'title': 'Force and Motion II',
      'subtitle': 'Fundamentals & Scope',
      // 👇 Pure Raw Link - No Google Docs hack needed anymore!
      'pdfUrl':
          'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/phyc1.pdf'
    },
    {
      'id': '2',
      'title': 'Pressure',
      'subtitle': 'Kinematics and Velocity',
      'pdfUrl':
          'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/phyc2.pdf' // Add your raw link here later when you upload phyc2.pdf
    },
    {
      'id': '3',
      'title': 'Electricity',
      'subtitle': 'Newton\'s Laws of Motion',
      'pdfUrl':
          'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/phyc3.pdf'
    },
    {
      'id': '4',
      'title': 'Electromagnetism',
      'subtitle': 'Fluids and Atmospheric Pressure',
      'pdfUrl': ''
    },
    {
      'id': '5',
      'title': 'Electronics',
      'subtitle': 'Thermal Properties of Matter',
      'pdfUrl': ''
    },
    {
      'id': '6',
      'title': 'Nuclear Physics',
      'subtitle': 'Sound and Light Waves',
      'pdfUrl': ''
    },
    {
      'id': '7',
      'title': 'Quantum Physics',
      'subtitle': 'Currents, Circuits and Fields',
      'pdfUrl': ''
    },
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 600),
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context, isDesktop),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 20, vertical: 30),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildChapterTile(context, chapters[index], isDesktop),
                    childCount: chapters.length,
                  ),
                ),
              ),
              _buildAIQuizCard(isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDesktop) {
    return SliverAppBar(
      expandedHeight: isDesktop ? 180 : 150,
      collapsedHeight: 85,
      toolbarHeight: 85,
      pinned: true,
      backgroundColor: const Color(0xFF003366),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 20),
            onPressed: () {}),
        if (isDesktop) const SizedBox(width: 20),
      ],
      flexibleSpace: SafeArea(
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text('AI PRO',
                      style: TextStyle(
                        fontSize: isDesktop ? 11 : 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      )),
                ),
                const SizedBox(height: 8),
                Text(
                  'Physics Chapters',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: isDesktop ? 34 : 24,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '7 Chapters available',
                  style: TextStyle(
                      fontSize: isDesktop ? 14 : 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChapterTile(
      BuildContext context, Map<String, String> chapter, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D21),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding:
            EdgeInsets.symmetric(horizontal: isDesktop ? 30 : 20, vertical: 15),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(
            child: Text(chapter['id']!,
                style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 18)),
          ),
        ),
        title: Text(chapter['title']!,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        subtitle: Text(chapter['subtitle']!,
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: Colors.white24, size: 18),

        // 👇 This now smoothly transitions to your custom PDF Viewer Screen!
        onTap: () {
          final String? pdfUrl = chapter['pdfUrl'];

          if (pdfUrl != null && pdfUrl.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerScreen(
                  pdfUrl: pdfUrl,
                  chapterTitle: chapter['title']!,
                ),
              ),
            );
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Textbook not uploaded yet!')),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildAIQuizCard(bool isDesktop) {
    return SliverToBoxAdapter(
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20, vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF003366), Color(0xFF001122)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI ASSESSMENT',
                        style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    const Text('Ready for the Final Quiz?',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                        'Test your knowledge with AI-generated questions.',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {},
                child: const Text('Start Now →',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
