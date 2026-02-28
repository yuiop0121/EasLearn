import 'package:flutter/material.dart';
import 'pdf_viewer_screen.dart';
import 'markdown_viewer_screen.dart';

class PhysicsChaptersScreen extends StatelessWidget {
  const PhysicsChaptersScreen({super.key});

  final List<Map<String, dynamic>> chapters = const [
    {
      'id': '1',
      'title': 'Force and Motion II',
      'subtitle': '1.1, 1.2, 1.3, 1.4',
      'pdfUrl':
          'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/phyc1.pdf',
      'subTopics': [
        {
          'title': 'Chapter 1 Note',
          'url':
              'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/1_Force_and_Motion_II.md'
        }
      ],
    },
    {
      'id': '2',
      'title': 'Pressure',
      'subtitle': '2.1, 2.2, 2.3, 2.4, 2.5',
      'pdfUrl':
          'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/phyc2.pdf',
      'subTopics': [
        {
          'title': 'Chapter 2 Note',
          'url':
              'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/2_Pressure.md'
        }
      ],
    },
    {
      'id': '3',
      'title': 'Electricity',
      'subtitle': '3.1, 3.2, 3.3, 3.4',
      'pdfUrl':
          'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/phyc3.pdf',
      'subTopics': [
        {
          'title': 'Chapter 3 Note',
          'url':
              'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/3_Electricity.md'
        }
      ],
    },
    {
      'id': '4',
      'title': 'Electromagnetism',
      'subtitle': '4.1, 4.2, 4.3',
      'pdfUrl':
          'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/phyc4.pdf',
      'subTopics': [
        {
          'title': 'Chapter 4 Note',
          'url':
              'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/4_Electromagnetism.md'
        }
      ],
    },
    {
      'id': '5',
      'title': 'Electronics',
      'subtitle': '5.1, 5.2, 5.3',
      'pdfUrl':
          'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/phyc5.pdf',
      'subTopics': [
        {
          'title': 'Chapter 5 Note',
          'url':
              'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/5_Electronics.md'
        }
      ],
    },
    {
      'id': '6',
      'title': 'Nuclear Physics',
      'subtitle': '6.1, 6.2',
      'pdfUrl':
          'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/phyc6.pdf',
      'subTopics': [
        {
          'title': 'Chapter 6 Note',
          'url':
              'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/6_Nuclear_Physics.md'
        }
      ],
    },
    {
      'id': '7',
      'title': 'Quantum Physics',
      'subtitle': '7.1, 7.2, 7.3',
      'pdfUrl':
          'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/phyc7.pdf',
      'subTopics': [
        {
          'title': 'Chapter 7 Note',
          'url':
              'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/7_Quantum_Physics.md'
        }
      ],
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
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, isDesktop),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 20, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ChapterExpandableCard(
                      chapter: chapters[index],
                      isDesktop: isDesktop,
                    ),
                    childCount: chapters.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDesktop) {
    return SliverAppBar(
      expandedHeight: 100,
      collapsedHeight: 70,
      pinned: true,
      centerTitle: true,
      backgroundColor: const Color(0xFF003366),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 12),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Physics Chapters',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const SizedBox(height: 2),
            Text('${chapters.length} Chapters available',
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class ChapterExpandableCard extends StatefulWidget {
  final Map<String, dynamic> chapter;
  final bool isDesktop;

  const ChapterExpandableCard(
      {super.key, required this.chapter, required this.isDesktop});

  @override
  State<ChapterExpandableCard> createState() => _ChapterExpandableCardState();
}

class _ChapterExpandableCardState extends State<ChapterExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerScreen(
                    pdfUrl: widget.chapter['pdfUrl'],
                    chapterTitle: widget.chapter['title'],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D21),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: Text(widget.chapter['id'],
                        style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.chapter['title'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(widget.chapter['subtitle'],
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white24, size: 16),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF003366),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.note_alt, color: Colors.amber, size: 14),
                  const SizedBox(width: 6),
                  const Text('Quick Note',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 14),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: (widget.chapter['subTopics'] as List).map((topic) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.circle,
                        size: 6, color: Colors.blueAccent),
                    title: Text(topic['title'],
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MarkdownViewerScreen(
                            url: topic['url'],
                            title: topic['title'],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
