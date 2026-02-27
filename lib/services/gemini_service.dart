// lib/services/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:edupulse_ai/core/constants.dart'; // This links to your API Key
import 'package:flutter/foundation.dart'; // 引入这个来判断是不是 Web

class GeminiService {
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConstants.geminiApiKey,
    );
    _visionModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConstants.geminiApiKey,
    );
  }

  // 修改后的 Feature 5: 支持 Web 的评分逻辑
  // 我们改用 Uint8List（字节数组），因为无论手机还是网页都支持它
  Future<String> gradeAnswer(Uint8List imageBytes, String markScheme) async {
    final prompt = [
      Content.multi([
        TextPart(
            "Grade this student answer against this marking scheme: $markScheme. Provide a score and feedback."),
        DataPart('image/jpeg', imageBytes),
      ]),
    ];
    final response = await _visionModel.generateContent(prompt);
    return response.text ?? "Error grading answer.";
  }

  // Chat Logic
  ChatSession? _chatSession;

  ChatSession get chatSession {
    _chatSession ??= _model.startChat();
    return _chatSession!;
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await chatSession.sendMessage(Content.text(message));
      return response.text ?? "I couldn't generate a response.";
    } catch (e) {
      return "Error: $e";
    }
  }
}
