import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Future<List<Map<String, dynamic>>> _getFreshNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> tempNotifications = [];
    String? email = prefs.getString('student_email');

    if (email != null) {
      String notifyKey = "notifications_$email";
      List<String> rawJsonList = prefs.getStringList(notifyKey) ?? [];

      for (String rawJson in rawJsonList) {
        Map<String, dynamic> data = jsonDecode(rawJson);

        IconData itemIcon = Icons.notifications_active_rounded;
        Color itemColor = const Color(0xFF0A58CA);

        if (data['type'] == 'task_status') {
          if (data['status'] == 'Approved') {
            itemIcon = Icons.check_circle_rounded;
            itemColor = Colors.green;
          } else if (data['status'] == 'Rejected') {
            itemIcon = Icons.cancel_rounded;
            itemColor = Colors.redAccent;
          }
        }
        else if (data['type'] == 'cert_status') {
          if (data['status'] == 'Approved') {
            itemIcon = Icons.verified_user_rounded;
            itemColor = Colors.teal;
          } else if (data['status'] == 'Pending') {
            itemIcon = Icons.workspace_premium_rounded;
            itemColor = Colors.orange;
          }
        }

        tempNotifications.add({
          "title": data['title'] ?? "Notification",
          "desc": data['desc'] ?? "",
          "icon": itemIcon,
          "color": itemColor,
        });
      }

      await prefs.setInt("unread_alerts_$email", 0);
    }

    tempNotifications.add({
      "title": "Welcome to Internify",
      "desc": "Your internship workspace is ready. Explore tasks, submissions, and certifications.",
      "icon": Icons.celebration_rounded,
      "color": const Color(0xFF0A58CA),
    });

    return tempNotifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Notifications",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getFreshNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF0A58CA)));
                  }

                  final listData = snapshot.data ?? [];

                  if (listData.isEmpty) {
                    return Center(child: Text("You're all caught up.", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    color: const Color(0xFF0A58CA),
                    child: ListView.builder(
                      itemCount: listData.length,
                      itemBuilder: (context, index) {
                        final item = listData[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: item['color'].withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(item['icon'], color: item['color'], size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                    const SizedBox(height: 4),
                                    Text(item['desc'], style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}