import 'package:flutter/material.dart';

// --- Global State Manager ---
// This acts as a single source of truth for the quiz results across the entire app.
// By using ValueNotifier, the UI will automatically rebuild when these values change.
class QuizData {
  static final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> totalNotifier = ValueNotifier<int>(15);
  static final ValueNotifier<bool> hasRecordNotifier =
      ValueNotifier<bool>(false);

  // Call this method to update the global record after a quiz finishes
  static void updateRecord(int newScore, int newTotal) {
    scoreNotifier.value = newScore;
    totalNotifier.value = newTotal;
    hasRecordNotifier.value = true;
  }
}

class GradingScreen extends StatelessWidget {
  // Optional parameters to prevent GoRouter instantiation errors
  final int? score;
  final int? total;

  const GradingScreen({super.key, this.score, this.total});

  @override
  Widget build(BuildContext context) {
    // If the screen is pushed directly from the QuizResultPage,
    // update the global state immediately after the current frame builds.
    if (score != null && total != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        QuizData.updateRecord(score!, total!);
      });
    }

    // ValueListenableBuilder listens to the global notifiers.
    // Whenever QuizData.updateRecord is called, this entire widget tree rebuilds automatically.
    return ValueListenableBuilder<bool>(
      valueListenable: QuizData.hasRecordNotifier,
      builder: (context, hasRecord, _) {
        return ValueListenableBuilder<int>(
          valueListenable: QuizData.scoreNotifier,
          builder: (context, savedScore, _) {
            return ValueListenableBuilder<int>(
              valueListenable: QuizData.totalNotifier,
              builder: (context, savedTotal, _) {
                // Prioritize incoming data, fallback to saved global data
                int displayScore = score ?? savedScore;
                int displayTotal = total ?? savedTotal;
                bool isRecordAvailable = (score != null) || hasRecord;

                // Calculate accuracy safely
                double accuracy = isRecordAvailable && displayTotal > 0
                    ? (displayScore / displayTotal) * 100
                    : 0;

                return Scaffold(
                  backgroundColor: const Color(0xFF0F1522),
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    // The back button is handled automatically if pushed via Navigator
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                    centerTitle: true,
                    title: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('AI GRADING RESULT',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5)),
                    ),
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Main Score Display Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            children: [
                              const Text('GRADE ANALYSIS',
                                  style: TextStyle(
                                      color: Color(0xFF4A8CFF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                              const SizedBox(height: 8),
                              Text(
                                '${accuracy.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.0),
                              ),
                              const SizedBox(height: 16),
                              const Text('Overall Accuracy Score',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 14)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Insight Chips Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildInsightChip(
                                isRecordAvailable
                                    ? 'Correct: $displayScore/$displayTotal'
                                    : 'No record yet',
                                Icons.analytics,
                                const Color(0xFF4A8CFF)),
                            const SizedBox(width: 12),
                            _buildInsightChip(
                                'Physics', Icons.science, Colors.blueAccent),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Dynamic AI Feedback Box
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.info, color: Color(0xFF4A8CFF)),
                                  SizedBox(width: 12),
                                  Text('AI Feedback',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isRecordAvailable
                                    ? (accuracy >= 80
                                        ? "Excellent work! Your record shows strong mastery of the concepts."
                                        : "You're getting there! Focus on reviewing missed topics to improve.")
                                    : "Start a quiz in the Question Bank to see your AI-graded record here.",
                                style: const TextStyle(
                                    color: Colors.white70,
                                    height: 1.6,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Helper method for generating insight pills
  Widget _buildInsightChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
