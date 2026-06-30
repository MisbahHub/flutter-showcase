import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internify/screens/login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();


    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _animate = true;
        });
      }
    });


    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            top: _animate
                ? MediaQuery.of(context).size.height * 0.35
                : MediaQuery.of(context).size.height * 0.4,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: _animate ? 1.0 : 0.0,
              child: Column(
                children: [
                  AnimatedScale(
                    scale: _animate ? 1 : 0.8,
                    duration: const Duration(milliseconds: 800),
                    child: Image.asset(
                      'assets/images/logo1.png',
                      width: 140,
                      height: 140,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Internify',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0A58CA),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),


          Positioned(
            bottom: 50,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _animate ? 0.7 : 0.0,
              child: Column(
                children: [
                  Text(
                    'Your Gateway to Virtual Internships',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),


                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0A58CA),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}