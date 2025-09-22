import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yu_connect/screens/signup/signup_screen.dart';
import 'package:yu_connect/screens/main/home_screen.dart';
import 'package:yu_connect/screens/signup/verification_screen.dart';
import 'package:yu_connect/services/auth_service.dart';
//import 'package:yu_connect/widgets/error_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    // 이메일과 비밀번호가 비어있는지 확인
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        _showErrorDialog('이메일과 비밀번호를 모두 입력해주세요.');
      }
      return;
    }
    try {
      // AuthService를 통해 로그인 시도
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 로그인 성공 시 홈 화면으로 이동
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      // 로그인 실패 시 오류 메시지 표시
      if (mounted) {
        _showErrorDialog('회원정보가 없습니다.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text(
            '오류 발생',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

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
                  SizedBox(
                    height: 50,
                    child: TextField(
                      controller: _emailController,
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
                      controller: _passwordController,
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
                    onPressed: _login,
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
