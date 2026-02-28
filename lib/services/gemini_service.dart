import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:edupulse_ai/core/constants.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: AppConstants.geminiApiKey,
    );
  }

  /// AI Pre-analysis based strictly on the extracted page/chapter text
  Future<String> analyzePage(String pageText, int pageNumber) async {
    try {
      final prompt = [
        Content.text("You are an AI tutor for EduPulse AI. "
            "This is the text of page/chapter $pageNumber of the textbook:\n\n"
            "\"$pageText\"\n\n"
            "Provide a 'Pre-analysis' summary in 5 short bullet points. "
            "Focus strictly on the key formulas, definitions, or concepts visible in this text."),
      ];

      final response = await _model.generateContent(prompt);
      return response.text ?? "No analysis available for this page.";
    } catch (e) {
      return "Error during pre-analysis: $e";
    }
  }

  /// Context-Aware Chatbot that retains memory and answers STRICTLY based on the chapter
  Future<String> chatWithContext(String userQuery, String pageContext,
      List<Map<String, String>> history) async {
    try {
      final List<Content> contextHistory = [];

      // Build the chat history to retain memory
      for (int i = 0; i < history.length; i++) {
        final msg = history[i];
        if (msg["text"] == null || msg["text"]!.isEmpty) continue;

        if (i < history.length - 1) {
          contextHistory.add(msg["role"] == "user"
              ? Content.text(msg["text"]!)
              : Content.model([TextPart(msg["text"]!)]));
        }
      }

      final chat = _model.startChat(history: contextHistory);

      // Strict prompt enforcing textbook-only answers
      final fullQuery = "[CONTEXT]\n"
          "The following is the extracted text content from the current textbook chapter:\n"
          "---\n$pageContext\n---\n\n"
          "[USER INPUT]\n$userQuery\n\n"
          "[INSTRUCTION]\n"
          "Answer the user question STRICTLY based on the provided context above. Do not deviate. If the answer cannot be found in the provided chapter text, explicitly state that you cannot answer based on the current chapter.";

      final response = await chat.sendMessage(Content.text(fullQuery));
      return response.text ?? "No response available.";
    } catch (e) {
      return "Error: $e";
    }
  }
}
