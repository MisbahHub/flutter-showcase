import 'package:flutter/material.dart';

class QuestionsScreen extends StatefulWidget {
  final String categoryName;
  const QuestionsScreen({super.key, required this.categoryName});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {

  final Map<String, List<Map<String, String>>> categoryWiseQuestions = {
    "Technical": [
      {
        "q": "What is the difference between Stateless and Stateful widgets in Flutter?",
        "a": "Stateless widgets are immutable and don't change their state at runtime, while Stateful widgets maintain a dynamic state that triggers a redraw via setState()."
      },
      {
        "q": "Explain multithreading and how async/await works in Dart?",
        "a": "Dart is single-threaded but handles asynchronous tasks using an Event Loop. async/await allows writing non-blocking asynchronous code that looks synchronous."
      },
      {
        "q": "What is Object-Oriented Programming (OOP) and its main pillars?",
        "a": "OOP is a programming paradigm based on 'objects'. Its four pillars are Encapsulation, Inheritance, Polymorphism, and Abstraction."
      },
    ],
    "HR / Behavioral": [
      {
        "q": "Tell me about yourself?",
        "a": "Focus on your professional journey, your skills in mobile development, and key achievements relevant to this role."
      },
      {
        "q": "Why should we hire you over other candidates?",
        "a": "Highlight your technical grip on frameworks like Flutter, your active project experience, and your passion for learning AI."
      },
      {
        "q": "How do you handle conflict or tight deadlines within a team?",
        "a": "Talk about clear communication, dividing tasks effectively, and focusing on problem-solving rather than blaming others."
      },
    ],
    "Marketing": [
      {
        "q": "How would you design a digital marketing strategy for a new AI product?",
        "a": "Focus on identifying the target audience, creating minimalist/moody visual content on social media, and utilizing content marketing to showcase the AI's value."
      },
      {
        "q": "What metrics do you look at to evaluate social media engagement?",
        "a": "Look at reach, conversion rates, click-through rates (CTR), and audience retention (especially on short-form content/reels)."
      },
    ],
    "Finance": [
      {
        "q": "What is the importance of a cash flow statement for a tech startup?",
        "a": "It tracks how much money is coming in and going out, helping the company maintain sufficient liquidity to manage daily operations and scaling costs."
      },
      {
        "q": "How do you define Return on Investment (ROI)?",
        "a": "ROI measures the gain or loss generated on an investment relative to the amount of money invested. It is calculated as net profit divided by total cost."
      },
    ]
  };

  @override
  Widget build(BuildContext context) {

    final currentQuestions = categoryWiseQuestions[widget.categoryName] ?? categoryWiseQuestions["HR / Behavioral"]!;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131937),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${widget.categoryName} Questions",
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: currentQuestions.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF131937),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Q${index + 1}: ",
                      style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        currentQuestions[index]['q']!,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Icon(Icons.bookmark_border, color: Colors.white24, size: 22),
                  ],
                ),
                const SizedBox(height: 12),

                // Answer Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("AI Suggested Hint:", style: TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        currentQuestions[index]['a']!,
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}