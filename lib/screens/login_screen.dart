import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yu_connect/screens/signup/signup_screen.dart';
import 'package:yu_connect/screens/main/home_screen.dart';
import 'package:yu_connect/screens/signup/verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              // 상단 이미지 배경 영역
              height: screenHeight * 0.45,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/yungnam_building.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 하단 흰색 배경 영역 (둥근 모서리)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // "어서오세요!" 텍스트
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '어서오세요!',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 학교 이메일 입력 필드
                  const SizedBox(
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: '학교 이메일',
                        labelStyle: TextStyle(fontSize: 14.0),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 비밀번호 입력 필드
                  SizedBox(
                    height: 50,
                    child: TextField(
                      textAlign: TextAlign.left,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        labelStyle: const TextStyle(
                          fontSize: 14.0,
                        ), // 폰트 크기 14.0 설정
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ), // 입력 텍스트 크기 14.0 설정
                    ),
                  ),
                  const SizedBox(height: 12),

                  // '비밀번호를 잊었나요?' 버튼
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const VerificationScreen(),
                          ),
                        );
                      },
                      child: Text(
                        '비밀번호를 잊었나요?',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF006FFD),
                          fontWeight: FontWeight.w800,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // '로그인' 버튼
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006FFD),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      '로그인',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 회원가입 문구와 버튼을 가로로 배치
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '영남대 재학생이신가요?',
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          '회원가입',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF006FFD),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64), // 하단 여백 추가
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
