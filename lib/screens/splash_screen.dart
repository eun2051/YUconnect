import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yu_connect/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/images/yu_logo.png'),
              width: 150,
            ),
            const SizedBox(height: 38),
            Text(
              'YUconnect',
              style: GoogleFonts.balsamiqSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00387A),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '영남대학교 민원통합시스템',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
