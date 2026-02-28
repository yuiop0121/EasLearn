import 'package:flutter/material.dart';

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

  // Data parsed from 15_Physics_MCQs.md
  final List<Map<String, dynamic>> questions = [
    {
      "topic": "Force and Motion II",
      "question":
          "What is the formula to calculate the magnitude of the resultant (\$F\$) of two perpendicular forces, \$F_x\$ and \$F_y\$?",
      "options": {
        "A": "F = Fx + Fy",
        "B": "F = sqrt(Fx^2 + Fy^2)",
        "C": "F = Fx cos(theta)",
        "D": "F = Fy sin(theta)"
      },
      "answer": "B"
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
      "answer": "B"
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
      "answer": "C"
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
      "answer": "D"
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
      "answer": "B"
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
      "answer": "A"
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
      "answer": "C"
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
      "answer": "B"
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
      "answer": "C"
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
      "answer": "D"
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
      "answer": "A"
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
      "answer": "B"
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
      "answer": "C"
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
      "answer": "C"
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
      "answer": "C"
    }
  ];

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        isAnswered = false;
        selectedAnswer = null;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222938),
        title: const Text("Quiz Result", style: TextStyle(color: Colors.white)),
        content: Text("You scored $score out of ${questions.length}",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to Bank
            },
            child: const Text("Back to Bank"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1522),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Physics - ${q['topic']}",
            style: const TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress tracker
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              backgroundColor: Colors.white10,
              color: const Color(0xFFFFCA28),
            ),
            const SizedBox(height: 40),
            // Question text
            Text(
              "Q${currentIndex + 1}. ${q['question']}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // Option Buttons
            ...q['options'].entries.map((entry) {
              bool isCorrect = isAnswered && entry.key == q['answer'];
              bool isWrong = isAnswered &&
                  selectedAnswer == entry.key &&
                  entry.key != q['answer'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    if (isAnswered) return;
                    setState(() {
                      selectedAnswer = entry.key;
                      isAnswered = true;
                      if (selectedAnswer == q['answer']) score++;
                    });
                    // Auto transition after 1 second
                    Future.delayed(
                        const Duration(milliseconds: 1000), _nextQuestion);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.withOpacity(0.2)
                          : (isWrong
                              ? Colors.red.withOpacity(0.2)
                              : const Color(0xFF222938)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isCorrect
                              ? Colors.green
                              : (isWrong ? Colors.red : Colors.white10)),
                    ),
                    child: Row(
                      children: [
                        Text("${entry.key})",
                            style: TextStyle(
                                color: isCorrect || isWrong
                                    ? Colors.white
                                    : Colors.white54,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: Text(entry.value,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 16))),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
