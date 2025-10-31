import 'package:flutter/material.dart';

/// 알림 조회 화면 (디자인 반영)
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 16,
                top: 20,
                bottom: 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF23272F),
                    ),
                    onPressed: () => Navigator.pop(context),
                    tooltip: '뒤로가기',
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '알림',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 26,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    '민원 알림',
                    style: TextStyle(
                      color: Color(0xFF71727A),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      letterSpacing: 0.12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _notificationCard('민원 답변이 완료되었습니다.', '답변을 확인해주세요!'),
                  _notificationCard(
                    '민원이 관련 부서에 전달되었습니다.',
                    '빠르게 답변해드리겠습니다.',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  _notificationCard('민원이 확인되었습니다.', '곧 관련 부서로 전달될 예정입니다.'),
                  _notificationCard('민원이 등록되었습니다.', '민원 게시물이 등록되었습니다.'),
                  const SizedBox(height: 24),
                  const Text(
                    '민원 알림',
                    style: TextStyle(
                      color: Color(0xFF71727A),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      letterSpacing: 0.12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _notificationCard('공지사항이 등록되었습니다.', '공지사항을 확인해주세요!'),
                  _notificationCard('학과 공지사항이 등록되었습니다.', '학과 공지사항을 확인해주세요!'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _notificationCard(
    String title,
    String subtitle, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF7F8FD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 80,
            height: 69,
            decoration: ShapeDecoration(
              color: const Color(0xFFEAF2FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF1F2024),
                      fontSize: fontSize,
                      fontFamily: 'Inter',
                      fontWeight: fontWeight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF71727A),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      letterSpacing: 0.12,
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
