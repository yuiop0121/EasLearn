import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String chapterTitle;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.chapterTitle,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  // State Management
  PdfTextSearchResult? _searchResult;
  bool _isSearching = false;
  int _currentPage = 1;
  int _totalPageCount = 0;
  double _viewScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildPdfViewer(),
          _buildPageNavigationPill(),
        ],
      ),
      bottomNavigationBar: _buildBottomControlBar(),
    );
  }

  // --- AppBar with AI Integration Point ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF003366),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        widget.chapterTitle,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.psychology, color: Colors.amber),
          onPressed: _showAiExplanation,
          tooltip: 'AI Explain Page',
        ),
      ],
    );
  }

  // --- Core PDF Viewer ---
  Widget _buildPdfViewer() {
    return Center(
      child: Transform.scale(
        scale: _viewScale,
        child: SfPdfViewer.network(
          widget.pdfUrl,
          key: _pdfViewerKey,
          controller: _pdfViewerController,
          canShowScrollHead: false,
          pageLayoutMode: PdfPageLayoutMode.single,
          onDocumentLoaded: (details) {
            setState(() => _totalPageCount = details.document.pages.count);
          },
          onPageChanged: (details) {
            setState(() => _currentPage = details.newPageNumber);
          },
        ),
      ),
    );
  }

  // --- Floating Page Navigation ---
  Widget _buildPageNavigationPill() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF003366).withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 18),
                onPressed: () => _pdfViewerController.previousPage(),
              ),
              Text(
                'Page $_currentPage of $_totalPageCount',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 18),
                onPressed: () => _pdfViewerController.nextPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Bottom Controls (Search & Zoom) ---
  Widget _buildBottomControlBar() {
    return BottomAppBar(
      color: const Color(0xFF003366),
      height: 80,
      child: _isSearching ? _buildSearchInput() : _buildDefaultControls(),
    );
  }

  Widget _buildDefaultControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
            Icons.search, 'Search', () => setState(() => _isSearching = true)),
        _buildActionButton(Icons.zoom_in, 'Zoom',
            () => setState(() => _pdfViewerController.zoomLevel += 0.5)),
        _buildActionButton(
            Icons.zoom_out,
            'Scale',
            () => setState(
                () => _viewScale = (_viewScale - 0.1).clamp(0.4, 1.0))),
        _buildActionButton(Icons.refresh, 'Reset', () {
          setState(() {
            _viewScale = 1.0;
            _pdfViewerController.zoomLevel = 1.0;
          });
        }),
      ],
    );
  }

  Widget _buildSearchInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search syllabus...',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
            onSubmitted: _executeSearch,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_upward, color: Colors.white),
          onPressed: () => _searchResult?.previousInstance(),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_downward, color: Colors.white),
          onPressed: () => _searchResult?.nextInstance(),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.redAccent),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchResult?.clear();
            });
          },
        ),
      ],
    );
  }

  // --- Search Logic (Fixed) ---
  void _executeSearch(String text) {
    if (text.isEmpty) return;

    // Fixed: Using default search to avoid version-specific enum errors
    _searchResult = _pdfViewerController.searchText(text);

    _searchResult?.addListener(() {
      if (mounted) setState(() {});
    });

    if (_searchResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search failed to initialize')),
      );
    }
  }

  // --- AI Placeholder ---
  void _showAiExplanation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.amber[800],
        content: Text('EduPulse AI is analyzing page $_currentPage content...'),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }
}
