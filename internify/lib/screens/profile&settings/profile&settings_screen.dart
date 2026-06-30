import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internify/screens/login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = "Please wait...";
  String _email = "Please wait...";
  String _university = "";
  String _domain = "";

  bool _darkMode = false;
  bool _biometric = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }


  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _name = prefs.getString('student_name') ?? "Student";
      _email = prefs.getString('student_email') ?? "example@gmail.com";
      _university = prefs.getString('student_university') ?? "";
      _domain = prefs.getString('student_domain') ?? "";

      _darkMode = prefs.getBool('dark_mode') ?? false;
      _biometric = prefs.getBool('biometric') ?? false;
    });
  }


  Future<void> _toggleDark(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    setState(() => _darkMode = value);
  }


  Future<void> _toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric', value);
    setState(() => _biometric = value);
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: GoogleFonts.poppins())),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Sign Out",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.redAccent,
            ),
          ),
          content: Text(
            "Are you sure you want to sign out of your account?",
            style: GoogleFonts.poppins(
              color: _darkMode ? Colors.white70 : Colors.black54,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              child: Text(
                "OK",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Delete Account",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          content: Text(
            "Are you sure you want to delete your account? This action cannot be undone.",
            style: GoogleFonts.poppins(
              color: _darkMode ? Colors.white70 : Colors.black54,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                  _showSnack("Your account has been deleted successfully.");
                }
              },
              child: Text(
                "Delete",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = _darkMode ? Colors.white : Colors.black87;
    Color subtitleColor = _darkMode ? Colors.white60 : Colors.black54;
    Color iconColor = _darkMode ? Colors.white70 : Colors.black54;
    Color dividerColor = _darkMode ? Colors.white12 : Colors.grey.shade200;
    Color cardColor = _darkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: _darkMode ? const Color(0xFF121212) : const Color(0xFFF4F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A58CA), Color(0xFF4EC5B6)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
              ),
              child: Column(
                children: [
                  Text(
                    "Profile & Settings",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: Text(
                        _name.isNotEmpty ? _name[0].toUpperCase() : "S",
                        style: const TextStyle(
                          fontSize: 32,
                          color: Color(0xFF0A58CA),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    _name,
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    _email,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.75)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: _darkMode ? [] : [BoxShadow(color: Colors.black12.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFF0A58CA).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.account_balance_rounded, color: Color(0xFF0A58CA), size: 22),
                          ),
                          title: Text("University", style: GoogleFonts.poppins(fontSize: 11, color: subtitleColor, fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            _university.isEmpty ? "Not Provided" : _university,
                            style: GoogleFonts.poppins(fontSize: 14, color: textColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Divider(color: dividerColor, height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFF4EC5B6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.code_rounded, color: Color(0xFF4EC5B6), size: 22),
                          ),
                          title: Text("Internship Domain", style: GoogleFonts.poppins(fontSize: 11, color: subtitleColor, fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            _domain.isEmpty ? "Not Provided" : _domain,
                            style: GoogleFonts.poppins(fontSize: 14, color: textColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: _darkMode ? [] : [BoxShadow(color: Colors.black12.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.lock_outline, color: iconColor),
                          title: Text("Change Password", style: GoogleFonts.poppins(color: textColor, fontSize: 14)),
                          subtitle: Text("Available soon", style: GoogleFonts.poppins(color: subtitleColor, fontSize: 11)),
                          onTap: () => _showSnack("This feature will be available soon."),
                        ),
                        Divider(color: dividerColor, height: 1),
                        SwitchListTile(
                          value: _darkMode,
                          activeColor: const Color(0xFF0A58CA),
                          secondary: Icon(Icons.dark_mode_outlined, color: iconColor),
                          title: Text("Dark Mode", style: GoogleFonts.poppins(color: textColor, fontSize: 14)),
                          onChanged: _toggleDark,
                        ),
                        Divider(color: dividerColor, height: 1),
                        SwitchListTile(
                          value: _biometric,
                          activeColor: const Color(0xFF0A58CA),
                          secondary: Icon(Icons.fingerprint_rounded, color: iconColor),
                          title: Text("Biometric Lock", style: GoogleFonts.poppins(color: textColor, fontSize: 14)),
                          onChanged: _toggleBiometric,
                        ),
                        Divider(color: dividerColor, height: 1),
                        ListTile(
                          leading: Icon(Icons.info_outline, color: iconColor),
                          title: Text("About Internify", style: GoogleFonts.poppins(color: textColor, fontSize: 14)),
                          subtitle: Text("Version 1.0", style: GoogleFonts.poppins(color: subtitleColor, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                      label: Text(
                        "Sign Out",
                        style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _darkMode ? const Color(0xFF2C2C2C) : Colors.red.withOpacity(0.06),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),


                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: TextButton.icon(
                      onPressed: () => _showDeleteAccountDialog(context),
                      icon: const Icon(Icons.delete_forever_rounded, color: Colors.grey, size: 20),
                      label: Text(
                        "Permanently Delete Account",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}