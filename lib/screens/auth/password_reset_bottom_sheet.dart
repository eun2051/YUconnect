import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 비밀번호 재설정 바텀시트 (이메일 인증 없이 바로 변경)
class PasswordResetBottomSheet extends StatefulWidget {
  const PasswordResetBottomSheet({super.key});

  @override
  State<PasswordResetBottomSheet> createState() =>
      _PasswordResetBottomSheetState();
}

class _PasswordResetBottomSheetState extends State<PasswordResetBottomSheet> {
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 이메일 유효성 검사
  bool _isValidYUEmail(String email) {
    return email.trim().endsWith('@yu.ac.kr');
  }

  /// 현재 비밀번호로 사용자 인증
  Future<void> _authenticateUser() async {
    final email = _emailController.text.trim();
    final currentPassword = _currentPasswordController.text.trim();

    if (!_isValidYUEmail(email)) {
      _showErrorDialog('유효한 영남대 이메일 주소를 입력해주세요.');
      return;
    }

    if (currentPassword.isEmpty) {
      _showErrorDialog('현재 비밀번호를 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 현재 비밀번호로 로그인하여 인증
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: currentPassword,
      );

      // 인증 성공 시 다음 화면으로 이동
      _nextPage();
    } catch (e) {
      _showErrorDialog('인증에 실패했습니다. 이메일과 현재 비밀번호를 확인해주세요.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 비밀번호 재설정 (실제 Firebase Auth 비밀번호 변경)
  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog('모든 필드를 입력해주세요.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorDialog('비밀번호가 일치하지 않습니다.');
      return;
    }

    if (newPassword.length < 6) {
      _showErrorDialog('비밀번호는 최소 6자 이상이어야 합니다.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 현재 사용자의 비밀번호를 실제로 변경
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        _nextPage();
      } else {
        _showErrorDialog('사용자 인증 정보를 찾을 수 없습니다.');
      }
      await Future.delayed(const Duration(seconds: 1));
      _nextPage();
    } catch (e) {
      _showErrorDialog('비밀번호 재설정에 실패했습니다.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 다음 페이지로 이동
  void _nextPage() {
    if (_currentPage < 2) {
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildEmailInputPage(scrollController),
            _buildPasswordResetPage(scrollController),
            _buildSuccessPage(scrollController),
          ],
        ),
      ),
    );
  }

  /// 첫 번째 화면: 이메일 입력
  Widget _buildEmailInputPage([ScrollController? scrollController]) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // 상단 바
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24), // 줄임

            // 닫기 버튼
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 33,
                  height: 33,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6E6E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 16), // 줄임

            // 제목
            const Text(
              '비밀번호를 잊었나요?',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16), // 줄임

            // 설명
            const Text(
              '본인 확인을 위해 이메일과 현재 비밀번호를 입력해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF4B4B4B),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 24), // 줄임

            // 이메일 입력 필드
            Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: const Color(0xFF491B6D)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText: '이메일을 입력하세요',
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 16), // 줄임

            // 현재 비밀번호 입력 필드
            Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: const Color(0xFF491B6D)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText: '현재 비밀번호를 입력하세요',
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 16), // 줄임

            // 안내 텍스트
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '본인 확인 후 새로운 비밀번호를 설정할 수 있습니다.',
                style: TextStyle(
                  color: Color(0xFF4B4B4B),
                  fontSize: 14, // 줄임
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 24), // 줄임

            // 확인 버튼
            GestureDetector(
              onTap: _isLoading ? null : _authenticateUser,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF006FFD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
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
            const SizedBox(height: 20), // 하단 여백 추가
          ],
        ),
      ),
    );
  }

  /// 두 번째 화면: 비밀번호 재설정
  Widget _buildPasswordResetPage([ScrollController? scrollController]) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 바
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 40),

            // 제목
            const Center(
              child: Text(
                '비밀번호 재설정',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 40),

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
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: const Color(0xFF491B6D)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText: '새 비밀번호를 입력하세요',
                  hintStyle: TextStyle(color: Color(0xFF4B4B4B), fontSize: 14),
                ),
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
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: const Color(0xFF491B6D)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText: '비밀번호를 다시 입력하세요',
                  hintStyle: TextStyle(color: Color(0xFF4B4B4B), fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 24), // 줄임

            // 확인 버튼
            GestureDetector(
              onTap: _isLoading ? null : _resetPassword,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF006FFD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
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
            const SizedBox(height: 20), // 하단 여백 추가
          ],
        ),
      ),
    );
  }

  /// 세 번째 화면: 성공 화면
  Widget _buildSuccessPage([ScrollController? scrollController]) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // 상단 바
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 40),

            // 닫기 버튼
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 33,
                  height: 33,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6E6E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 제목
            const Text(
              '비밀번호 재설정 성공!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            // 설명
            const Text(
              '이제 새 비밀번호로 \n로그인할 수 있습니다!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF4B4B4B),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 40), // 줄임

            // 확인 버튼
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF006FFD),
                  borderRadius: BorderRadius.circular(10),
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
            const SizedBox(height: 20), // 하단 여백 추가
          ],
        ),
      ),
    );
  }
}
