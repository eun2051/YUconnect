import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_screen.dart';
import 'notice_screen.dart'; // NoticeScreen import 추가
import '../../components/line_rounded_bell.dart';
import '../../components/inquiry_card.dart';
import '../../components/academic_calendar_bottom_sheet.dart';
import '../../models/inquiry.dart';
import '../../models/academic_event.dart';
import '../../repositories/inquiry_repository.dart';
import '../../repositories/academic_event_repository.dart';
import 'main_screen.dart'; // MainScreen import 경로 수정

/// YUconnect 홈화면 (공지사항/학사일정/총학생회 행사/민원조회)
/// - 상단 탭 전환, 하단 네비게이터 연동, 각 섹션별 화면 제공
/// - 더보기/학과 커뮤니티 더보기/민원 더보기/캘린더 바텀시트 등 동작 구현
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // 0: 공지사항, 1: 학사일정, 2: 총학생회 행사, 3: 민원조회
  int _selectedTab = 0;

  // 외부에서 탭을 강제로 변경할 수 있도록 메서드 추가
  void setTab(int index, {int? noticeTab}) {
    setState(() {
      _selectedTab = index;
    });
    // 추가: noticeTab이 전달된 경우, NoticeScreen의 탭도 변경
    if (noticeTab != null) {
      final noticeState = context.findAncestorStateOfType<NoticeScreenState>();
      noticeState?.setTab(noticeTab);
    }
  }

  void _showCalendarSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AcademicCalendarBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(child: _buildSection()),
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomNav(), // 하단 네비게이터 제거
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/yu_logo.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Text(
            'YUconnect',
            style: const TextStyle(
              color: Color(0xFF00387A),
              fontSize: 32,
              fontFamily: 'Balsamiq Sans',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.16,
            ),
          ),
          const Spacer(),
          // 알림 버튼 추가
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF2563EB),
              size: 32,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
            tooltip: '알림',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFF7B61FF), width: 1.5),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search,
              size: 24,
              color: Color(0xFF7B61FF).withOpacity(0.3),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                '검색...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7B61FF),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabTitles = ['공지사항', '학사일정', '총학생회 행사', '민원 조회'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabTitles.length, (i) {
            final isSelected = _selectedTab == i;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF3B5BFE) : Color(0xFFF2F6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tabTitles[i],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Color(0xFF3B5BFE),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSection() {
    switch (_selectedTab) {
      case 0:
        return _buildNoticeSection();
      case 1:
        return _buildScheduleSection();
      case 2:
        return _buildEventSection();
      case 3:
        return _buildInquirySection();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildNoticeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '공지사항',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xFF23272F),
                ),
              ),
              TextButton(
                onPressed: () {
                  // MainScreen의 영대공지 탭(1번)으로 이동 (네비게이터 push X, 상태만 변경)
                  final mainState = context
                      .findAncestorStateOfType<MainScreenState>();
                  if (mainState != null) {
                    mainState.setTab(1, noticeTab: 0); // 공지사항 탭
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '더보기',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _noticeCard('[SW중심대학사업단] 산학협력객원 교수 채용 공고', '2025.09.17'),
        const SizedBox(height: 12),
        _noticeCard('[연구원 채용]', '2025.09.17'),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '학과 커뮤니티',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xFF23272F),
                ),
              ),
              TextButton(
                onPressed: () {
                  // MainScreen의 영대공지 탭(1번) + 학과 커뮤니티 탭으로 이동
                  final mainState = context
                      .findAncestorStateOfType<MainScreenState>();
                  if (mainState != null) {
                    mainState.setTab(1, noticeTab: 1); // 학과 커뮤니티 탭
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '더보기',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _noticeCard('2026학년도 전공 교육과정...', '2025.09.17'),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _noticeCard(String title, String date) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0FE),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
            child: const Center(
              child: Icon(Icons.link, color: Color(0xFF7BAAF7), size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF23272F),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: const TextStyle(
                      color: Color(0xFFB0B5C3),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.chevron_right,
              color: Color(0xFFB0B5C3),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    final eventRepository = AcademicEventRepository();
    final now = DateTime.now();
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '학사일정',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton(
              onPressed: _showCalendarSheet,
              child: const Text(
                '더보기',
                style: TextStyle(color: Color(0xFF006FFD)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<AcademicEvent>>(
          stream: eventRepository.getEventsByDateRange(
            now,
            now.add(const Duration(days: 30)), // 다음 30일
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 100,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF006FFD),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '데이터를 불러오는 중 오류가 발생했습니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final events = snapshot.data ?? [];
            
            if (events.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '예정된 학사일정이 없습니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            // 최근 3개만 표시
            final recentEvents = events.take(3).toList();
            
            return Column(
              children: recentEvents.map((event) {
                return _buildEventCard(event);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// 학사일정 카드 위젯
  Widget _buildEventCard(AcademicEvent event) {
    Color eventColor = _getEventCategoryColor(event.category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: eventColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: eventColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: eventColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.category.displayName,
                        style: TextStyle(
                          color: eventColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatEventDate(event),
                      style: const TextStyle(
                        color: Color(0xFF71727A),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Color(0xFF1F2024),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (event.description != null && event.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.description!,
                    style: const TextStyle(
                      color: Color(0xFF71727A),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 이벤트 카테고리별 색상
  Color _getEventCategoryColor(AcademicEventCategory category) {
    switch (category) {
      case AcademicEventCategory.regular:
        return const Color(0xFF006FFD);
      case AcademicEventCategory.exam:
        return const Color(0xFFFF6B35);
      case AcademicEventCategory.holiday:
        return const Color(0xFF10B981);
      case AcademicEventCategory.registration:
        return const Color(0xFF8B5CF6);
      case AcademicEventCategory.special:
        return const Color(0xFFF59E0B);
    }
  }

  /// 이벤트 날짜 포맷팅
  String _formatEventDate(AcademicEvent event) {
    final startDate = event.startDate;
    if (event.endDate == null) {
      return '${startDate.month}/${startDate.day}';
    } else {
      final endDate = event.endDate!;
      if (startDate.month == endDate.month) {
        return '${startDate.month}/${startDate.day}-${endDate.day}';
      } else {
        return '${startDate.month}/${startDate.day}-${endDate.month}/${endDate.day}';
      }
    }
  }

  Widget _buildEventSection() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '총학생회 행사',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                '더보기',
                style: TextStyle(color: Color(0xFF006FFD)),
              ),
            ),
          ],
        ),
        // TODO: 총학생회 행사 리스트 위젯 연결
      ],
    );
  }

  Widget _buildInquirySection() {
    final user = FirebaseAuth.instance.currentUser;
    final inquiryRepository = InquiryRepository();
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '나의 민원 현황',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton(
              onPressed: () {
                // MainScreen에서 민원 탭(index 2)으로 이동
                final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                mainScreenState?.setTab(2);
              },
              child: const Text(
                '더보기',
                style: TextStyle(color: Color(0xFF006FFD)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (user == null)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  '로그인이 필요합니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          StreamBuilder<List<Inquiry>>(
            stream: inquiryRepository.getCurrentUserInquiries(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 100,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF006FFD),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '데이터를 불러오는 중 오류가 발생했습니다',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final inquiries = snapshot.data ?? [];
              
              if (inquiries.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '등록된 민원이 없습니다',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 최근 3개만 표시
              final recentInquiries = inquiries.take(3).toList();
              
              return Column(
                children: recentInquiries.map((inquiry) {
                  return InquiryCard(
                    inquiry: inquiry,
                    isAdmin: false,
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}
