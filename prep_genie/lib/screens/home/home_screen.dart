import 'package:flutter/material.dart';
import 'package:prep_genie/screens/mock_interview/mock_interview_screen.dart';
import 'package:prep_genie/screens/profile/profile_screen.dart';
import 'package:prep_genie/screens/progress_tracker/progress_tracker_screen.dart';
import 'package:prep_genie/screens/questions/questions_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
  const HomeScreen({super.key, required this.userEmail});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final TextEditingController searchController = TextEditingController();
  final List<Map<String, dynamic>> allCategories = [
    {"title": "Technical", "icon": Icons.code_rounded, "color": Colors.blueAccent},
    {"title": "HR / Behavioral", "icon": Icons.groups_rounded, "color": Colors.greenAccent},
    {"title": "Marketing", "icon": Icons.trending_up_rounded, "color": Colors.orangeAccent},
    {"title": "Finance", "icon": Icons.account_balance_wallet_rounded, "color": Colors.pinkAccent},
  ];
  List<Map<String, dynamic>> foundCategories = [];

  @override
  void initState(){
    super.initState();
    foundCategories= allCategories;
  }

   void runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
   if (enteredKeyword.isEmpty) {
   results =  allCategories;
   } else {
   results = allCategories
  .where((category) => category["title"]
  .toString()
  .toLowerCase()
  .contains(enteredKeyword.toLowerCase()))
  .toList();
 }
    setState(() {
      foundCategories = results;
    });
   }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [


                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hello, Scholar!",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Ready to ace your interview today?",
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(userEmail: widget.userEmail),
                            ),
                          );
                        },
                        child: const CircleAvatar(
                          radius: 23,
                          backgroundColor: Colors.purpleAccent,
                          child: Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                      )
                    ],
                  ),
                      const SizedBox(height: 25),


                      TextField(
                        controller: searchController,
                        autofocus: false,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) => runFilter(value),

                        decoration: InputDecoration(
                          hintText: "Search categories (e.g., Technical)...",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Colors.purpleAccent),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                runFilter('');
                              });
                            },
                          )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFF131937),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none
                          ),
                        ),
                      ),

                    const SizedBox(height: 25),


                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.purpleAccent, Colors.deepPurple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                        ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "AI Mock Interview",
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Practice dynamic audio rounds with our smart AI assistant.",
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MockInterviewScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Start", style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),

                      const SizedBox(height: 25),


                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProgressTrackerScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131937),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.analytics_outlined, color: Colors.greenAccent, size: 28),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Your Preparation Score", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 2),
                                    Text("Completed 4 mock sessions this week", style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text("78%", style: TextStyle(color: Colors.purpleAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),


                      const Text(
                        "Interview Categories",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),

                      foundCategories.isEmpty
                          ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded, color: Colors.white.withOpacity(0.3), size: 50),
                            const SizedBox(height: 10),
                            Text(
                              "No Category Found",
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                          : // 🔥 UPDATED GRIDVIEW: Direct itemBuilder ke andar code rakh diya hai
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: foundCategories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.2,
                        ),
                        itemBuilder: (context, index) {
                          // Filtered data variables
                          final String title = foundCategories[index]["title"];
                          final IconData icon = foundCategories[index]["icon"];
                          final Color color = foundCategories[index]["color"];

                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF131937),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  // 🔥 Context local hone ki wajah se navigation makkhan ki tarah chalegi
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuestionsScreen(categoryName: title),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(icon, color: color, size: 26),
                                      ),
                                      Text(
                                        title,
                                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ),
          )
        ),
    );
  }
}