import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:edupulse_ai/core/constants.dart';

class FirebaseGeminiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final GenerativeModel _model;
  ChatSession? _chatSession;

  FirebaseGeminiService();

  /// Initializes or retrieves the current chat session with dynamic system instructions
  Future<ChatSession> _getChatSession(String userInput) async {
    if (_chatSession != null) return _chatSession!;

    // 1. Retrieve context from Firestore (Syllabus/Curriculum Data)
    final textbookDocs = await _firestore
        .collection('textbook_chunks')
        .limit(3) // Fetching relevant context
        .get();

    final syllabusContext = textbookDocs.docs
        .map((doc) => doc.data()['text'] as String)
        .join('\n\n');

    // 2. Retrieve student history/mistakes for personalization
    final mistakeDocs = await _firestore
        .collection('mistake_log')
        .orderBy('timestamp', descending: true)
        .limit(2)
        .get();

    final studentHistory = mistakeDocs.docs.map((doc) {
      final data = doc.data();
      return "Mistake: ${data['error_type']} on ${data['question']}. User said ${data['user_answer']}.";
    }).join('\n');

    // 3. Create the System Instruction (Source of Truth)
    final systemInstruction = '''
You are EasAI, an expert educational assistant for the KitaHack 2026 hackathon.
Your CORE CAUSE is to help students learn accurately based on the KPM Malaysia syllabus.

SOURCE OF TRUTH (Syllabus Data):
$syllabusContext

STUDENT CONTEXT (Personalization):
$studentHistory

RULES:
1. ONLY answer based on the provided Syllabus Data.
2. If the data is missing, admit you don't know and suggest related syllabus topics.
3. Be encouraging but rigorous.
4. Reference the student's past mistakes to help them avoid repeating them.
5. Use gemini-2.5-flash capabilities for high-speed, accurate reasoning.
''';

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConstants.geminiApiKey,
      systemInstruction: Content.system(systemInstruction),
    );

    _chatSession = _model.startChat(history: []);

    return _chatSession!;
  }

  Future<String> chat(String message) async {
    try {
      final session = await _getChatSession(message);
      final response = await session.sendMessage(Content.text(message));
      return response.text ?? "I'm having trouble thinking right now.";
    } catch (e) {
      // If gemini-2.5-flash still errors, we catch it here
      return "AI Connection Error: $e. Please verify model string reliability.";
    }
  }
}
