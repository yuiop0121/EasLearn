import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';

class ChatMessage {
  final String role; // 'user' or 'model'
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String _currentMode = "Standard";

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  String get currentMode => _currentMode;

  // 1. Send Message
  Future<void> sendMessage(String text, String uid, String chapter) async {
    if (text.trim().isEmpty) return;

    // Add user message locally
    _messages.add(ChatMessage(role: 'user', content: text));
    _isTyping = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$kBackendUrl/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "uid": uid,
          "message": text,
          "current_chapter_name": chapter,
          "history": _messages.take(_messages.length - 1).map((m) => m.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _messages.add(ChatMessage(role: 'model', content: data['response']));
        _currentMode = data['mode_used'];
      } else {
        _messages.add(ChatMessage(role: 'model', content: "Error: ${response.statusCode}"));
      }
    } catch (e) {
      _messages.add(ChatMessage(role: 'model', content: "Connection Failed: $e"));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  // 2. Clear History
  void clearHistory() {
    _messages.clear();
    _currentMode = "Standard";
    notifyListeners();
  }

  // 3. Regenerate Response
  Future<void> regenerateResponse(String uid, String chapter) async {
    if (_messages.isEmpty || _messages.last.role != 'model') return;

    // Remove last AI response
    _messages.removeLast();
    
    // Last message is now the user's prompt
    final lastUserMsg = _messages.last;
    if (lastUserMsg.role != 'user') return;

    _isTyping = true;
    notifyListeners();

    try {
        final response = await http.post(
        Uri.parse('$kBackendUrl/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "uid": uid,
          "message": lastUserMsg.content,
          "current_chapter_name": chapter,
          "history": _messages.take(_messages.length - 1).map((m) => m.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _messages.add(ChatMessage(role: 'model', content: data['response']));
        _currentMode = data['mode_used'];
      }
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }
}
