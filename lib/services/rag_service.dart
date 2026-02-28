import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:edupulse_ai/core/constants.dart';

/// Comprehensive RAG service that loads syllabus data for a General Chatbot.
class RagService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final GenerativeModel _model;

  // List of syllabus chapters from the GitHub repository
  final List<String> _allChapterUrls = [
    'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/1_Force_and_Motion_II.md',
    'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/2_Pressure.md',
    'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/3_Electricity.md',
    'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/4_Electromagnetism.md',
    'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/5_Electronics.md',
    'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/6_Nuclear_Physics.md',
    'https://cdn.jsdelivr.net/gh/Michelle-0107/EasLearnTextbook@main/7_Quantum_Physics.md',
  ];

  RagService() {
    // Initialize Gemini 2.0 Flash for high-speed reasoning
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: AppConstants.geminiApiKey,
    );
  }

  /// Fetches all syllabus documents concurrently and merges them into a single knowledge base.
  Future<String> _fetchAllTextbooks() async {
    try {
      // Execute all HTTP GET requests simultaneously for better performance
      final responses = await Future.wait(
          _allChapterUrls.map((url) => http.get(Uri.parse(url))));

      StringBuffer allContent = StringBuffer();
      for (int i = 0; i < responses.length; i++) {
        if (responses[i].statusCode == 200) {
          // Use a generic document label instead of specifically mentioning "Physics"
          allContent.writeln("--- SYLLABUS DOCUMENT ${i + 1} ---");
          allContent.writeln(responses[i].body);
          allContent.writeln("\n");
        }
      }
      return allContent.toString();
    } catch (e) {
      return "Error loading textbooks: $e";
    }
  }

  /// Retrieves the student's most recent mistakes from Firestore for personalized feedback.
  Future<String> _getStudentMistakeContext() async {
    try {
      final docs = await _firestore
          .collection('mistake_log')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      if (docs.docs.isEmpty) return "No prior mistake history found.";
      return docs.docs
          .map((d) =>
              "- Concept: ${d['error_type']} | Question: ${d['question']}")
          .join("\n");
    } catch (e) {
      return "History unavailable.";
    }
  }

  /// Main entry point for the General Chatbot.
  Future<String> askGeneralQuestion(String question) async {
    // Fetch ALL textbook data and student history in parallel
    final results = await Future.wait([
      _fetchAllTextbooks(),
      _getStudentMistakeContext(),
    ]);

    final String entireTextbookData = results[0];
    final String mistakeLog = results[1];

    // The system prompt is generalized so the AI acts as a comprehensive tutor.
    final finalPrompt = '''
You are EasAI, a comprehensive and professional tutor for the KPM Malaysian Syllabus.
You have access to the student's textbook database.

SYLLABUS CONTENT (Database):
$entireTextbookData

STUDENT PERSONALIZATION (Mistake History):
$mistakeLog

CORE INSTRUCTIONS:
1. Answer strictly based on the provided Syllabus Content. 
2. If the user asks about a topic found in their Mistake History, gently remind them of the core concept.
3. Be encouraging, professional, and concise. Act as a general tutor. Do NOT explicitly state that you "only have Physics data" unless the user asks about a subject clearly not in the database (in which case, just say "I haven't indexed that specific textbook yet").
4. IMPORTANT: Do NOT start your response with "model:" or "EasAI:". Do NOT output raw tool_code. Just provide the final answer directly in clean markdown.

USER QUESTION:
$question
''';

    try {
      // Send as a single user message to avoid role validation errors
      final response =
          await _model.generateContent([Content.text(finalPrompt)]);
      String finalAnswer =
          response.text ?? "I'm sorry, I couldn't generate a response.";

      // Clean up potential weird formatting from the model output
      finalAnswer = finalAnswer.replaceAll(
          RegExp(r'^model:\s*', caseSensitive: false), '');
      finalAnswer = finalAnswer.replaceAll(
          RegExp(r'^EasAI:\s*', caseSensitive: false), '');
      return finalAnswer.trim();
    } catch (e) {
      return "AI Connection Error: $e";
    }
  }
}
