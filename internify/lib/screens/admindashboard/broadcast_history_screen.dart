import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BroadcastHistoryScreen extends StatefulWidget {
  const BroadcastHistoryScreen({super.key});

  @override
  State<BroadcastHistoryScreen> createState() => _BroadcastHistoryScreenState();
}

class _BroadcastHistoryScreenState extends State<BroadcastHistoryScreen> {
  List<String> _allPublishedTasks = [];
  List<String> _internsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoryDatabase();
  }

  Future<void> _loadHistoryDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allPublishedTasks = prefs.getStringList('global_assigned_tasks') ?? [];
      _internsList = prefs.getStringList('registered_interns_list') ?? [];
      _isLoading = false;
    });
  }


  void _showTaskAuditBottomSheet(String taskId, String title, String assignedScope, String deadline) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> submissionLogs = [];

    String targetName = assignedScope.replaceAll("Assigned to: ", "").trim();


    for (String internRaw in _internsList) {
      Map<String, dynamic> intern = jsonDecode(internRaw);
      String sEmail = intern['email'] ?? "";
      String sName = intern['name'] ?? "Unknown Intern";

      if (targetName == "All Active Interns" || targetName.toLowerCase() == sName.toLowerCase()) {
        String status = prefs.getString("status_${taskId}_$sEmail") ?? "Incomplete";
        String gitLink = prefs.getString("link_${taskId}_$sEmail") ?? "No repository submitted yet";

        submissionLogs.add({
          "name": sName,
          "email": sEmail,
          "status": status,
          "link": gitLink,
        });
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF0A58CA).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(deadline, style: GoogleFonts.poppins(color: const Color(0xFF0A58CA), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(assignedScope, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              const Divider(height: 32),
              Text("Submission Overview", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 12),

              if (submissionLogs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text("No interns have been assigned to this task.", style: GoogleFonts.poppins(fontSize: 13, color: Colors.black38)),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: submissionLogs.length,
                    itemBuilder: (context, index) {
                      final log = submissionLogs[index];
                      Color statusColor = log['status'] == 'Approved'
                          ? Colors.green
                          : (log['status'] == 'Pending' ? Colors.orange : Colors.redAccent);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6FA),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(log['name']!, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text(log['status']!, style: GoogleFonts.poppins(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text("GitHub Repository:", style: GoogleFonts.poppins(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold)),
                            SelectableText(
                                log['link']!,
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: log['link']!.contains("github.com") ? const Color(0xFF0A58CA) : Colors.black45,
                                    decoration: log['link']!.contains("github.com") ? TextDecoration.underline : TextDecoration.none
                                )
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(
            "Published Tasks",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)
        ),
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
          : _allPublishedTasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined, color: Colors.grey.shade300, size: 55),
            const SizedBox(height: 12),
            Text("No tasks have been published yet", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
          ],
        ),
      )
          : FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final prefs = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _allPublishedTasks.length,
            itemBuilder: (context, index) {
              final parts = _allPublishedTasks[index].split(" | ");
              if (parts.length < 2) return const SizedBox();

              String taskId = parts[0].trim();
              String title = parts[1].trim();
              String assigned = parts.length > 2 ? parts[2] : "Assigned To: All Active Interns";
              String deadline = parts.length > 3 ? parts[3] : "Due Date: Not Set";
              String targetName = assigned.replaceAll("Assigned to: ", "").trim();

              bool isApproved = true;
              for (String internRaw in _internsList) {
                Map<String, dynamic> intern = jsonDecode(internRaw);
                if (targetName == "All Active Interns" || targetName.toLowerCase() == (intern['name'] ?? "").toString().toLowerCase()) {
                  String currentStatus = prefs.getString("status_${taskId}_${intern['email']}") ?? "Incomplete";
                  if (currentStatus != "Approved") {
                    isApproved = false;
                  }
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.01), blurRadius: 6)],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showTaskAuditBottomSheet(taskId, title, assigned, deadline),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isApproved ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          child: Icon(
                              isApproved ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                              color: isApproved ? Colors.green : Colors.orange,
                              size: 22
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  title,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis
                              ),
                              const SizedBox(height: 2),
                              Text("$assigned • $deadline", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        if (isApproved)
                          const Icon(Icons.done_all_rounded, color: Colors.green, size: 20)
                        else
                          const Icon(Icons.hourglass_bottom_rounded, color: Colors.orange, size: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}