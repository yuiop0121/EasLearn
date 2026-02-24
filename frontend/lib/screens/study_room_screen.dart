import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html; // For IFrame
import 'dart:ui' as ui; // For platform view registry
import '../constants.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';

class StudyRoomScreen extends StatefulWidget {
  final String chapterTitle;
  final int pageNumber;
  final String pdfUrl;

  const StudyRoomScreen({
    super.key,
    required this.chapterTitle,
    required this.pageNumber,
    required this.pdfUrl,
  });

  @override
  State<StudyRoomScreen> createState() => _StudyRoomScreenState();
}

class _StudyRoomScreenState extends State<StudyRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Register the IFrame view factory
    // Note: detailed implementation would require conditional import for non-web
    // but we are targeting web specifically here.
    final String viewId = 'pdf-viewer-${widget.chapterTitle.hashCode}';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => html.IFrameElement()
        ..src = widget.pdfUrl
        ..style.border = 'none'
        ..style.height = '100%'
        ..style.width = '100%'
        ..allowFullscreen = true,
    );
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final uid = userProvider.uid ?? "test_user_uid";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => chatProvider.clearHistory(),
            tooltip: "Clear Chat",
          ),
          Chip(
            label: Text("Mode: ${chatProvider.currentMode}"),
            backgroundColor: chatProvider.currentMode == "Standard"
                ? Colors.blue[100]
                : Colors.green[100],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // LEFT: PDF VIEW
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.grey[200],
              child: HtmlElementView(
                viewType: 'pdf-viewer-${widget.chapterTitle.hashCode}',
              ),
            ),
          ),
          
          // VERTICAL DIVIDER
          const VerticalDivider(width: 1),

          // RIGHT: CHAT INTERFACE
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatProvider.messages[index];
                      final isUser = msg.role == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 300),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blueAccent : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: isUser
                              ? Text(msg.content, style: const TextStyle(color: Colors.white))
                              : MarkdownBody(data: msg.content),
                        ),
                      );
                    },
                  ),
                ),
                if (chatProvider.isTyping) const LinearProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: (chatProvider.isTyping || chatProvider.messages.isEmpty)
                            ? null
                            : () async {
                                await chatProvider.regenerateResponse(uid, widget.chapterTitle);
                                _scrollToBottom();
                              },
                        tooltip: "Regenerate last response",
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: "Ask CikguAI...",
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (val) async {
                            await chatProvider.sendMessage(val, uid, widget.chapterTitle);
                            _controller.clear();
                            _scrollToBottom();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          final text = _controller.text;
                          await chatProvider.sendMessage(text, uid, widget.chapterTitle);
                          _controller.clear();
                          _scrollToBottom();
                        },
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
  }
}
