import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CertificateRequestsScreen extends StatefulWidget {
  const CertificateRequestsScreen({super.key});

  @override
  State<CertificateRequestsScreen> createState() => _CertificateRequestsScreenState();
}

class _CertificateRequestsScreenState extends State<CertificateRequestsScreen> {
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }


  Future<void> _loadRequests() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> internsRawList = prefs.getStringList('registered_interns_list') ?? [];
    List<Map<String, dynamic>> tempRequests = [];

    for (String rawJson in internsRawList) {
      Map<String, dynamic> intern = jsonDecode(rawJson);

      if (intern['has_requested_certificate'] == true && intern['certificate_status'] != 'Approved') {
        tempRequests.add(intern);
      }
    }

    setState(() {
      _pendingRequests = tempRequests;
      _isLoading = false;
    });
  }

  Future<void> _approveStudentCertificate(String studentEmail) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> internsRawList = prefs.getStringList('registered_interns_list') ?? [];
    List<String> updatedList = [];

    for (String rawJson in internsRawList) {
      Map<String, dynamic> intern = jsonDecode(rawJson);
      if (intern['email'] == studentEmail) {
        intern['certificate_status'] = "Approved";
        intern['has_requested_certificate'] = false;
      }
      updatedList.add(jsonEncode(intern));
    }
    await prefs.setStringList('registered_interns_list', updatedList);


    String notifyKey = "notifications_$studentEmail";
    List<String> currentNotifications = prefs.getStringList(notifyKey) ?? [];

    Map<String, dynamic> approvedCertNotification = {
      "title": "Certificate Approved",
      "desc": "Your internship certificate has been approved and is now available for download.",
      "type": "cert_status",
      "status": "Approved",
      "timestamp": DateTime.now().millisecondsSinceEpoch.toString()
    };

    currentNotifications.insert(0, jsonEncode(approvedCertNotification));
    await prefs.setStringList(notifyKey, currentNotifications);

    String unreadKey = "unread_alerts_$studentEmail";
    int currentUnread = prefs.getInt(unreadKey) ?? 0;
    await prefs.setInt(unreadKey, currentUnread + 1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Certificate approved successfully. Notification sent.", style: GoogleFonts.poppins())),
    );

    _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(
          "Certificate Requests",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0A58CA), size: 18),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A58CA)))
          : _pendingRequests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium_outlined, color: Colors.grey.shade300, size: 55),
            const SizedBox(height: 12),
            Text("No certificate requests pending review", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final intern = _pendingRequests[index];
          String name = intern['name'] ?? "Unknown Intern";
          String email = intern['email'] ?? "";
          String domain = intern['domain'] ?? "Intern";

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.01), blurRadius: 6)],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.amber.withOpacity(0.1),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 2),
                      Text("$domain • $email", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _approveStudentCertificate(email),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("Approve", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}