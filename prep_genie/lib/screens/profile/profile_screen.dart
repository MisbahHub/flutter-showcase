import 'package:flutter/material.dart';
import 'package:prep_genie/screens/login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;
  const ProfileScreen({super.key, required this.userEmail});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  bool isDarkMode = true;


  String getUserName(String email) {
   if (email.isEmpty || !email.contains('@')) {
    return "PrepGenie User";
  }
   String rawName = email.split('@')[0];
   return rawName[0].toUpperCase() + rawName.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    String dynamicName = getUserName(widget.userEmail);
    final backgroundColor = isDarkMode ? const Color(0xFF0A0E21) : const Color(0xFFF5F7FB);
    final cardColor = isDarkMode ? const Color(0xFF131937) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0A0E21);
    final subTextColor = isDarkMode ? Colors.white54 : Colors.black54;

    return Scaffold(

      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "User Profile",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_note_rounded, color: Colors.purpleAccent, size: 26),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [

             Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.purpleAccent,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: cardColor,
                      backgroundImage: AssetImage('assets/images/prepGenie1.jpg'),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        print("Camera icon clicked!");
                      },
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.purpleAccent,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              dynamicName,
              style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.userEmail.isEmpty ? "user@example.com" : widget.userEmail,
              style: TextStyle(color: subTextColor, fontSize: 14),
            ),

            const SizedBox(height: 40),


            _buildProfileSectionTitle("Account Settings"),
            const SizedBox(height: 10),
            _buildProfileOption(Icons.person_outline, "Personal Information", cardColor, textColor),
            _buildProfileOption(Icons.history_edu_rounded, "Interview History", cardColor, textColor),
            _buildProfileOption(Icons.bookmark_border_rounded, "Saved Questions", cardColor, textColor),

            const SizedBox(height: 30),

            _buildProfileSectionTitle("App Preferences"),
            const SizedBox(height: 10),

            _buildToggleOption(Icons.dark_mode_outlined, "Dark Mode Theme", isDarkMode, cardColor, textColor, (val) {
              setState(() {
                isDarkMode = val;
              });
            }),

            _buildProfileOption(Icons.notifications_none_rounded, "Notifications", cardColor, textColor),
            _buildProfileOption(Icons.help_outline_rounded, "Help & Support", cardColor, textColor),

            const SizedBox(height: 40),


            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardColor,
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 20),
                    SizedBox(width: 10),
                    Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(color: Colors.purpleAccent, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }


  Widget _buildProfileOption(IconData icon, String title, Color bgColor, Color txtColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isDarkMode ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  print("$title clicked!");
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(icon, color: txtColor.withOpacity(0.7), size: 22),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(title, style: TextStyle(color: txtColor, fontSize: 15)),
                      ),
                      Icon(Icons.arrow_forward_ios, color: txtColor.withOpacity(0.3), size: 14),
                    ],
                  ),
                ),
            ),
      ),
    );
  }


  Widget _buildToggleOption(IconData icon, String title, bool value, Color bgColor, Color txtColor, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isDarkMode ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: txtColor.withOpacity(0.7), size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title, style: TextStyle(color: txtColor, fontSize: 15)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.purpleAccent,
          )
        ],
      ),
    );
  }
}