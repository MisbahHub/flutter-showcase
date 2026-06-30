import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  String _certificateStatus = "Not Requested";
  String _userEmail = "";
  String _studentDomain = "Flutter Developer";

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('student_email') ?? "";
    List<String> internsRawList = prefs.getStringList('registered_interns_list') ?? [];

    String currentStatus = "Not Requested";
    String detectedDomain = "Software Development";

    _userEmail = email;

    for (String rawJson in internsRawList) {
      Map<String, dynamic> intern = jsonDecode(rawJson);
      if (intern['email'] == email) {

        if (intern['domain'] != null && intern['domain'].toString().isNotEmpty) {
          detectedDomain = intern['domain'];
        }

        if (intern['certificate_status'] == "Approved") {
          currentStatus = "Approved";
        }
        else if (intern['certificate_status'] == "Pending" && intern['has_requested_certificate'] == true) {
          currentStatus = "Pending";
        }
        else {
          currentStatus = "Not Requested";
        }
        break;
      }
    }

    setState(() {
      _certificateStatus = currentStatus;
      _studentDomain = detectedDomain;
    });
  }

  Future<void> _requestCertificate() async {
    if (_userEmail.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> internsRawList = prefs.getStringList('registered_interns_list') ?? [];
    List<String> updatedList = [];

    for (String rawJson in internsRawList) {
      Map<String, dynamic> intern = jsonDecode(rawJson);
      if (intern['email'] == _userEmail) {
        intern['has_requested_certificate'] = true;
        intern['certificate_status'] = "Pending";
      }
      updatedList.add(jsonEncode(intern));
    }

    await prefs.setStringList('registered_interns_list', updatedList);

    String notifyKey = "notifications_$_userEmail";
    List<String> currentNotifications = prefs.getStringList(notifyKey) ?? [];

    Map<String, dynamic> certNotification = {
      "title": "Certificate Request Submitted",
      "desc": "Your certificate request has been submitted and is currently under review.",
      "type": "cert_status",
      "status": "Pending",
      "timestamp": DateTime.now().millisecondsSinceEpoch.toString()
    };

    currentNotifications.insert(0, jsonEncode(certNotification));
    await prefs.setStringList(notifyKey, currentNotifications);

    String unreadKey = "unread_alerts_$_userEmail";
    int currentUnread = prefs.getInt(unreadKey) ?? 0;
    await prefs.setInt(unreadKey, currentUnread + 1);

    setState(() {
      _certificateStatus = 'Pending';
    });

    _showSnack("Certificate request submitted successfully.", Colors.blue);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: color,
      ),
    );
  }

  Color _statusColor() {
    switch (_certificateStatus) {
      case "Approved":
        return Colors.green;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon() {
    switch (_certificateStatus) {
      case "Approved":
        return Icons.verified;
      case "Pending":
        return Icons.hourglass_top;
      default:
        return Icons.workspace_premium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 60),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Certificates",
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.06),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _statusIcon(),
                      size: 50,
                      color: color,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "$_studentDomain Intern",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Internship Certificate Portal",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Certificate Status: ",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        _certificateStatus,
                        style: GoogleFonts.poppins(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _certificateStatus == 'Not Requested'
                          ? _requestCertificate
                          : (_certificateStatus == 'Approved'
                          ? () => _showSnack("Your certificate download is starting.", Colors.green)
                          : null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _certificateStatus == "Approved"
                            ? Colors.green
                            : const Color(0xFF0A58CA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _certificateStatus == "Not Requested"
                            ? "Request Certificate"
                            : _certificateStatus == "Pending"
                            ? "Pending Review"
                            : "Download Certificate",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}