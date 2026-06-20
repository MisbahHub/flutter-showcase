import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prep_genie/screens/login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){

    super.initState();
    Timer(const Duration(seconds: 3), (){
     if(mounted){
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) => LoginScreen()),
       );
     }
    }
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E21),
      body: Center(
          child: Column(
            mainAxisAlignment : MainAxisAlignment.center,
            children: [
             CircleAvatar(
               radius: 80,
               backgroundColor: Colors.transparent,
               backgroundImage:  AssetImage(
                 'assets/images/prepGenie1.jpg',
               ),
             ),
              SizedBox(height: 15),
              Text(
                "PrepGenie",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Your AI Interview Wingman",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                color: Colors.purpleAccent,
                strokeWidth: 3,
              ),
            ],
          )
        )

    );
  }
}
