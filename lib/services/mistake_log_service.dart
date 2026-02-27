import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mistake_log_service.g.dart';

@riverpod
MistakeLogService mistakeLogService(MistakeLogServiceRef ref) {
  return MistakeLogService(firestore: FirebaseFirestore.instance);
}

class MistakeLogService {
  final FirebaseFirestore firestore;

  MistakeLogService({required this.firestore});

  Future<void> logMistake({
    required String question,
    required String userAnswer,
    required String correctAnswer,
    required String errorType, // e.g., "Calculation", "Concept"
  }) async {
    await firestore.collection('mistake_log').add({
      'question': question,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
      'error_type': errorType,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
