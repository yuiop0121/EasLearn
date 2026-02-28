import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:edupulse_ai/core/constants.dart';

/// Service to handle AI interactions for EduPulse AI.
/// Uses Gemini 2.5 Flash and Firestore-based RAG for KitaHack 2026.
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GenerativeModel? _model;
  ChatSession? _chatSession;

  ChatService();

  /// Injects Firestore context into the model's system instruction.
  Future<void> _initializeChat() async {
    if (_chatSession != null) return;

    // 1. Fetch Curriculum Data (Syllabus context)
    final textbookDocs =
        await _firestore.collection('textbook_chunks').limit(3).get();

    final syllabusContext = textbookDocs.docs
        .map((doc) => doc.data()['text'] as String)
        .join('\n\n');

    // 2. Fetch Student Mistakes (Personalization)
    final mistakeDocs = await _firestore
        .collection('mistake_log')
        .orderBy('timestamp', descending: true)
        .limit(2)
        .get();

    final studentHistory = mistakeDocs.docs.map((doc) {
      final data = doc.data();
      return "- Mistake in ${data['error_type']} regarding ${data['question']}. User answer: ${data['user_answer']}.";
    }).join('\n');

    final systemInstruction = '''
You are EasAI, a specialized Secondary School Educational Assistant. Your persona is encouraging, professional, and strictly evidence-based.
Your goal is to provide accurate, syllabus-aligned assistance.

SYLLABUS CONTEXT:
$syllabusContext

STUDENT PROGRESS HISTORY:
$studentHistory

CORE RULES:
- Use ONLY the provided Syllabus Context for factual answers.
- If data is missing, admit it and suggest related topics.
- Address the student's past mistakes kindly if they recur.
- Every message in history MUST use the role 'user' (student) or 'model' (AI).
- No 'system' role allowed in chat history (it stays in this instruction).
''';

    // Create a NEW model instance with system instructions to prevent role errors
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: AppConstants.geminiApiKey,
      systemInstruction: Content.system(systemInstruction),
    );

    _chatSession = _model!.startChat();
  }

  /// Sends a message and returns the AI response.
  Future<String> sendMessage(String message) async {
    try {
      await _initializeChat();

      // History is handled automatically by _chatSession.
      // Roles are strictly 'user' for this call and 'model' for the response.
      final response = await _chatSession!.sendMessage(Content.text(message));

      return response.text ?? "I'm having trouble retrieving an answer.";
    } catch (e) {
      if (e.toString().contains('valid role')) {
        return "Role Validation Error: History roles must be 'user' or 'model'. System instructions moved to model initialization.";
      }
      return "AI connection error: $e";
    }
  }
}
