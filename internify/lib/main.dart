import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internify/screens/login/login_screen.dart';
import 'package:internify/screens/splash/splash_screen.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0A58CA),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A58CA),
          secondary: const Color(0xFF00C4B4),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
