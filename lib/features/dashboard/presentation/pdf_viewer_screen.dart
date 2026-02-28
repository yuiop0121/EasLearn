import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart'; // Ensure this is in pubspec.yaml
import 'package:edupulse_ai/services/gemini_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String chapterTitle;

  const PdfViewerScreen(
      {super.key, required this.pdfUrl, required this.chapterTitle});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GeminiService _geminiService = GeminiService();
  final PageController _pageController = PageController();
  final TransformationController _transformationController =
      TransformationController();

  PdfDocument? _document;

  String _currentSummary = "Flip to a page to see AI Pre-analysis...";
  bool _isAnalyzing = false;
  bool _showAiPanel = false; // Hidden by default
  Timer? _debounce;

  int _currPage = 1;
  int _totalPage = 1;

  // AI Chat & RAG State
  final List<Map<String, String>> _chatHistory = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  String _currentPageText = "";
  bool _isChatting = false;

  @override
  void initState() {
    super.initState();
    _initDocument();
  }

  Future<void> _initDocument() async {
    try {
      final doc = await PdfDocument.openUri(Uri.parse(widget.pdfUrl));
      if (mounted) {
        setState(() {
          _document = doc;
          _totalPage = doc.pages.length;
        });
        _onPageChanged(1); // Trigger analysis for the first page
      }
    } catch (e) {
      debugPrint("Error loading PDF: $e");
    }
  }

  void _onPageChanged(int pageNumber) async {
    if (mounted) {
      setState(() {
        _currPage = pageNumber;
      });
      // Optionally reset zoom when changing pages
      _transformationController.value = Matrix4.identity();
    }

    try {
      if (_document != null) {
        final page = _document!.pages[pageNumber - 1];
        final textObj = await page.loadText();
        _currentPageText = textObj.fullText;
      }
    } catch (e) {
      debugPrint("Could not extract text for RAG: $e");
      _currentPageText = "";
    }

    if (!_showAiPanel) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;
      setState(() => _isAnalyzing = true);

      try {
        if (_document == null) return;

        // Trigger AI Agent analysis using extracted text
        final result =
            await _geminiService.analyzePage(_currentPageText, pageNumber);

        if (mounted) {
          setState(() {
            _currentSummary = result;
            _isAnalyzing = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _currentSummary = "AI analysis paused. Please stay on the page.";
            _isAnalyzing = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        elevation: 0,
        centerTitle: true,
        title: Text(widget.chapterTitle,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome), // AI styled icon
            onPressed: () {
              setState(() {
                _showAiPanel = !_showAiPanel;
              });
              if (_showAiPanel) {
                _onPageChanged(_currPage); // Retrigger analysis if opened
              }
            },
            tooltip: 'Toggle AI Analysis',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRect(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1.0,
                    maxScale: 5.0,
                    clipBehavior: Clip.hardEdge,
                    child: Center(
                      child: _document == null
                          ? const CircularProgressIndicator()
                          : PageView.builder(
                              controller: _pageController,
                              onPageChanged: (idx) => _onPageChanged(idx + 1),
                              itemCount: _totalPage,
                              itemBuilder: (context, index) {
                                return Align(
                                  alignment: Alignment.center,
                                  child: PdfPageView(
                                    document: _document,
                                    pageNumber: index + 1,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
                // Top Page Pill (Moved to bottom, overlapping edge)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                      child: Opacity(opacity: 0.8, child: _buildPagePill())),
                ),
                // AI Panel (Floating Overlay)
                if (_showAiPanel) _buildTopRightAnalysisPanel(),
              ],
            ),
          ),
          _buildBottomFeatureBar(),
        ],
      ),
    );
  }

  Widget _buildPagePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF003366),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (_currPage > 1) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 16),
          Text(
            "Page $_currPage of $_totalPage",
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              if (_currPage < _totalPage) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomFeatureBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: const Color(0xFF003366),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min, // Group buttons together tightly
          children: [
            _featureButton(Icons.search, "Search", () {}),
            const SizedBox(width: 8),
            _featureButton(Icons.zoom_in, "Zoom In", _zoomIn),
            const SizedBox(width: 8),
            _featureButton(Icons.fullscreen_exit, "Fit", _resetZoom),
            const SizedBox(width: 8),
            _featureButton(Icons.zoom_out, "Zoom Out", _zoomOut),
          ],
        ),
      ),
    );
  }

  void _zoomIn() {
    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    if (scale < 5.0) {
      // arbitrary max scale
      _scaleAtCenter(1.2);
    }
  }

  void _zoomOut() {
    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    if (scale > 1.0) {
      _scaleAtCenter(1 / 1.2);
    } else {
      _resetZoom();
    }
  }

  void _resetZoom() {
    // Reset exactly to original non-scrolling size and centered
    _transformationController.value = Matrix4.identity();
  }

  void _scaleAtCenter(double scaleFactor) {
    if (!mounted) return;

    // We want to scale around the center of the viewport
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    // Calculate center of the InteractiveViewer area
    // The Expanded widget takes the remaining space, subtracting the Appbar and BottomAppBar
    final center =
        Offset(size.width / 2, (size.height - kToolbarHeight - 80) / 2);

    final matrix = _transformationController.value;

    // Calculate new matrix zooming towards the center
    final newMatrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(scaleFactor)
      ..translate(-center.dx, -center.dy)
      ..multiply(matrix);

    // Apply some constraints if needed, but for now we just set it
    _transformationController.value = newMatrix;
  }

  Widget _featureButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRightAnalysisPanel() {
    return Positioned(
      top: 20,
      right: 20,
      bottom: 20, // Allow space to grow downward
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D21).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.psychology,
                    color: Colors.cyanAccent, size: 18),
                const SizedBox(width: 8),
                const Text("AI TUTOR",
                    style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _showAiPanel = false),
                  child:
                      const Icon(Icons.close, color: Colors.white54, size: 16),
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 16),

            // AI Pre-Analysis Section
            if (_isAnalyzing)
              const LinearProgressIndicator(
                  backgroundColor: Colors.transparent, minHeight: 2),
            const Text("Page Analysis:",
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_currentSummary,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12, height: 1.4)),
            const Divider(color: Colors.white10, height: 24),

            // Chat History ListView
            Expanded(
              child: ListView.builder(
                controller: _chatScrollController,
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final chat = _chatHistory[index];
                  final isUser = chat["role"] == "user";
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.blueAccent.withOpacity(0.2)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        chat["text"] ?? "",
                        style: TextStyle(
                            color: isUser ? Colors.blue[100] : Colors.white,
                            fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isChatting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("AI is thinking...",
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontStyle: FontStyle.italic)),
              ),

            // Chat Input Field
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: "Ask about this page...",
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (val) => _handleSendChat(val),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.blueAccent, size: 16),
                    onPressed: () => _handleSendChat(_chatController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSendChat(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;

    if (mounted) {
      setState(() {
        _chatHistory.add({"role": "user", "text": text});
        _isChatting = true;
      });
      _chatController.clear();
      _scrollToBottom();
    }

    final aiResponse = await _getChatResponse(text, _currentPageText);

    if (mounted) {
      setState(() {
        _chatHistory.add({"role": "ai", "text": aiResponse});
        _isChatting = false;
      });
      _scrollToBottom();
    }
  }

  Future<String> _getChatResponse(String userQuery, String pageContext) async {
    return await _geminiService.chatWithContext(
        userQuery, pageContext, _chatHistory);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _transformationController.dispose();
    _pageController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    _document?.dispose();
    super.dispose();
  }
}
