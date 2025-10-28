import 'package:flutter/material.dart';
import 'notification_screen.dart';
import 'notice_screen.dart';
import 'main_screen.dart';
import '../../components/simple_calendar_bottom_sheet.dart';
import '../../components/student_council_events_section.dart';

/// YUconnect 홈화면 (새로운 디자인)
/// - 피그마 디자인을 기반으로 한 새로운 인터페이스
/// - 4개 탭 시스템: 공지사항, 학사일정, 총학생회 행사, 민원조회
class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => NewHomeScreenState();
}

class NewHomeScreenState extends State<NewHomeScreen> {
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
      builder: (context) => const SimpleCalendarBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildTabBar(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더 (로고 + 알림 아이콘)
  Widget _buildHeader() {
    return Container(
      width: 375,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 왼쪽: 로고
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/yu_logo.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          // 중앙: YUconnect 텍스트
          Expanded(
            child: Center(
              child: Text(
                'YUconnect',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF00387A),
                  fontSize: 32,
                  fontFamily: 'Balsamiq Sans',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.16,
                ),
              ),
            ),
          ),
          // 오른쪽: 알림 아이콘 (검색바 오른쪽 끝에 정확히 맞춤)
          Container(
            width: 60, // 너비를 60으로 더 늘려서 더 오른쪽으로
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 0), // 패딩을 0으로 줄여서 최대한 오른쪽으로
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              },
              child: SizedBox(
                width: 28,
                height: 28,
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF2563EB),
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 검색바
  Widget _buildSearchBar() {
    return Container(
      width: 343,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 343,
              height: 44,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1.5, color: const Color(0xFF7B61FF)),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 24,
                  color: Color(0xFF7B61FF).withOpacity(0.3),
                ),
                const SizedBox(width: 8),
                Text(
                  '검색...',
                  style: TextStyle(
                    color: const Color(0xFF7B61FF),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 탭바 (카테고리 선택)
  Widget _buildTabBar() {
    final tabTitles = ['공지사항', '학사일정', '총학생회 행사', '민원 조회'];
    final tabWidths = [90, 80, 100, 95]; // 크기 증가

    return Container(
      width: double.infinity,
      height: 70, // 높이 증가
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(tabTitles.length, (i) {
            final isSelected = _selectedTab == i;
            return Padding(
              padding: EdgeInsets.only(right: i < tabTitles.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: Container(
                  width: tabWidths[i].toDouble(),
                  height: 36, // 높이 증가
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ), // 패딩 증가
                  decoration: ShapeDecoration(
                    color: isSelected
                        ? const Color(0xFF006FFD)
                        : const Color(0xFFEAF2FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      tabTitles[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF006FFD),
                        fontSize: 13, // 폰트 크기 증가
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.55,
                      ),
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

  /// 메인 콘텐츠
  Widget _buildContent() {
    if (_selectedTab == 2) {
      // 총학생회 행사 탭인 경우 특별한 레이아웃
      return const StudentCouncilEventsSection();
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 16),
          _buildNoticeCards(),
          const SizedBox(height: 40),
          if (_selectedTab == 0) _buildCommunitySection(),
        ],
      ),
    );
  }

  /// 섹션 헤더 (제목 + 더보기)
  Widget _buildSectionHeader() {
    final sectionTitles = ['공지사항', '학사일정', '총학생회 행사', '민원 현황'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 22, right: 16), // 왼쪽을 22픽셀로 조금 줄임
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              sectionTitles[_selectedTab],
              style: TextStyle(
                color: const Color(0xFF1F2024),
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_selectedTab == 0) {
                // 공지사항 더보기
                final mainState = context
                    .findAncestorStateOfType<MainScreenState>();
                if (mainState != null) {
                  mainState.setTab(1, noticeTab: 0);
                }
              } else if (_selectedTab == 1) {
                // 학사일정 더보기 (캘린더)
                _showCalendarSheet();
              } else if (_selectedTab == 3) {
                // 민원조회 더보기
                final mainState = context
                    .findAncestorStateOfType<MainScreenState>();
                if (mainState != null) {
                  mainState.setTab(2); // 민원 탭으로 이동
                }
              }
            },
            child: Text(
              '더보기',
              style: TextStyle(
                color: const Color(0xFF006FFD),
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 공지사항 카드들
  Widget _buildNoticeCards() {
    switch (_selectedTab) {
      case 0: // 공지사항
        return _buildNoticeCardsForTab([
          {'title': '[SW중심대학사업단] 산학협력객원 교수 채용 공고', 'date': '2025.09.17'},
          {'title': '[연구원 채용]', 'date': '2025.09.17'},
        ]);
      case 1: // 학사일정
        return _buildNoticeCardsForTab([
          {'title': '2025년 2학기 기말고사 일정 안내', 'date': '2025.12.10'},
          {'title': '겨울방학 계절학기 수강신청', 'date': '2025.12.05'},
        ]);
      case 2: // 총학생회 행사
        return _buildNoticeCardsForTab([
          {'title': '영남대학교 축제 "유니버시아드" 개최', 'date': '2025.10.15'},
          {'title': '학과 대항 체육대회 안내', 'date': '2025.10.20'},
        ]);
      case 3: // 민원조회
        return _buildNoticeCardsForTab([
          {'title': '기숙사 시설 개선 요청', 'date': '2025.09.25', 'status': '처리중'},
          {'title': '도서관 이용시간 연장 건의', 'date': '2025.09.20', 'status': '완료'},
        ]);
      default:
        return Container();
    }
  }

  /// 탭별 공지사항 카드 생성
  Widget _buildNoticeCardsForTab(List<Map<String, String>> items) {
    return Container(
      width: double.infinity, // 화면 전체 너비 사용
      padding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 16픽셀 패딩
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              _buildNoticeCard(
                item['title'] ?? '',
                item['date'] ?? '',
                item['status'],
                75, // 높이를 86에서 75로 줄임
              ),
              if (!isLast) const SizedBox(height: 12),
            ],
          );
        }),
      ),
    );
  }

  /// 개별 공지사항 카드
  Widget _buildNoticeCard(
    String title,
    String date,
    String? status,
    double height,
  ) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF7F8FD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: IntrinsicHeight( // 내부 콘텐츠 높이에 맞춤
        child: Row(
          children: [
            Container(
              width: 56,
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: const Color(0xFF1F2024),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                color: const Color(0xFF71727A),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.12,
                              ),
                            ),
                            if (status != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: status == '완료'
                                      ? Colors.green
                                      : Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(
                      Icons.chevron_right,
                      color: Color(0xFFB0B5C3),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        ), // IntrinsicHeight 닫기
      ),
    );
  }

  /// 학과 커뮤니티 섹션 (공지사항 탭에서만 표시)
  Widget _buildCommunitySection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: 22,
            right: 16,
          ), // 왼쪽을 22픽셀로 조금 줄임
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '학과 커뮤니티',
                  style: TextStyle(
                    color: const Color(0xFF1F2024),
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // 학과 커뮤니티 더보기
                  final mainState = context
                      .findAncestorStateOfType<MainScreenState>();
                  if (mainState != null) {
                    mainState.setTab(1, noticeTab: 1);
                  }
                },
                child: Text(
                  '더보기',
                  style: TextStyle(
                    color: const Color(0xFF006FFD),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildNoticeCard('2026학년도 전공 교육과정...', '2025.09.17', null, 75),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
