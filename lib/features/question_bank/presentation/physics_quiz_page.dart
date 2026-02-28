import 'package:edupulse_ai/features/grading/presentation/grading_screen.dart';
import 'package:flutter/material.dart';
// IMPORTANT: Ensure this path correctly points to your GradingScreen file
// import 'package:edupulse_ai/screens/grading_screen.dart';

class PhysicsQuizPage extends StatefulWidget {
  const PhysicsQuizPage({super.key});

  @override
  State<PhysicsQuizPage> createState() => _PhysicsQuizPageState();
}

class _PhysicsQuizPageState extends State<PhysicsQuizPage> {
  int currentIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool isAnswered = false;

  // The 15 Physics MCQ Questions
  final List<Map<String, dynamic>> questions = [
    {
      "topic": "Force and Motion II",
      "question":
          "What is the formula to calculate the magnitude of the resultant (F) of two perpendicular forces, Fx and Fy?",
      "options": {
        "A": "F = Fx + Fy",
        "B": "F = sqrt(Fx² + Fy²)",
        "C": "F = Fx cos(θ)",
        "D": "F = Fy sin(θ)"
      },
      "answer": "B",
      "explanation": "Using Pythagoras' Theorem for perpendicular components."
    },
    {
      "topic": "Force and Motion II",
      "question":
          "According to Hooke's Law, what is the relationship between the applied force and the extension of a spring, provided the elastic limit is not exceeded?",
      "options": {
        "A": "Inversely proportional",
        "B": "Directly proportional",
        "C": "Equal",
        "D": "Exponentially proportional"
      },
      "answer": "B",
      "explanation":
          "Hooke's Law states F = kx, where force is directly proportional to extension."
    },
    {
      "topic": "Pressure",
      "question":
          "Which principle states that pressure applied to an enclosed fluid is transmitted uniformly in all directions throughout the fluid?",
      "options": {
        "A": "Archimedes' Principle",
        "B": "Bernoulli's Principle",
        "C": "Pascal's Principle",
        "D": "Hooke's Law"
      },
      "answer": "C",
      "explanation": "Pascal's principle is the basis for hydraulic systems."
    },
    {
      "topic": "Pressure",
      "question":
          "According to Archimedes' Principle, the buoyant force on an object immersed in a fluid is equal to:",
      "options": {
        "A": "The volume of the fluid displaced",
        "B": "The density of the fluid displaced",
        "C": "The mass of the object",
        "D": "The weight of the fluid displaced"
      },
      "answer": "D",
      "explanation":
          "Buoyant force equals the weight of the fluid displaced by the object."
    },
    {
      "topic": "Electricity",
      "question":
          "What is the SI unit for the rate of flow of electric charge?",
      "options": {
        "A": "Volt (V)",
        "B": "Ampere (A)",
        "C": "Joules (J)",
        "D": "Ohm (Ω)"
      },
      "answer": "B",
      "explanation":
          "Current is the rate of flow of charge, measured in Amperes."
    },
    {
      "topic": "Electricity",
      "question": "Which equation correctly represents Ohm's Law?",
      "options": {
        "A": "V = IR",
        "B": "P = VI",
        "C": "E = V + Ir",
        "D": "R = ρl / A"
      },
      "answer": "A",
      "explanation":
          "Ohm's law defines the relationship between Voltage, Current, and Resistance."
    },
    {
      "topic": "Electromagnetism",
      "question":
          "In a step-up transformer, which of the following is true regarding the number of turns in the primary (Np) and secondary (Ns) coils?",
      "options": {
        "A": "Ns < Np",
        "B": "Ns = Np",
        "C": "Ns > Np",
        "D": "There are no secondary coils"
      },
      "answer": "C",
      "explanation":
          "Step-up transformers increase voltage by having more turns in the secondary coil."
    },
    {
      "topic": "Electromagnetism",
      "question":
          "Which rule is used to determine the direction of the force on a current-carrying conductor in a magnetic field?",
      "options": {
        "A": "Fleming's Right-Hand Rule",
        "B": "Fleming's Left-Hand Rule",
        "C": "Faraday's Law",
        "D": "Lenz's Law"
      },
      "answer": "B",
      "explanation":
          "Fleming's Left-Hand Rule is used for the motor effect (force)."
    },
    {
      "topic": "Electronics",
      "question":
          "The release of electrons from the surface of a heated metal is known as:",
      "options": {
        "A": "Rectification",
        "B": "Electromagnetic induction",
        "C": "Thermionic emission",
        "D": "Photoelectric effect"
      },
      "answer": "C",
      "explanation":
          "Thermionic emission occurs when heat provides energy for electrons to escape."
    },
    {
      "topic": "Electronics",
      "question":
          "What is the primary function of a semiconductor diode in forward bias?",
      "options": {
        "A": "To amplify current",
        "B": "To act as a switch",
        "C": "To prevent current flow",
        "D": "To allow current to flow in one direction"
      },
      "answer": "D",
      "explanation": "Diodes act as one-way valves for electric current."
    },
    {
      "topic": "Nuclear Physics",
      "question":
          "Which type of radiation is a helium nucleus and is stopped by a piece of paper?",
      "options": {
        "A": "Alpha (α)",
        "B": "Beta (β)",
        "C": "Gamma (γ)",
        "D": "X-rays"
      },
      "answer": "A",
      "explanation":
          "Alpha particles are relatively large and heavy, giving them low penetrating power."
    },
    {
      "topic": "Nuclear Physics",
      "question":
          "What process involves the splitting of a heavy, unstable nucleus into two lighter nuclei?",
      "options": {
        "A": "Nuclear Fusion",
        "B": "Nuclear Fission",
        "C": "Radioactive Decay",
        "D": "Thermionic Emission"
      },
      "answer": "B",
      "explanation":
          "Fission is the splitting of nuclei, while fusion is the joining of nuclei."
    },
    {
      "topic": "Quantum Physics",
      "question":
          "In quantum physics, light is considered as discrete packets of energy called:",
      "options": {
        "A": "Electrons",
        "B": "Protons",
        "C": "Photons",
        "D": "Neutrons"
      },
      "answer": "C",
      "explanation": "Photons are the basic units or quanta of light."
    },
    {
      "topic": "Quantum Physics",
      "question":
          "The photoelectric effect occurs only if the frequency of incident light is above the metal's:",
      "options": {
        "A": "Natural frequency",
        "B": "Harmonic frequency",
        "C": "Threshold frequency",
        "D": "Resonance frequency"
      },
      "answer": "C",
      "explanation":
          "Threshold frequency is the minimum frequency required to eject electrons."
    },
    {
      "topic": "Quantum Physics",
      "question":
          "According to Einstein's Photoelectric Equation (hf = W + Kmax), what does 'W' represent?",
      "options": {
        "A": "Wave frequency",
        "B": "Weight function",
        "C": "Work function",
        "D": "Wavelength"
      },
      "answer": "C",
      "explanation":
          "Work function is the minimum energy needed to remove an electron from the metal surface."
    }
  ];

