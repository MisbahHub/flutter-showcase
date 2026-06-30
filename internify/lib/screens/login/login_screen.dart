import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internify/screens/admindashboard/admin_dashboard.dart';
import 'package:internify/screens/studentdashboard/student_dashboard.dart';
import 'package:internify/screens/login/registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isStudent = true;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }


  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      String email = _emailController.text.trim().toLowerCase();
      String password = _passwordController.text;

      if (_isStudent) {
        final prefs = await SharedPreferences.getInstance();


        List<String> internsJsonList = prefs.getStringList('registered_interns_list') ?? [];


        if (internsJsonList.isEmpty) {
          _showNoAccountDialog();
          setState(() => _isLoading = false);
          return;
        }

        bool emailExists = false;
        bool passwordMatches = false;

        for (String internRaw in internsJsonList) {
          Map<String, dynamic> intern = jsonDecode(internRaw);
          String savedEmail = (intern['email'] ?? "").toString().trim().toLowerCase();

          if (savedEmail == email) {
            emailExists = true;

            if (intern['password'] == password) {
              passwordMatches = true;

              await prefs.setString('student_name', intern['name'] ?? "Student");
              await prefs.setString('student_email', intern['email']);
              await prefs.setString('student_university', intern['university'] ?? "Not specified");
              await prefs.setString('student_domain', intern['domain'] ?? "Not specified");
              break;
            }
          }
        }

        if (passwordMatches) {

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StudentDashboard()),
            );
          }
        } else if (!emailExists) {

          _showNoAccountDialog();
        } else {
          _showSnackBar("Invalid password. Please try again.", Colors.redAccent);
        }

      } else {

        if (email == "admin@internify.com" && password == "admin123") {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          }
        } else {
          _showSnackBar("Invalid Admin Credentials", Colors.redAccent);
        }
      }
    } catch (e) {
      _showSnackBar("Something went wrong", Colors.red);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: color,
      ),
    );
  }

  void _showNoAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Account Not Found",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: const Color(0xFF0A58CA),
          ),
        ),
        content: Text(
          "It looks like this email isn't registered on this device yet. Please register to continue.",
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0A58CA),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo1.png', height: 90),
                    const SizedBox(height: 10),

                    Text(
                      "Internify",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A58CA),
                      ),
                    ),
                    const SizedBox(height: 5),

                    Text(
                      "Sign in to access your internship workspace",
                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),


                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildTab("Student", true),
                          _buildTab("Admin", false),
                        ],
                      ),
                    ),

                    if (!_isStudent)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Admin access only",
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                        ),
                      ),

                    const SizedBox(height: 25),


                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      },
                      decoration: _inputDecoration("Email Address", Icons.email),
                      validator: (v) => v!.contains("@") ? null : "Enter valid email",
                    ),
                    const SizedBox(height: 18),


                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submitForm(),
                      decoration: _inputDecoration("Password", Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black38),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      validator: (v) => v!.length < 5 ? "Password must be at least 5 characters long" : null,
                    ),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showSnackBar("Coming soon", Colors.blue),
                        child: Text("Forgot Password?", style: GoogleFonts.poppins(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: 15),


                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A58CA),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(
                          _isStudent ? "Continue as Student" : "Continue as Admin",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),


                    if (_isStudent)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have account? ", style: GoogleFonts.poppins(fontSize: 14)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                              );
                            },
                            child: Text(
                              "Register",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF0A58CA),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          )
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool student) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isStudent = student;
            _emailController.clear();
            _passwordController.clear();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: _isStudent == student ? const Color(0xFF0A58CA) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: _isStudent == student ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF0A58CA)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}