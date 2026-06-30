import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internify/screens/notifications/notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internify/screens/certificate/certificate_screen.dart';
import 'package:internify/screens/profile&settings/profile&settings_screen.dart';
import 'package:internify/screens/task_detail/task_detail_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  String studentName = "Student";


  List<Map<String, String>> _tasks = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserAndTasks();
  }

  Future<void> _loadUserAndTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('student_email');
    String currentLocalName = prefs.getString('student_name') ?? "Student";

    List<Map<String, String>> assignedTasks = [];

    int currentBadgeCount = 0;
    if (email != null) {
      currentBadgeCount = prefs.getInt("unread_alerts_$email") ?? 0;
    }


    if (email != null && email.contains("demo")) {
      assignedTasks = [
        {'id': 'demo_1', 'title': 'Design Splash Screen', 'date': 'Due: June 28', 'status': 'Approved'},
        {'id': 'demo_2', 'title': 'Form Validation', 'date': 'Due: June 29', 'status': 'Pending'},
        {'id': 'demo_3', 'title': 'Database Integration', 'date': 'Due: July 02', 'status': 'Incomplete'}
      ];
    }
    else {
      List<String> liveAdminTasks = prefs.getStringList('global_assigned_tasks') ?? [];
      for (String rawTask in liveAdminTasks) {
        final parts = rawTask.split(" | ");
        if (parts.length < 2) continue;

        String taskId = parts[0].trim();
        String taskTitle = parts[1].trim();
        String assignedToName = parts.length > 2
            ? parts[2].replaceAll("Assigned to: ", "").trim()
            : "All Active Interns";
        String deadlineDate = parts.length > 3 ? parts[3].trim() : "Due: Upcoming";

        if (assignedToName == "All Active Interns" ||
            assignedToName.toLowerCase() == currentLocalName.toLowerCase()) {

          String statusKey = "status_${taskId}_$email";
          String currentStatus = prefs.getString(statusKey) ?? "Incomplete";

          assignedTasks.add({
            'id': taskId,
            'title': taskTitle,
            'date': deadlineDate,
            'status': currentStatus
          });
        }
      }
    }

    setState(() {
      studentName = currentLocalName;
      _tasks = assignedTasks;
      _unreadCount = currentBadgeCount;
      _isLoading = false;
    });
  }


  void _onTabChanged(int index) async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('student_email');

    if (index == 1 && email != null) {
      await prefs.setInt("unread_alerts_$email", 0);
      setState(() {
        _unreadCount = 0;
      });
    }

    setState(() {
      _currentIndex = index;
    });
  }


  Color statusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Pending":
        return Colors.orange;
      case "Rejected":
        return Colors.redAccent;
      case "Incomplete":
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF0A58CA),
        unselectedItemColor: Colors.grey,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),


          BottomNavigationBarItem(
            icon: Badge(
              label: Text("$_unreadCount"),
              backgroundColor: Colors.redAccent,
              isLabelVisible: _unreadCount > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
            activeIcon: const Icon(Icons.notifications),
            label: "Notifications",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.workspace_premium_outlined), activeIcon: Icon(Icons.workspace_premium), label: "Certificate"),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _homeUI(),
          const NotificationScreen(),
          const CertificateScreen(),
          const ProfileScreen(),
        ],
      ),
    );
  }


  Widget _homeUI() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A58CA)))
        : RefreshIndicator(
      onRefresh: _loadUserAndTasks,
      color: const Color(0xFF0A58CA),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 35),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF0A58CA), Color(0xFF4EC5B6)]),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 34,
                            width: 34,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Padding(
                                padding: const EdgeInsets.all(4.5),
                                child: Image.asset('assets/images/logo1.png', fit: BoxFit.contain),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Internify",
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              InkWell(
                                onTap: () => _onTabChanged(1),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.notifications_none, color: Colors.white),
                                ),
                              ),
                              if (_unreadCount > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                                )
                            ],
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => setState(() => _currentIndex = 3),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: Text(
                                studentName.isNotEmpty ? studentName[0].toUpperCase() : "S",
                                style: const TextStyle(color: Color(0xFF0A58CA), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text("Welcome", style: GoogleFonts.poppins(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(studentName, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _premiumStat("Active Tasks", _tasks.length.toString(), Icons.task),
                  const SizedBox(width: 12),
                  _premiumStat(
                      "Completed tasks",
                      _tasks.where((t) => t['status'] == "Approved").length.toString(),
                      Icons.check_circle_outline_rounded
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text("Recent Assignments", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 10),

            _tasks.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, color: Colors.grey.shade400, size: 48),
                    const SizedBox(height: 12),
                    Text("No Active Tasks", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
                    Text("New assignments will appear here once they are published.", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
              ),
            )
                : Column(
              children: _tasks.map((task) {
                final color = statusColor(task['status']!);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task))
                      ).then((value) {
                        _loadUserAndTasks();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 8, offset: const Offset(0, 2))],
                        border: Border(left: BorderSide(color: color, width: 4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.task, color: color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task['title']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(task['date']!, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(
                                task['status'] == 'Pending' ? 'Review' : task['status']!,
                                style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _premiumStat(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 3))]),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0A58CA)),
            const SizedBox(height: 6),
            Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}