  void _handleOptionTap(String key) {
    if (isAnswered) return;
    setState(() {
      selectedAnswer = key;
      isAnswered = true;
      if (selectedAnswer == questions[currentIndex]['answer']) {
        score++;
      }
    });
  }

  void _goToNextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        isAnswered = false;
        selectedAnswer = null;
      });
    } else {
      // Navigate to the result page when questions end
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              QuizResultPage(score: score, total: questions.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentIndex];
    bool isCorrectChoice = selectedAnswer == q['answer'];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1522),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Physics: ${currentIndex + 1}/${questions.length}",
            style: const TextStyle(fontSize: 16, color: Colors.white70)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Expanded and SingleChildScrollView prevent bottom overflow
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / questions.length,
                    backgroundColor: Colors.white10,
                    color: const Color(0xFFFFCA28),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    q['question'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4),
                  ),
                  const SizedBox(height: 30),
                  ...q['options'].entries.map((entry) {
                    bool isThisCorrect = isAnswered && entry.key == q['answer'];
                    bool isThisWrong = isAnswered &&
                        selectedAnswer == entry.key &&
                        entry.key != q['answer'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _handleOptionTap(entry.key),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isThisCorrect
                                ? Colors.green.withOpacity(0.15)
                                : (isThisWrong
                                    ? Colors.red.withOpacity(0.15)
                                    : const Color(0xFF222938)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isThisCorrect
                                  ? Colors.green
                                  : (isThisWrong ? Colors.red : Colors.white10),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text("${entry.key})",
                                  style: TextStyle(
                                      color: isAnswered
                                          ? Colors.white
                                          : Colors.white38,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 15),
                              Expanded(
                                  child: Text(entry.value,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16))),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // Answer Feedback and Explanation
                  if (isAnswered) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isCorrectChoice
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isCorrectChoice
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCorrectChoice ? "Correct! ✨" : "Wrong answer ❌",
                            style: TextStyle(
                                color:
                                    isCorrectChoice ? Colors.green : Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Correct answer: ${q['answer']}, Because ${q['explanation']}",
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),

          // Fixed Next/Result Button pinned to the bottom of the screen
          if (isAnswered)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _goToNextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A8CFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    currentIndex < questions.length - 1
                        ? "Next Question"
                        : "View Results",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. QUIZ RESULT PAGE
// ==========================================
class QuizResultPage extends StatelessWidget {
  final int score;
  final int total;

  const QuizResultPage({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    double percentage = (score / total) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1522),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, size: 100, color: Color(0xFFFFCA28)),
              const SizedBox(height: 20),
              const Text("Quiz Completed!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Score: $score / $total",
                  style: const TextStyle(color: Colors.white70, fontSize: 20)),
              const SizedBox(height: 40),
              Text("${percentage.toStringAsFixed(0)}%",
                  style: const TextStyle(
                      color: Color(0xFFFFCA28),
                      fontSize: 80,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 60),

              // Directs to GradingScreen pushing data onto the navigator stack
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Update the global state immediately before navigating
                    QuizData.updateRecord(score, total);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GradingScreen(score: score, total: total)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A8CFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("View AI Analysis",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
