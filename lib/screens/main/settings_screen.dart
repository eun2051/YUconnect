import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import '../../components/mode_selection_bottom_sheet.dart';
import '../../components/language_selection_bottom_sheet.dart';
import 'notification_screen.dart';

/// 설정 화면
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  /// 로그아웃 처리
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 설정 항목 빌드
  Widget _buildSettingItem({
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1F2024),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Color(0xFF8F9098),
                ),
          ],
        ),
      ),
    );
  }

  /// 사용자 프로필 섹션
  Widget _buildUserProfile() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // 프로필 이미지와 편집 버튼
          Stack(
            children: [
              // 프로필 이미지 (크기 축소)
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F2FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCCE7FF), width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 45, color: Color(0xFF006FFD)),
                ),
              ),

              // 편집 버튼
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // TODO: 프로필 이미지 편집 기능
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('프로필 편집 기능은 준비 중입니다.')),
                    );
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF006FFD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 사용자 정보
          Column(
            children: [
              Text(
                '이승은',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1F2024),
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '@yu22412051',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF71727A),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                  letterSpacing: 0.12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 여백
            const SizedBox(height: 56),

            // 헤더
            Container(
              width: double.infinity,
              height: 56,
              child: const Center(
                child: Text(
                  '설정',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1F2024),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // 사용자 프로필
            _buildUserProfile(),

            // 설정 항목들
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  // 알림
                  _buildSettingItem(
                    title: '알림',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),

                  // 구분선
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey[200],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),

                  // 모드 변경
                  _buildSettingItem(
                    title: '모드 변경',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const ModeSelectionBottomSheet(),
                      );
                    },
                  ),

                  // 구분선
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey[200],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),

                  // 언어
                  _buildSettingItem(
                    title: '언어',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            const LanguageSelectionBottomSheet(),
                      );
                    },
                  ),

                  // 구분선
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey[200],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),

                  // 비밀번호 변경
                  _buildSettingItem(
                    title: '비밀번호 변경',
                    onTap: () {
                      // TODO: 비밀번호 변경 화면으로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호 변경 기능은 준비 중입니다.')),
                      );
                    },
                  ),

                  // 구분선
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey[200],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),

                  // 행사 신청 내역 조회
                  _buildSettingItem(
                    title: '행사 신청 내역 조회',
                    onTap: () {
                      // TODO: 행사 신청 내역 조회 화면으로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('행사 신청 내역 조회 기능은 준비 중입니다.'),
                        ),
                      );
                    },
                  ),

                  // 구분선
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey[200],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),

                  // 관리자 인증
                  _buildSettingItem(
                    title: '관리자 인증',
                    onTap: () {
                      // TODO: 관리자 인증 화면으로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('관리자 인증 기능은 준비 중입니다.')),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // 로그아웃 버튼
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: _signOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '로그아웃',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
