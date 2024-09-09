import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb and defaultTargetPlatform
import 'theory_data.dart';

enum QuizMode { hiddenExplanation, training, hiddenTerm }

/// Theory tab for taekwondo theory training and quizzing.
///
/// Allows users to select belt levels and start different types of quizzes
/// or training modes to practice taekwondo terminology and theory.
/// Provides options to train with hidden explanations, hidden terms, or
/// both terms and explanations visible.
class TheoryTab extends StatefulWidget {
  const TheoryTab({super.key});

  @override
  TheoryTabState createState() => TheoryTabState();
}

class TheoryTabState extends State<TheoryTab> {
  List<Belt> selectedBelts = [];
  List<MapEntry<String, String>> terms = [];
  Map<int, bool> beltSelection = {};
  bool isQuizStarted = false;
  List<bool> showExplanationList = [];
  PageController pageController = PageController();
  QuizMode? quizMode;

  @override
  void initState() {
    super.initState();
    beltSelection = {for (var belt in allBelts) belt.level: false};
  }

  @override
  Widget build(BuildContext context) {
    if (!isQuizStarted) {
      // Belt selection screen
      return Scaffold(
        // Removed AppBar as per your request
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                      'Vælg bælter',
                      textAlign: TextAlign.center,
                      style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _selectAllBelts,
                        child: const Text('Vælg Alle'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _deselectAllBelts,
                        child: const Text('Fravælg Alle'),
                      ),
                    ],
                  ),
                  ...allBelts.map((belt) {
                    return CheckboxListTile(
                      title: Text(belt.name),
                      value: beltSelection[belt.level],
                      onChanged: (bool? value) {
                        setState(() {
                          beltSelection[belt.level] = value ?? false;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10.0,
                children: [
                  ElevatedButton(
                    onPressed: _startQuiz,
                    child: const Text('Træn skjult forklaring'),
                  ),
                  ElevatedButton(
                    onPressed: _startTraining,
                    child: const Text('Træn'),
                  ),
                  ElevatedButton(
                    onPressed: _startReverseQuiz,
                    child: const Text('Træn skjult udtryk'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Quiz interface with swipe navigation
      return Scaffold(
        // No AppBar to remove the header
        body: _buildQuiz(),
      );
    }
  }

  Widget _buildQuiz() {
    if (terms.isEmpty) {
      return const Center(
        child: Text('Ingen spørgsmål at vise.'),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          itemCount: terms.length,
          itemBuilder: (context, index) {
            var term = terms[index];
            bool showAnswer = showExplanationList[index];

            String questionText;
            String answerText;
            String? buttonText;

            if (quizMode == QuizMode.hiddenExplanation) {
              // Question is term.key, answer is term.value
              questionText = term.key;
              answerText = term.value;
              buttonText = 'Vis forklaring';
            } else if (quizMode == QuizMode.hiddenTerm) {
              // Question is term.value, answer is term.key
              questionText = term.value;
              answerText = term.key;
              buttonText = 'Vis udtryk';
            } else {
              // Training mode, show both
              questionText = term.key;
              answerText = term.value;
              showAnswer = true; // Always show answer
              buttonText = null;
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Spørgsmål ${index + 1} af ${terms.length}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    questionText,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (!showAnswer && buttonText != null)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showExplanationList[index] = true;
                        });
                      },
                      child: Text(buttonText),
                    )
                  else if (showAnswer)
                    Text(
                      answerText,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
          },
        ),
        // Navigation buttons for desktop browsers
        if (kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.linux))
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                iconSize: 40,
                icon: const Icon(Icons.arrow_left),
                onPressed: _previousPage,
              ),
            ),
          ),
        if (kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.linux))
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                iconSize: 40,
                icon: const Icon(Icons.arrow_right),
                onPressed: _nextPage,
              ),
            ),
          ),
      ],
    );
  }

  void _previousPage() {
    if (pageController.hasClients) {
      pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _nextPage() {
    if (pageController.hasClients) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _selectAllBelts() {
    setState(() {
      for (var belt in allBelts) {
        beltSelection[belt.level] = true;
      }
    });
  }

  void _deselectAllBelts() {
    setState(() {
      for (var belt in allBelts) {
        beltSelection[belt.level] = false;
      }
    });
  }

  void _startQuiz() {
    _prepareQuiz(QuizMode.hiddenExplanation);
  }

  void _startTraining() {
    _prepareQuiz(QuizMode.training);
  }

  void _startReverseQuiz() {
    _prepareQuiz(QuizMode.hiddenTerm);
  }

  void _prepareQuiz(QuizMode mode) {
    selectedBelts = allBelts
        .where((belt) => beltSelection[belt.level] == true)
        .toList();

    if (selectedBelts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vælg mindst ét bælte for at starte quizzen')),
      );
      return;
    }

    terms = [];
    for (var belt in selectedBelts) {
      for (var category in belt.categories.values) {
        terms.addAll(category.entries);
      }
    }

    terms.shuffle();

    // Initialize the list to track which explanations are shown
    showExplanationList = List<bool>.filled(terms.length, false);

    setState(() {
      isQuizStarted = true;
      quizMode = mode;
    });
  }
}
