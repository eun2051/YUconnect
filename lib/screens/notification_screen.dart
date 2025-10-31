import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 샘플 알림 데이터 (아이콘 포함, 스크린샷과 동일하게)
    final notifications = [
      NotificationData(
        title: '민원 답변이 완료되었습니다.',
        message: '답변을 확인해주세요!',
        icon: Icons.send, // 비행기
      ),
      NotificationData(
        title: '민원이 관련 부서에 전달되었습니다.',
        message: '빠르게 답변해드리겠습니다.',
        icon: Icons.headset_mic, // 헤드셋
      ),
      NotificationData(
        title: '민원이 확인되었습니다.',
        message: '곧 관련 부서로 전달될 예정입니다.',
        icon: Icons.mail_outline, // 편지
      ),
      NotificationData(
        title: '민원이 등록되었습니다.',
        message: '민원 게시물이 등록되었습니다.',
        icon: Icons.check_circle_outline, // 체크
      ),
      NotificationData(
        title: '공지사항이 등록되었습니다.',
        message: '공지사항을 확인해주세요!',
        icon: Icons.notifications_none, // 종
      ),
      NotificationData(
        title: '학과 공지사항이 등록되었습니다.',
        message: '학과 공지사항을 확인해주세요!',
        icon: Icons.notifications, // 종(채워진)
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 타이틀
            Container(
              width: 87,
              height: 45,
              child: Stack(
                children: [
                  Positioned(
                    left: 31,
                    top: 0,
                    child: Text(
                      '알림',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 30,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            // 알림 카드 리스트
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final data = notifications[index];
                  return NotificationCard(
                    title: data.title,
                    message: data.message,
                    icon: data.icon,
                  );
                },
              ),
            ),
            // 하단 안내 텍스트
            const SizedBox(
              width: 54,
              child: Text(
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
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const NotificationCard({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 326,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF7F8FD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        children: [
          // 아이콘 영역
          Container(
            width: 80,
            height: 69,
            decoration: ShapeDecoration(
              color: const Color(0xFFEAF2FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(icon, color: Color(0xFF5B6B92), size: 28),
            ),
          ),
          // 텍스트 영역
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1F2024),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
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
          // 우측 > 아이콘
          Container(
            width: 32,
            height: 69,
            alignment: Alignment.center,
            child: const Icon(
              Icons.chevron_right,
              color: Color(0xFFB0B3C7),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationData {
  final String title;
  final String message;
  final IconData icon;
  NotificationData({
    required this.title,
    required this.message,
    required this.icon,
  });
}
