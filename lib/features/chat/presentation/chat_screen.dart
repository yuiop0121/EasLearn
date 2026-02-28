import 'package:flutter/material.dart';
import 'package:edupulse_ai/core/theme/app_theme.dart';
import 'package:edupulse_ai/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      "isUser": false,
      "message":
          "Hello! I am EasLearn AI. I've indexed your textbooks and mistake logs. How can I help you today?",
      "timestamp": "Now",
    },
  ];

  final ChatService _chatService = ChatService();
  bool _isLoading = false;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text.trim();
    final userMsg = {
      "isUser": true,
      "message": userText,
      "timestamp": _formatTime(DateTime.now()),
    };

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      // ChatService handles the system instruction and history roles correctly now
      final response = await _chatService.sendMessage(userText);

      if (mounted) {
        setState(() {
          _messages.add({
            "isUser": false,
            "message": response,
            "timestamp": _formatTime(DateTime.now()),
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            "isUser": false,
            "message": "Error: $e",
            "timestamp": _formatTime(DateTime.now()),
          });
          _isLoading = false;
        });
      }
    }
  }

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

  String _formatTime(DateTime time) {
    return "${time.hour > 12 ? time.hour - 12 : time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}";
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, bottom: 8),
                      child: Text(
                        "EasLearn AI is thinking...",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  );
                }
                final msg = _messages[index];
                return ChatBubble(
                  isUser: msg['isUser'],
                  message: msg['message'],
                  timestamp: msg['timestamp'],
                );
              },
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () {},
      ),
      title: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'EASLEARN AI ASSISTANT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
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
                'GPT-4 Omni Active',
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

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.backgroundNavy,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.mic_none,
                      color: AppColors.textSecondary),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  // Removed alignment: Alignment.centerLeft to let TextField fill
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Ask EasLearn anything...",
                            hintStyle:
                                TextStyle(color: AppColors.textSecondary),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      Icon(Icons.attach_file,
                          color: AppColors.textSecondary.withOpacity(0.5)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accentPurple, Color(0xFFD946EF)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionChip(context, "Summarize Page"),
                _buildActionChip(context, "Define Symbols"),
                _buildActionChip(context, "Practice Quiz"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        backgroundColor: AppColors.backgroundDark,
        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          _controller.text = label;
          _sendMessage();
        },
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String message;
  final String timestamp;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.message,
    required this.timestamp,
  });

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
            if (!isUser) ...[
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF334155),
                child: Icon(Icons.smart_toy,
                    size: 18, color: AppColors.accentPurple),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.primaryBlue
                      : const Color(0xFF1E293B), // Navy
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  border: isUser
                      ? null
                      : Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF334155),
                child:
                    Icon(Icons.person, size: 18, color: AppColors.textPrimary),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: EdgeInsets.only(
            left: isUser ? 0 : 48,
            right: isUser ? 48 : 0,
          ),
          child: Text(
            isUser ? "You • $timestamp" : "EasLearn AI • $timestamp",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
