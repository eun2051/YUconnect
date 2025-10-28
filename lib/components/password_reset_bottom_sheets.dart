import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

/// 비밀번호 재설정 이메일 입력 바텀시트
class PasswordResetEmailBottomSheet extends StatefulWidget {
  const PasswordResetEmailBottomSheet({super.key});

  @override
  State<PasswordResetEmailBottomSheet> createState() =>
      _PasswordResetEmailBottomSheetState();
}

class _PasswordResetEmailBottomSheetState
    extends State<PasswordResetEmailBottomSheet> {
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
        // 현재 바텀시트 닫기
        Navigator.pop(context);

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호 재설정 이메일을 전송했습니다. 이메일을 확인해주세요.'),
            backgroundColor: Colors.green,
          ),
        );

        // 잠시 후 새 비밀번호 입력 바텀시트 표시
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          _showNewPasswordBottomSheet(context, email);
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

  /// 새 비밀번호 입력 바텀시트 표시
  void _showNewPasswordBottomSheet(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PasswordResetNewPasswordBottomSheet(email: email),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: const Icon(Icons.close, color: Colors.black54, size: 18),
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
    );
  }
}

/// 새 비밀번호 입력 바텀시트
class PasswordResetNewPasswordBottomSheet extends StatefulWidget {
  final String email;

  const PasswordResetNewPasswordBottomSheet({super.key, required this.email});

  @override
  State<PasswordResetNewPasswordBottomSheet> createState() =>
      _PasswordResetNewPasswordBottomSheetState();
}

class _PasswordResetNewPasswordBottomSheetState
    extends State<PasswordResetNewPasswordBottomSheet> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 비밀번호 유효성 검사
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  /// 비밀번호 재설정
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호가 일치하지 않습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // 네트워크 지연 시뮬레이션

      if (mounted) {
        // 현재 바텀시트 닫기
        Navigator.pop(context);

        // 성공 바텀시트 표시
        _showSuccessBottomSheet(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호 변경 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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

  /// 성공 바텀시트 표시
  void _showSuccessBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PasswordResetSuccessBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // 제목
            const Text(
              '비밀번호 재설정',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 새 비밀번호 입력
                  const Text(
                    '새 비밀번호',
                    style: TextStyle(
                      color: Color(0xFF491B6D),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 44,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFF491B6D),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: TextFormField(
                      controller: _newPasswordController,
                      obscureText: !_isNewPasswordVisible,
                      decoration: InputDecoration(
                        hintText: '새 비밀번호를 입력하세요',
                        hintStyle: const TextStyle(
                          color: Color(0xFF4B4B4B),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFF491B6D),
                          ),
                          onPressed: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '새 비밀번호를 입력해주세요.';
                        }
                        if (!_isValidPassword(value)) {
                          return '비밀번호는 6자 이상이어야 합니다.';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 새 비밀번호 확인
                  const Text(
                    '새 비밀번호 확인',
                    style: TextStyle(
                      color: Color(0xFF491B6D),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 44,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFF491B6D),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        hintText: '비밀번호를 다시 입력하세요',
                        hintStyle: const TextStyle(
                          color: Color(0xFF4B4B4B),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFF491B6D),
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호 확인을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 확인 버튼
                  GestureDetector(
                    onTap: _isLoading ? null : _resetPassword,
                    child: Container(
                      width: double.infinity,
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 비밀번호 재설정 성공 바텀시트
class PasswordResetSuccessBottomSheet extends StatelessWidget {
  const PasswordResetSuccessBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                // 모든 바텀시트 닫기
                Navigator.pop(context);
              },
              child: Container(
                width: 33,
                height: 33,
                decoration: const ShapeDecoration(
                  color: Color(0xFFE6E6E6),
                  shape: OvalBorder(),
                ),
                child: const Icon(Icons.close, color: Colors.black54, size: 18),
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

          // 성공 아이콘
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
                // 모든 바텀시트 닫기
                Navigator.pop(context);
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
    );
  }
}
