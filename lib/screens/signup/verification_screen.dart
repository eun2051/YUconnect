// lib/screens/signup/verification_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '비밀번호 찾기',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Text('확인 코드를 입력해주세요!', style: GoogleFonts.inter(fontSize: 20)),
      ),
    );
  }
}
