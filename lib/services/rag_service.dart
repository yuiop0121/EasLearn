import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rag_service.g.dart';

// Needs to be configured with actual API key
const String _apiKey = 'YOUR_API_KEY';

@riverpod
RagService ragService(RagServiceRef ref) {
  return RagService(
    firestore: FirebaseFirestore.instance,
    model: GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey),
    embeddingModel:
        GenerativeModel(model: 'text-embedding-004', apiKey: _apiKey),
  );
}

class RagService {
  final FirebaseFirestore firestore;
  final GenerativeModel model;
  final GenerativeModel embeddingModel;

  RagService({
    required this.firestore,
    required this.model,
    required this.embeddingModel,
  });

  Future<String> askQuestion(String question) async {
    // 1. Generate embedding for the question
    final content = Content.text(question);
    final embeddingResult = await embeddingModel.embedContent(content);
    final vector = embeddingResult.embedding.values;

    // 2. Retrieve relevant chunks from Firestore via Cloud Function
    final functions = FirebaseFunctions.instance;
    final httpsCallable =
        functions.httpsCallable('searchSimilarTextbookChunks');

    final result = await httpsCallable.call({
      'queryVector': vector,
      'limit': 5,
    });

    final List<dynamic> results = result.data['results'];
    final relevantChunks = results.map((doc) => doc['text'] as String).toList();

    if (relevantChunks.isEmpty) {
      return "I couldn't find any relevant information in the textbook to answer your question.";
    }

    final context = relevantChunks.join('\n\n');

    final prompt = '''
Answer ONLY based on the provided KPM textbook context. Maintain 100% syllabus accuracy. 
If the answer is not in the context, say "I don't know based on the provided textbook."

Context:
$context

Question:
$question
''';

    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? "I'm sorry, I couldn't generate an answer.";
  }
}
