import 'package:flutter/material.dart';
import '../main/main_screen.dart';

/// 비밀번호 재설정 성공 화면
class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Container(
          width: 375,
          height: 355,
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
          child: Stack(
            children: [
              // 닫기 버튼
              Positioned(
                left: 320,
                top: 24,
                child: GestureDetector(
                  onTap: () {
                    // 로그인 화면으로 이동 (모든 스택을 지우고 메인 화면으로)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Container(
                    width: 33,
                    height: 33,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFE6E6E6),
                      shape: OvalBorder(),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black54,
                      size: 18,
                    ),
                  ),
                ),
              ),

              // 제목
              const Positioned(
                left: 105,
                top: 77,
                child: Text(
                  '비밀번호 재설정 성공!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // 설명 텍스트
              const Positioned(
                left: 67,
                top: 112,
                child: SizedBox(
                  width: 240,
                  child: Text(
                    '이제 새 비밀번호로 \n로그인할 수 있습니다!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF4B4B4B),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              // 성공 아이콘 (추가)
              Positioned(
                left: 171,
                top: 160,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF006FFD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
              ),

              // 확인 버튼
              Positioned(
                left: 16,
                top: 237,
                child: GestureDetector(
                  onTap: () {
                    // 로그인 화면으로 이동 (모든 스택을 지우고 메인 화면으로)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Container(
                    width: 343,
                    height: 50,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF006FFD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '확인',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
