import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'password_reset_new_password_screen.dart';

/// 비밀번호 재설정 - 이메일 입력 화면
class PasswordResetEmailScreen extends StatefulWidget {
  const PasswordResetEmailScreen({super.key});

  @override
  State<PasswordResetEmailScreen> createState() =>
      _PasswordResetEmailScreenState();
}

class _PasswordResetEmailScreenState extends State<PasswordResetEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// 영남대 이메일 유효성 검사
  bool _isValidYUEmail(String email) {
    return email.trim().endsWith('@yu.ac.kr');
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> _sendPasswordResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      await authService.sendPasswordResetEmail(email);

      if (mounted) {
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호 재설정 이메일을 전송했습니다. 이메일을 확인해주세요.'),
            backgroundColor: Colors.green,
          ),
        );

        // 잠시 후 다음 화면으로 이동
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PasswordResetNewPasswordScreen(email: email),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = '오류가 발생했습니다.';
        if (e.toString().contains('user-not-found')) {
          errorMessage = '등록되지 않은 이메일입니다.';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = '유효하지 않은 이메일 형식입니다.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Container(
          width: 375,
          height: 425,
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
                left: 315,
                top: 22,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
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
                left: 88,
                top: 59,
                child: Text(
                  '비밀번호를 잊었나요?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // 설명 텍스트
              const Positioned(
                left: 19,
                top: 99,
                child: SizedBox(
                  width: 337,
                  child: Text(
                    '학교 이메일 주소를 입력하면 새 비밀번호를 생성할 수 있는 링크를 공유해 드립니다.',
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

              // 입력 폼
              Positioned(
                left: 16,
                top: 191,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이메일 입력 필드
                      Container(
                        width: 343,
                        height: 44,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0xFF491B6D),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'user@yu.ac.kr',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이메일을 입력해주세요.';
                            }
                            if (!_isValidYUEmail(value)) {
                              return '영남대 이메일(@yu.ac.kr)을 입력해주세요.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 안내 텍스트
                      const SizedBox(
                        width: 227,
                        child: Text(
                          '학교 이메일을 입력하시오.',
                          style: TextStyle(
                            color: Color(0xFF4B4B4B),
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 보내기 버튼
                      GestureDetector(
                        onTap: _isLoading ? null : _sendPasswordResetEmail,
                        child: Container(
                          width: 343,
                          height: 50,
                          decoration: ShapeDecoration(
                            color: _isLoading
                                ? Colors.grey
                                : const Color(0xFF006FFD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : const Text(
                                    '보내기',
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
                    ],
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
