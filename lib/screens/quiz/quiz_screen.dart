import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../models/quiz.dart';
import '../../core/services/mock_data.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _questions = MockDataService.getAllQuestions();
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return; // Prevent changing answer

    setState(() {
      _selectedOptionIndex = selectedIndex;
      _isAnswered = true;
      if (selectedIndex == _questions[_currentIndex].correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isPass = _score >= (_questions.length / 2);
        return AlertDialog(
          title: Text(isPass ? "🎉 Great Job!" : "📚 Keep Learning"),
          content: Text("You scored $_score out of ${_questions.length}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close Dialog
                Navigator.pop(context); // Go Back Home
              },
              child: const Text("Finish"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close Dialog
                setState(() {
                  // Reset Quiz
                  _currentIndex = 0;
                  _score = 0;
                  _selectedOptionIndex = null;
                  _isAnswered = false;
                });
              },
              child: const Text("Retry"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    
    if (_questions.isEmpty) return const Scaffold(body: Center(child: Text("No questions available")));

    final question = _questions[_currentIndex];
    final options = question.getOptions(prefs.language);

    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? "اختبار المعلومات" : "Museum Quiz")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[200],
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            
            // Question Counter
            Text(
              "Question ${_currentIndex + 1}/${_questions.length}",
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Question Text
            Text(
              question.getQuestion(prefs.language),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Options List
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final isCorrect = index == question.correctAnswerIndex;
                  final isSelected = index == _selectedOptionIndex;
                  
                  // Determine Color
                  Color bgColor = Colors.white;
                  Color borderColor = Colors.grey.shade300;
                  
                  if (_isAnswered) {
                    if (isCorrect) {
                      bgColor = Colors.green.shade100;
                      borderColor = Colors.green;
                    } else if (isSelected && !isCorrect) {
                      bgColor = Colors.red.shade100;
                      borderColor = Colors.red;
                    }
                  }

                  return InkWell(
                    onTap: () => _checkAnswer(index),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${String.fromCharCode(65 + index)}.", // A, B, C...
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(options[index], style: const TextStyle(fontSize: 16))),
                          if (_isAnswered && isCorrect)
                            const Icon(Icons.check_circle, color: Colors.green),
                          if (_isAnswered && isSelected && !isCorrect)
                            const Icon(Icons.cancel, color: Colors.red),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Next Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isAnswered ? _nextQuestion : null,
                child: Text(
                  _currentIndex == _questions.length - 1 
                    ? (isArabic ? "إنهاء" : "Finish") 
                    : (isArabic ? "التالي" : "Next Question")
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}