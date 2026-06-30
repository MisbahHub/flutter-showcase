import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InternsListScreen extends StatefulWidget {
  const InternsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InternsListScreenContent();
  }

  @override
  State<InternsListScreen> createState() => _InternsListScreenState();
}


class _InternsListScreenContent extends StatelessWidget {
  const _InternsListScreenContent();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _InternsListScreenState extends State<InternsListScreen> {

  List<Map<String, dynamic>> _internsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInterns();
  }


  Future<void> _loadInterns() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> rawJsonList = prefs.getStringList('registered_interns_list') ?? [];

    List<Map<String, dynamic>> parsedList = [];
    for (String rawJson in rawJsonList) {
      parsedList.add(jsonDecode(rawJson));
    }

    setState(() {
      _internsList = parsedList;
      _isLoading = false;
    });
  }


  void _showDeleteInternConfirmationDialog(String email, String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Delete Intern Account",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.redAccent),
          ),
          content: Text(
            "Are you sure you want to remove $name from the internship program? This action cannot be undone.",
            style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();

                List<String> rawJsonList = prefs.getStringList('registered_interns_list') ?? [];
                List<String> updatedList = [];


                for (String rawJson in rawJsonList) {
                  Map<String, dynamic> intern = jsonDecode(rawJson);
                  if (intern['email'] != email) {
                    updatedList.add(rawJson);
                  }
                }


                await prefs.setStringList('registered_interns_list', updatedList);

                if (prefs.getString('student_email') == email) {
                  await prefs.remove('student_name');
                  await prefs.remove('student_email');
                  await prefs.remove('student_university');
                  await prefs.remove('student_domain');
                }

                _loadInterns();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Intern account removed successfully.', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.redAccent
                    ),
                  );
                }
              },
              child: Text("Delete", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text("Intern Management", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0A58CA)),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A58CA)))
          : _internsList.isEmpty
          ? Center(
        child: Text("No active interns available.", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _internsList.length,
        itemBuilder: (context, index) {
          final intern = _internsList[index];
          String name = intern['name'] ?? "Unknown Intern";
          String university = intern['university'] ?? "Not specified";
          String domain = intern['domain'] ?? "Not specified";
          String email = intern['email'] ?? "";

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.01), blurRadius: 6)],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF0A58CA).withOpacity(0.08),
                child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "I",
                    style: const TextStyle(color: Color(0xFF0A58CA), fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
              title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        children: [
                          const Icon(Icons.account_balance_rounded, size: 13, color: Colors.black38),
                          const SizedBox(width: 6),
                          Expanded(child: Text(university, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis))
                        ]
                    ),
                    const SizedBox(height: 3),
                    Row(
                        children: [
                          const Icon(Icons.work_outline_rounded, size: 13, color: Colors.black38),
                          const SizedBox(width: 6),
                          Expanded(child: Text(domain, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis))
                        ]
                    ),
                  ],
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 24),
                onPressed: () => _showDeleteInternConfirmationDialog(email, name),
              ),
            ),
          );
        },
      ),
    );
  }
}