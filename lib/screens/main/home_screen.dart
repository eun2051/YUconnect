import 'package:flutter/material.dart';
import 'notification_screen.dart';
import 'notice_screen.dart'; // NoticeScreen import 추가
import '../../components/line_rounded_bell.dart';
import 'main_screen.dart'; // MainScreen import 경로 수정

/// YUconnect 홈화면 (공지사항/학사일정/총학생회 행사/민원조회)
/// - 상단 탭 전환, 하단 네비게이터 연동, 각 섹션별 화면 제공
/// - 더보기/학과 커뮤니티 더보기/민원 더보기/캘린더 바텀시트 등 동작 구현
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
      builder: (context) => SizedBox(
        height: 400,
        child: Center(child: Text('캘린더 바텀시트 (학사일정 상세)')),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
        // TODO: 학사일정 리스트 위젯 연결
      ],
    );
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
                // TODO: MainScreen에서 민원 탭으로 이동하도록 구현 필요
              },
              child: const Text(
                '더보기',
                style: TextStyle(color: Color(0xFF006FFD)),
              ),
            ),
          ],
        ),
        // TODO: 민원 현황 리스트 위젯 연결
      ],
    );
  }
}
