import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yu_connect/screens/main/home_screen.dart';
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
    _checkAuthStateAndNavigate(); //인증 상태 확인 함수 호출
  }

  void _checkAuthStateAndNavigate() async {
    // 1초 대기 (로고를 충분히 보여주기 위함)
    await Future.delayed(const Duration(seconds: 1));

    //Firebase의 사용자 인증 상태 변화를 한 번만 감지
    FirebaseAuth.instance.authStateChanges().first.then((user) {
      if (mounted) {
        if (user == null) {
          // 사용자가 로그아웃 상태 > 로그인 화면으로 이동
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          // 사용자가 로그인 상태 > 홈 화면으로 이동
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
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
