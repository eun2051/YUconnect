import 'package:flutter/material.dart';
import '../screens/student_council/event_registration_screen.dart';

/// 총학생회 행사 섹션 위젯
class StudentCouncilEventsSection extends StatelessWidget {
  const StudentCouncilEventsSection({super.key});

  void _navigateToEventRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventRegistrationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 8),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총학생회 행사',
                      style: TextStyle(
                        color: Color(0xFF1F2024),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '더보기',
                      style: TextStyle(
                        color: Color(0xFF006FFD),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 행사 카드들 (가로 스크롤)
              SizedBox(
                height: 250,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildEventCard(
                      title: '들풀제',
                      location: '영남대학교 천연잔디구장',
                      date: '09.30 - 10.01',
                      buttonText: '신청하기',
                    ),
                    const SizedBox(width: 12),
                    _buildEventCard(
                      title: '플리마켓 신청',
                      location: '들풀제 플리마켓',
                      date: 'JUL 04',
                      buttonText: '신청하기',
                    ),
                    const SizedBox(width: 12),
                    _buildEventCard(
                      title: '학과 체육대회',
                      location: '영남대학교 체육관',
                      date: 'NOV 15',
                      buttonText: '신청하기',
                    ),
                    const SizedBox(width: 12),
                    _buildEventCard(
                      title: '겨울 축제',
                      location: '중앙광장',
                      date: 'DEC 20',
                      buttonText: '신청하기',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 총학생회 행사 등록하기 섹션
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 8),
                child: const Text(
                  '총학생회 행사 등록하기',
                  style: TextStyle(
                    color: Color(0xFF1F2024),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 새 행사 등록 버튼
              Center(
                child: GestureDetector(
                  onTap: () => _navigateToEventRegistration(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFEAF2FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF006FFD),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '새 행사 등록',
                          style: TextStyle(
                            color: Color(0xFF006FFD),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard({
    required String title,
    required String location,
    required String date,
    required String buttonText,
  }) {
    return Container(
      width: 250,
      decoration: ShapeDecoration(
        color: const Color(0xFFF7F8FD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 이미지 영역
          Container(
            width: double.infinity,
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF2FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                // 중앙 아이콘
                const Center(
                  child: Icon(Icons.event, color: Color(0xFFB3DAFF), size: 32),
                ),
                // 우상단 날짜 태그
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF006FFD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 하단 정보 영역
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목과 장소
                Column(
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
                      location,
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
                const SizedBox(height: 16),

                // 신청 버튼
                Container(
                  width: double.infinity,
                  height: 40,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1.50,
                        color: Color(0xFF006FFD),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Color(0xFF006FFD),
                        fontSize: 12,
                        fontFamily: 'Inter',
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
    );
  }
}
