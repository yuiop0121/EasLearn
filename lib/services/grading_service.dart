import 'dart:convert';
import 'package:cross_file/cross_file.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'grading_service.g.dart';

// Needs to be configured with actual API key
const String _apiKey = 'YOUR_API_KEY';

@riverpod
GradingService gradingService(GradingServiceRef ref) {
  return GradingService(
    model: GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey),
  );
}

class GradingService {
  final GenerativeModel model;

  GradingService({required this.model});

  Future<Map<String, dynamic>> gradeSubmission(
    XFile image,
    String markScheme,
  ) async {
    final imageBytes = await image.readAsBytes();

    final prompt = '''
    Mark this student answer based on the mark scheme.
    Mark Scheme: $markScheme
    
    Return a JSON containing:
    - score: (number)
    - missing_keywords: (list of strings)
    - feedback: (string)
    ''';

    final content = [
      Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
    ];

    try {
      final response = await model.generateContent(content);
      final responseText = response.text;

      if (responseText == null) {
        throw Exception("Empty response from AI");
      }

      // Basic cleanup to find JSON if markdown block is used
      String jsonString = responseText;
      if (responseText.contains('```json')) {
        jsonString = responseText.split('```json')[1].split('```')[0];
      } else if (responseText.contains('```')) {
        jsonString = responseText.split('```')[1].split('```')[0];
      }

      return json.decode(jsonString);
    } catch (e) {
      return {
        'score': 0,
        'missing_keywords': [],
        'feedback': "Error grading: $e",
      };
    }
  }
}
