import 'dart:convert'; // ✅ JSON processing ke liye yeh import lazmi add kiya hai
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _universityController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();


  String? _selectedDomain;

  final List<String> _domainsList = [
    "Flutter Developer",
    "Web Developer",
    "iOS Developer",
    "UI/UX Designer",
    "Python Developer (AI/ML)",
    "Data Science",
    "Graphic Designer"
  ];

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    String email = _emailController.text.trim().toLowerCase();


    List<String> internsJsonList = prefs.getStringList('registered_interns_list') ?? [];

    bool isDuplicate = false;

    for (String internRaw in internsJsonList) {
      Map<String, dynamic> internData = jsonDecode(internRaw);
      if (internData['email'] == email) {
        isDuplicate = true;
        break;
      }
    }

    if (isDuplicate) {
      _showSnack("This email is already registered. Please sign in to continue.", Colors.orange);
    } else {

      Map<String, dynamic> newIntern = {
        'name': _nameController.text.trim(),
        'email': email,
        'password': _passwordController.text,
        'university': _universityController.text.trim(),
        'domain': _selectedDomain,
        'has_requested_certificate': false,
        'certificate_status': 'Pending',
      };


      internsJsonList.add(jsonEncode(newIntern));
      await prefs.setStringList('registered_interns_list', internsJsonList);


      await prefs.setString('student_name', _nameController.text.trim());
      await prefs.setString('student_email', email);
      await prefs.setString('student_university', _universityController.text.trim());
      await prefs.setString('student_domain', _selectedDomain!);


      await prefs.setBool('is_intern_registered', true);

      _showSnack("Welcome to Internify! Your account is ready.", Colors.green);

      if (mounted) {
        Navigator.pop(context);
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: color,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.black45, fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF0A58CA), size: 22),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0A58CA), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0A58CA)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Create Account",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A58CA),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your internship journey starts here",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),


                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    decoration: _inputDecoration("Full Name", Icons.person),
                    validator: (v) => v == null || v.trim().isEmpty ? "Enter full name" : null,
                  ),
                  const SizedBox(height: 20),


                  TextFormField(
                    controller: _universityController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    decoration: _inputDecoration("University Name", Icons.account_balance_rounded),
                    validator: (v) => v == null || v.trim().isEmpty ? "Enter university name" : null,
                  ),
                  const SizedBox(height: 20),


                  DropdownButtonFormField<String>(
                    value: _selectedDomain,
                    hint: Text("Select Internship Domain", style: GoogleFonts.poppins(color: Colors.black45, fontSize: 14)),
                    decoration: _inputDecoration("Internship Domain", Icons.work_outline_rounded),
                    icon: const Icon(Icons.arrow_drop_down_circle, color: Color(0xFF0A58CA)),
                    items: _domainsList.map((String domain) {
                      return DropdownMenuItem<String>(
                        value: domain,
                        child: Text(domain, style: GoogleFonts.poppins(fontSize: 14)),
                      );
                    }).toList(),

                    validator: (value) => value == null ? "Please select a internship domain" : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDomain = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration("Email Address", Icons.email_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Enter email address";
                      if (!v.contains("@") || !v.contains(".")) return "Please enter a valid email address.";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ✅ 5. PASSWORD FIELD
                  TextFormField(
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    obscureText: !_isPasswordVisible,
                    decoration: _inputDecoration("Account Password", Icons.lock_outline_rounded).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black45),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    validator: (v) => v != null && v.length < 5 ? "Password must be at least 5 characters long" : null,
                  ),
                  const SizedBox(height: 30),


                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A58CA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text(
                        "Create Account",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}