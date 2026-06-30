import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskSubmissionsScreen extends StatefulWidget {
  const TaskSubmissionsScreen({super.key});

  @override
  State<TaskSubmissionsScreen> createState() => _TaskSubmissionsScreenState();
}

class _TaskSubmissionsScreenState extends State<TaskSubmissionsScreen> {
  List<Map<String, dynamic>> _pendingSubmissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> internsJsonList = prefs.getStringList('registered_interns_list') ?? [];
    List<String> globalTasks = prefs.getStringList('global_assigned_tasks') ?? [];
    List<Map<String, dynamic>> structuredList = [];

    for (String internRaw in internsJsonList) {
      Map<String, dynamic> intern = jsonDecode(internRaw);
      String studentEmail = intern['email'] ?? "";
      String studentName = intern['name'] ?? "Intern";

      for (String taskRaw in globalTasks) {
        final parts = taskRaw.split(" | ");
        if (parts.length < 2) continue;

        String taskId = parts[0].trim();
        String taskTitle = parts[1].trim();

        String statusKey = "status_${taskId}_$studentEmail";
        String currentStatus = prefs.getString(statusKey) ?? "Incomplete";

        if (currentStatus == "Pending") {
          String gitLinkKey = "link_${taskId}_$studentEmail";
          String submittedLink = prefs.getString(gitLinkKey) ?? "No Link Found";

          structuredList.add({
            'taskId': taskId,
            'taskTitle': taskTitle,
            'studentEmail': studentEmail,
            'studentName': studentName,
            'githubLink': submittedLink,
          });
        }
      }
    }

    setState(() {
      _pendingSubmissions = structuredList;
      _isLoading = false;
    });
  }


  Future<void> _evaluateSubmission(int index, String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final submission = _pendingSubmissions[index];

    String taskId = submission['taskId'];
    String studentEmail = submission['studentEmail'];
    String taskTitle = submission['taskTitle'];

    String statusKey = "status_${taskId}_$studentEmail";
    await prefs.setString(statusKey, newStatus);


    if (newStatus == "Rejected") {
      await prefs.remove("link_${taskId}_$studentEmail");
    }


    String notifyKey = "notifications_$studentEmail";
    List<String> currentNotifications = prefs.getStringList(notifyKey) ?? [];

    Map<String, dynamic> statusNotification = {
      "title": newStatus == "Approved" ? "Submission Approved" : "Submission Rejected",
      "desc": newStatus == "Approved"
          ? "Your submission for '$taskTitle' has been reviewed and approved."
          : "Your submission for '$taskTitle' was not approved. Please review the feedback and resubmit.",
      "type": "task_status",
      "status": newStatus,
      "timestamp": DateTime.now().millisecondsSinceEpoch.toString()
    };

    currentNotifications.insert(0, jsonEncode(statusNotification));
    await prefs.setStringList(notifyKey, currentNotifications);

    _showSnack(
      newStatus == "Approved" ? 'Submission approved successfully' : 'Submission rejected. Notification sent to the intern.',
      newStatus == "Approved" ? Colors.green : Colors.redAccent,
    );

    _loadSubmissions();
  }

  void _showSnack(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text("Submission Reviews", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0A58CA), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A58CA)))
          : _pendingSubmissions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, color: Colors.grey.shade300, size: 55),
            const SizedBox(height: 12),
            Text("No submissions pending review", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _pendingSubmissions.length,
        itemBuilder: (context, index) {
          final node = _pendingSubmissions[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.01), blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(node['studentName'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF0A58CA))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text("Pending Review", style: GoogleFonts.poppins(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text("Assignment:", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(node['taskTitle'], style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Text("GitHub Repository:", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        node['githubLink'],
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.blue, decoration: TextDecoration.underline),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Color(0xFF0A58CA), size: 20),
                      tooltip: "Copy Repository Link",
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: node['githubLink']));
                        _showSnack("Repository link copied.", const Color(0xFF0A58CA));
                      },
                    ),
                  ],
                ),

                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(

                        onPressed: () => _evaluateSubmission(index, "Rejected"),
                        icon: const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
                        label: Text("Reject", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _evaluateSubmission(index, "Approved"),
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: Text("Approve", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}