import 'package:flutter/material.dart';

/// 알림 조회 화면 (디자인 반영)
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF23272F),
          ),
          onPressed: () => Navigator.pop(context),
          tooltip: '뒤로가기',
        ),
        centerTitle: true,
        title: const Text(
          '알림',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 26,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 민원 알림 소제목
          const Positioned(
            left: 29,
            top: 121,
            child: SizedBox(
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
          ),
          // 알림 카드들
          _buildNotificationCard(
            left: 26,
            top: 146,
            title: '민원 답변이 완료되었습니다.',
            subtitle: '답변을 확인해주세요!',
          ),
          _buildNotificationCard(
            left: 26,
            top: 232,
            title: '민원이 관련 부서에 전달되었습니다.',
            subtitle: '빠르게 답변해드리겠습니다.',
            titleFontSize: 12,
            titleFontWeight: FontWeight.w600,
          ),
          _buildNotificationCard(
            left: 26,
            top: 318,
            title: '민원이 확인되었습니다.',
            subtitle: '곧 관련 부서로 전달될 예정입니다.',
          ),
          _buildNotificationCard(
            left: 26,
            top: 404,
            title: '민원이 등록되었습니다.',
            subtitle: '민원 게시물이 등록되었습니다.',
          ),
          // 민원 알림 소제목(아래)
          const Positioned(
            left: 32,
            top: 492,
            child: SizedBox(
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
          ),
          // 추가 알림 카드들
          _buildNotificationCard(
            left: 29,
            top: 517,
            title: '공지사항이 등록되었습니다.',
            subtitle: '공지사항을 확인해주세요!',
          ),
          _buildNotificationCard(
            left: 29,
            top: 605,
            title: '학과 공지사항이 등록되었습니다.',
            subtitle: '학과 공지사항을 확인해주세요!',
          ),
        ],
      ),
    );
  }

  // 알림 카드 위젯 생성 함수
  static Widget _buildNotificationCard({
    required double left,
    required double top,
    required String title,
    required String subtitle,
    double titleFontSize = 14,
    FontWeight titleFontWeight = FontWeight.w700,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 326,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFF7F8FD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 186,
                            child: Text(
                              title,
                              style: TextStyle(
                                color: const Color(0xFF1F2024),
                                fontSize: titleFontSize,
                                fontFamily: 'Inter',
                                fontWeight: titleFontWeight,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 186,
                            child: Text(
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
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8F9098),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
