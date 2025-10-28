import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterProfileIntroScreen extends StatelessWidget {
  const RegisterProfileIntroScreen({super.key});

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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final args = ModalRoute.of(context)?.settings.arguments as Map?;
                if (args == null ||
                    args['email'] == null ||
                    args['password'] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('이메일/비밀번호 정보가 없습니다. 처음부터 다시 시도해 주세요.'),
                    ),
                  );
                  return;
                }
                Navigator.pushNamed(
                  context,
                  '/register2',
                  arguments: {
                    'email': args['email'],
                    'password': args['password'],
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006FFD),
                minimumSize: const Size(327, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '시작하기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '프로필을 완성해주세요',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF1F2024),
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '최고의 서비스를 제공하기 위해 \n프로필을 완성해주세요!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF71727A),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.33,
                letterSpacing: 0.12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
