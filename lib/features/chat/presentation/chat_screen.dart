import 'package:flutter/material.dart';
import 'package:edupulse_ai/core/theme/app_theme.dart';
import 'package:edupulse_ai/services/rag_service.dart';

/// The main chat interface for the General Syllabus Assistant.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Initialize the generalized RagService
  final RagService _ragService = RagService();

  bool _isLoading = false;

  // Initial greeting message acting as a general tutor
  final List<Map<String, dynamic>> _messages = [
    {
      "isUser": false,
      "message":
          "Hello! I am EasAI. I have indexed your syllabus textbooks and mistake logs. What subject or topic would you like to ask about today?",
      "timestamp": "Now",
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Handles sending the user's message and retrieving the AI's response
  void _sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;

    // Display user's message in the UI immediately
    _addMessage(userText, true);

    setState(() => _isLoading = true);
    _controller.clear();
    _scrollToBottom();

    try {
      // Fetch response using the general syllabus database
      final response = await _ragService.askGeneralQuestion(userText);
      if (mounted) _addMessage(response, false);
    } catch (e) {
      if (mounted) _addMessage("I encountered an error: $e", false);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  /// Helper to append a new message to the chat list
  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add({
        "isUser": isUser,
        "message": text,
        "timestamp": _formatTime(DateTime.now()),
      });
    });
  }

  /// Formats the DateTime object into a readable time string (e.g., 4:30 PM)
  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return "$hour:${time.minute.toString().padLeft(2, '0')} $amPm";
  }

  /// Smoothly scrolls the list view to the newest message
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                // Display loading indicator if waiting for AI response
                if (index == _messages.length) return _buildLoadingIndicator();
                final msg = _messages[index];
                return ChatBubble(
                  isUser: msg['isUser'],
                  message: msg['message'],
                  timestamp: msg['timestamp'],
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  /// Builds the top app bar with generalized database terminology
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon:
            const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EASAI ASSISTANT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
          ),
          const Text(
            'KPM SYLLABUS DATABASE', // Generalized subtitle
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                'Gemini 2.0 Active',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        )
      ],
    );
  }

  /// Builds the loading text shown when the AI is fetching data
  Widget _buildLoadingIndicator() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 16, bottom: 8),
        child: Text(
          "EasAI is searching your syllabus database...", // Generalized loading text
          style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  /// Builds the text input area at the bottom of the screen
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.backgroundNavy,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText:
                      "Ask anything about your syllabus...", // Generalized hint
                  hintStyle:
                      TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.accentPurple, Color(0xFFD946EF)]),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

/// A reusable widget for displaying individual chat messages
class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String message;
  final String timestamp;

  const ChatBubble(
      {super.key,
      required this.isUser,
      required this.message,
      required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) _buildAvatar(Icons.smart_toy, AppColors.accentPurple),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isUser ? AppColors.primaryBlue : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                ),
                child: Text(message,
                    style: const TextStyle(color: Colors.white, height: 1.4)),
              ),
            ),
            if (isUser) _buildAvatar(Icons.person, AppColors.textPrimary),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding:
              EdgeInsets.only(left: isUser ? 0 : 48, right: isUser ? 48 : 0),
          child: Text("${isUser ? 'You' : 'EasAI'} • $timestamp",
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ),
      ],
    );
  }

  /// Helper to build the circular avatars next to chat bubbles
  Widget _buildAvatar(IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: const Color(0xFF334155),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}
