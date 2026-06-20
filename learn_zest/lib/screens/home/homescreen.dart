import 'package:flutter/material.dart';
import 'package:learn_zest/screens/course/course_detail.dart';
import 'package:learn_zest/screens/profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final String email;
  const HomeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> courses = [
      {"name": "Flutter Development", "icon": Icons.phone_android},
      {"name": "UI/UX Design", "icon": Icons.design_services},
      {"name": "Web Development", "icon": Icons.web},
      {"name": "Java Development", "icon": Icons.code},
      {"name": "C++ Development", "icon": Icons.computer},
      {"name": "Graphic Designing", "icon": Icons.brush},
      {"name": "Digital Marketing", "icon": Icons.campaign},
      {"name": "Project Management", "icon": Icons.work},
      {"name": "AI/ML Learning", "icon": Icons.memory},
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade600,
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                "LearnZest",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),


        actions: [
          IconButton(
            icon:
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Colors.blue,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(email:email),
                ),
              );
            },
          )
        ],
      ),

      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: ListTile(
                contentPadding: const EdgeInsets.all(12),

                // ✅ FIXED ICON (important)
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(
                    courses[index]["icon"] as IconData,
                    color: Colors.blue,
                  ),
                ),

                title: Text(
                  courses[index]["name"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                subtitle: const Text("Tap to view details"),

                trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailScreen(
                        courseName: courses[index]["name"],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}


