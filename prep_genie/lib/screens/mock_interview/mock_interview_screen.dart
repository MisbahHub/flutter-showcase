import 'package:flutter/material.dart';

class MockInterviewScreen extends StatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  int currentQuestionIndex = 0;
  final TextEditingController _responseController = TextEditingController();

  final List<String> mockQuestions = [
    "Tell me about a time when you faced a difficult technical challenge and how you solved it?",
    "What are your long-term career goals as a Software Engineer?",
    "How do you handle tight deadlines or high-pressure situations in a team?",
    "Why do you want to join PrepGenie as an AI interview specialist?",
  ];

  void _showComingSoonMessage() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.lock_clock, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              "Voice Input Feature Coming Soon!",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.purpleAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E21),

        appBar: AppBar(
          backgroundColor: const Color(0xFF131937),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "AI Mock Session",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  // ConstrainedBox ensure karta hai ke layout full height le jab keyboard na ho
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48, // Padding adjust karne ke liye
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Section: Question Display
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.purpleAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.purpleAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Question ${currentQuestionIndex + 1} of ${mockQuestions.length}",
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              "\"${mockQuestions[currentQuestionIndex]}\"",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, height: 1.5),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30), // Keyboard space padding

                        // Middle Section: Actual Working Text Input Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Type your response:",
                              style: TextStyle(color: Colors.purpleAccent, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _responseController,
                              maxLines: 3,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Enter your answer here...",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                fillColor: const Color(0xFF131937),
                                filled: true,
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(bottom: 35),
                                  child: IconButton(
                                    icon: const Icon(Icons.mic, color: Colors.purpleAccent, size: 26),
                                    onPressed: _showComingSoonMessage,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.purpleAccent, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.purpleAccent, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Bottom Section: Navigation Buttons
                        Column(
                          children: [
                            if (currentQuestionIndex < mockQuestions.length - 1)
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      currentQuestionIndex++;
                                      _responseController.clear();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purpleAccent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text("Next Question", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            const SizedBox(height: 15),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  "End Interview",
                                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}