import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Map<String, String> task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final _linkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String _currentStatus;
  bool _isSubmitting = false;
  String _savedLink = "";

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.task['status'] ?? 'Incomplete';
    _loadSubmittedLink();
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _loadSubmittedLink() async {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('student_email') ?? "";
    String taskId = widget.task['id'] ?? "";

    setState(() {
      _savedLink = prefs.getString("link_${taskId}_$email") ?? "";
      if (_savedLink.isNotEmpty && _currentStatus == 'Pending') {
        _linkController.text = _savedLink;
      }
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Rejected':
        return Colors.redAccent;
      case 'Incomplete':
      default:
        return Colors.blueGrey;
    }
  }

  void _submitTaskWork() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('student_email') ?? "";
    String taskId = widget.task['id'] ?? "";

    await prefs.setString("link_${taskId}_$email", _linkController.text.trim());
    await prefs.setString("status_${taskId}_$email", "Pending");

    String currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await prefs.setString("time_${taskId}_$email", currentTimestamp);

    setState(() {
      _currentStatus = 'Pending';
      widget.task['status'] = 'Pending';
      _isSubmitting = false;
    });

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Submission Sent", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF0A58CA))),
          content: Text("Your submission has been received and is now pending review.", style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: Text("OK", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF0A58CA))),
            )
          ],
        ),
      );
    }
  }


  void _unsubmitTask() async {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('student_email') ?? "";
    String taskId = widget.task['id'] ?? "";

    String savedTimeStr = prefs.getString("time_${taskId}_$email") ?? "0";
    int savedMillis = int.parse(savedTimeStr);

    DateTime submissionTime = DateTime.fromMillisecondsSinceEpoch(savedMillis);
    DateTime currentTime = DateTime.now();

    int minutesDifference = currentTime.difference(submissionTime).inMinutes;

    if (minutesDifference > 60) {
      _showErrorDialog("Submission Locked", "This submission can no longer be withdrawn as it is currently under review.");
      return;
    }

    await prefs.setString("status_${taskId}_$email", "Incomplete");
    await prefs.remove("link_${taskId}_$email");

    setState(() {
      _currentStatus = 'Incomplete';
      widget.task['status'] = 'Incomplete';
      _linkController.clear();
      _savedLink = "";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Submission withdrawn successfully.", style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF0A58CA),
      ),
    );
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: Text(content, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Got It", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF0A58CA))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = getStatusColor(_currentStatus);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0A58CA), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Task Details',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.01), blurRadius: 6)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Submission Status", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(
                          _currentStatus == 'Pending' ? 'Pending Review' : _currentStatus,
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ],
                    ),
                    Icon(
                      _currentStatus == 'Approved'
                          ? Icons.verified_rounded
                          : (_currentStatus == 'Rejected' ? Icons.cancel_rounded : Icons.pending_actions_rounded),
                      color: statusColor,
                      size: 28,
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text("Task Details", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task['title']!,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF0A58CA), fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 13, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text(widget.task['date']!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (_currentStatus == 'Incomplete' || _currentStatus == 'Rejected') ...[
                Text(
                    _currentStatus == 'Rejected' ? "Submission Requires Revision" : "Submit Assignment",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: _currentStatus == 'Rejected' ? Colors.redAccent : Colors.black87)
                ),
                const SizedBox(height: 10),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _linkController,
                        keyboardType: TextInputType.url,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: "GitHub Repository URL",
                          labelStyle: GoogleFonts.poppins(fontSize: 13),
                          prefixIcon: const Icon(Icons.link_rounded, color: Color(0xFF0A58CA)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return "Please enter your GitHub repository link.";
                          if (!v.contains("github.com")) return "Enter a valid GitHub repository link";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitTaskWork,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentStatus == 'Rejected' ? Colors.redAccent : const Color(0xFF0A58CA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                              _currentStatus == 'Rejected' ? "Submit Again" : "Submit Repository",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ] else ...[
                Text("Submission Details", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _currentStatus == 'Approved' ? Colors.green.withOpacity(0.06) : Colors.orange.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_currentStatus == 'Approved' ? Icons.check_circle_outline_rounded : Icons.hourglass_empty_rounded, color: statusColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _currentStatus == 'Approved' ? "Submission Approved" : "Pending Review",
                            style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      if (_savedLink.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text("GitHub Repository:", style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.bold)),
                        Text(_savedLink, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, decoration: TextDecoration.underline)),
                      ],

                      if (_currentStatus == 'Pending') ...[
                        const Divider(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _unsubmitTask,
                            icon: const Icon(Icons.undo_rounded, color: Colors.redAccent, size: 16),
                            label: Text("Withdraw Submission", style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "You can withdraw your submission within 1 hour.",
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}