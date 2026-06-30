import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internify/screens/login/login_screen.dart';
import 'package:internify/screens/admindashboard/interns_list.dart';
import 'package:internify/screens/admindashboard/certificate_requests_screen.dart';
import 'package:internify/screens/admindashboard/task_submissions_screen.dart';
import 'package:internify/screens/admindashboard/broadcast_history_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<String> _publishedTasks = [];
  List<String> _liveFilteredTasks = [];
  List<String> _internNames = ["All Active Interns"];

  final _taskTitleController = TextEditingController();
  final _taskDeadlineController = TextEditingController();
  final _taskFormKey = GlobalKey<FormState>();

  int _totalInternsCount = 0;
  int _pendingRequestsCount = 0;
  String _selectedTargetIntern = "All Active Interns";
  int _pendingSubmissionsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRealWorldDatabase();
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDeadlineController.dispose();
    super.dispose();
  }

  Future<void> _loadRealWorldDatabase() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> internsRawList = prefs.getStringList('registered_interns_list') ?? [];
    List<String> savedTasks = prefs.getStringList('global_assigned_tasks') ?? [];

    int submissionPending = 0;
    List<String> activeLiveTasks = [];

    for (String taskRaw in savedTasks) {
      final parts = taskRaw.split(" | ");
      if (parts.length < 2) continue;
      String taskId = parts[0].trim();
      String assignedToName = parts.length > 2 ? parts[2].replaceAll("Assigned to: ", "").trim() : "All Active Interns";

      bool isFullyApproved = true;
      bool hasCheckedAnyIntern = false;

      for (String internRaw in internsRawList) {
        Map<String, dynamic> intern = jsonDecode(internRaw);
        String studentEmail = intern['email'] ?? "";
        String studentName = intern['name'] ?? "";

        if (assignedToName == "All Active Interns" || assignedToName.toLowerCase() == studentName.toLowerCase()) {
          hasCheckedAnyIntern = true;
          String statusKey = "status_${taskId}_$studentEmail";
          String currentStatus = prefs.getString(statusKey) ?? "Incomplete";

          if (currentStatus == "Pending") {
            submissionPending++;
          }
          if (currentStatus != "Approved") {
            isFullyApproved = false;
          }
        }
      }

      if (hasCheckedAnyIntern && !isFullyApproved) {
        activeLiveTasks.add(taskRaw);
      } else if (!hasCheckedAnyIntern) {
        activeLiveTasks.add(taskRaw);
      }
    }

    int requestsCount = 0;
    List<String> parsedNames = ["All Active Interns"];
    for (String rawJson in internsRawList) {
      Map<String, dynamic> intern = jsonDecode(rawJson);
      if (intern['name'] != null) {
        parsedNames.add(intern['name']);
      }

      if (intern['has_requested_certificate'] == true && intern['certificate_status'] != 'Approved') {
        requestsCount++;
      }
    }

    setState(() {
      _publishedTasks = savedTasks;
      _liveFilteredTasks = activeLiveTasks;
      _totalInternsCount = internsRawList.length;
      _pendingRequestsCount = requestsCount;
      _pendingSubmissionsCount = submissionPending;
      _internNames = parsedNames;
    });
  }

  Future<void> _publishTaskToStudent() async {
    if (!_taskFormKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();

    String deadlineText = _taskDeadlineController.text.trim();
    String taskId = "task_${DateTime.now().millisecondsSinceEpoch}";

    String taskPayload = "$taskId | ${_taskTitleController.text.trim()} | Assigned to: $_selectedTargetIntern | Due: $deadlineText";

    _publishedTasks.add(taskPayload);
    await prefs.setStringList('global_assigned_tasks', _publishedTasks);

    List<String> internsRawList = prefs.getStringList('registered_interns_list') ?? [];

    for (String rawJson in internsRawList) {
      Map<String, dynamic> intern = jsonDecode(rawJson);
      String studentEmail = intern['email'] ?? "";
      String studentName = intern['name'] ?? "";

      if (_selectedTargetIntern == "All Active Interns" || _selectedTargetIntern == studentName) {
        String unreadKey = "unread_alerts_$studentEmail";
        int currentUnread = prefs.getInt(unreadKey) ?? 0;
        await prefs.setInt(unreadKey, currentUnread + 1);

        String notifyKey = "notifications_$studentEmail";
        List<String> currentNotifications = prefs.getStringList(notifyKey) ?? [];

        Map<String, dynamic> newTaskNotification = {
          "title": "New Task Available",
          "desc": "Your new assignment '${_taskTitleController.text.trim()}' is now available in your workspace.",
          "type": "task_status",
          "status": "Incomplete",
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString()
        };

        currentNotifications.insert(0, jsonEncode(newTaskNotification));
        await prefs.setStringList(notifyKey, currentNotifications);
      }
    }

    setState(() {
      _taskTitleController.clear();
      _taskDeadlineController.clear();
      _selectedTargetIntern = "All Active Interns";
    });

    if (mounted) Navigator.pop(context);
    _loadRealWorldDatabase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task published successfully. Notifications have been sent.', style: GoogleFonts.poppins())),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Sign Out", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.redAccent)),
          content: Text("Are you sure you want to sign out of your account?", style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600))),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: Text("OK", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  void _showTaskDetailsDialog(String title, String assignedTo, String deadline) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Task Details", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: const Color(0xFF0A58CA))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Assigned To:", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(assignedTo, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text("Due Date:", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(deadline, style: GoogleFonts.poppins(fontSize: 14, color: Colors.orange, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text("Task Overview:", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(title, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF0A58CA))))],
        );
      },
    );
  }

  void _showAssignTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
              child: Form(
                key: _taskFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create New Task', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0A58CA))),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      value: _selectedTargetIntern,
                      decoration: InputDecoration(
                        labelText: 'Select Target Interns',
                        labelStyle: GoogleFonts.poppins(fontSize: 13),
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF0A58CA)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _internNames.map((String name) {
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name, style: GoogleFonts.poppins(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setModalState(() { _selectedTargetIntern = newValue!; });
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _taskDeadlineController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Due Date (e.g. June 30, July 05)',
                        labelStyle: GoogleFonts.poppins(fontSize: 13),
                        prefixIcon: const Icon(Icons.calendar_month_outlined, color: Color(0xFF0A58CA)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please specify a target deadline date' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _taskTitleController,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(labelText: 'Task Details', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please write some details' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _publishTaskToStudent,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A58CA), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('Publish Assignment', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAssignTaskBottomSheet,
        backgroundColor: const Color(0xFF0A58CA),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_rounded),
        label: Text('Create Task', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 35),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF0A58CA), Color(0xFF4EC5B6)]),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Control Center', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                      const SizedBox(height: 2),
                      Text('HR & Admin Dashboard', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  InkWell(
                    onTap: () => _showLogoutDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const InternsListScreen()));
                        _loadRealWorldDatabase();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF0A58CA).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.people_outline_rounded, color: Color(0xFF0A58CA), size: 24)),
                                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26, size: 14),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('$_totalInternsCount', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                            Text('Total Interns', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BroadcastHistoryScreen()),
                        );
                        _loadRealWorldDatabase();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF4EC5B6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.assignment_outlined, color: Color(0xFF4EC5B6), size: 24)),
                                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26, size: 14),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('${_publishedTasks.length}', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                            Text('Published Tasks', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: InkWell(
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskSubmissionsScreen()));
                  _loadRealWorldDatabase();
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
                      border: Border.all(color: const Color(0xFF0A58CA).withOpacity(0.15))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFF0A58CA).withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF0A58CA), size: 24)
                          ),
                          const SizedBox(width: 14),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Submission Reviews ($_pendingSubmissionsCount)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                                const SizedBox(height: 2),
                                Text("Review and approve GitHub submissions", style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                              ]
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26, size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: InkWell(
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const CertificateRequestsScreen()));
                  _loadRealWorldDatabase();
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)], border: Border.all(color: Colors.amber.withOpacity(0.15))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 24)),
                          const SizedBox(width: 14),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text("Certificate Approvals ($_pendingRequestsCount)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                            const SizedBox(height: 2),
                            Text("Review and approve certificate requests", style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                          ]),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26, size: 16),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text('Active Tasks (${_liveFilteredTasks.length})', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _liveFilteredTasks.isEmpty
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                child: Column(
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, color: Colors.grey.shade300, size: 45),
                    const SizedBox(height: 12),
                    Text("No Active Tasks", style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text("All assigned tasks have been reviewed and completed.", style: GoogleFonts.poppins(color: Colors.black26, fontSize: 11), textAlign: TextAlign.center),
                  ],
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: _liveFilteredTasks.length,
                itemBuilder: (context, index) {
                  final rawContent = _liveFilteredTasks[index];
                  final parts = rawContent.split(" | ");

                  if (parts.length < 2) return const SizedBox();
                  final title = parts[1];
                  final assigned = parts.length > 2 ? parts[2] : "Assigned to: All Interns";
                  final deadline = parts.length > 3 ? parts[3] : "Due: Upcoming";

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      onTap: () => _showTaskDetailsDialog(title, assigned, deadline),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(backgroundColor: const Color(0xFF0A58CA).withOpacity(0.1), child: const Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF0A58CA), size: 20)),
                      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text("$assigned\n$deadline", style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: Colors.grey.shade400, size: 22),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          setState(() {
                            _publishedTasks.remove(rawContent);
                            _liveFilteredTasks.removeAt(index);
                          });
                          await prefs.setStringList('global_assigned_tasks', _publishedTasks);
                          _loadRealWorldDatabase();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}