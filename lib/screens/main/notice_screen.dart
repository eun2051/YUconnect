import 'package:flutter/material.dart';

/// 공지사항/학과 커뮤니티 전체보기 화면
class NoticeScreen extends StatefulWidget {
  final int initialTab;
  const NoticeScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  NoticeScreenState createState() => NoticeScreenState();
}

class NoticeScreenState extends State<NoticeScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedTab;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _pageController = PageController(initialPage: _selectedTab);
  }

  void setTab(int index) {
    setState(() {
      _selectedTab = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    setState(() => _selectedTab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 72), // 기존 56 -> 72로 증가
          // 그룹: 타이틀 + 검색 + pill 탭
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        '공지사항',
                        style: TextStyle(
                          color: Color(0xFF23272F),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFF2563EB),
                            width: 2,
                          ),
                          color: Colors.white,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.search,
                            color: Color(0xFF2563EB),
                            size: 22,
                          ),
                          onPressed: () {},
                          splashRadius: 20,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // pill 탭바 (크기 축소, 시안 비율)
              Center(
                child: Container(
                  width: screenWidth - 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFFF7F8FD),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onTabTap(0),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.ease,
                            margin: EdgeInsets.only(left: 6, right: 3),
                            height: 38,
                            decoration: _selectedTab == 0
                                ? BoxDecoration(
                                    color: Color(0xFFB4DBFF),
                                    borderRadius: BorderRadius.circular(19),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x22000000),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  )
                                : null,
                            child: Center(
                              child: Text(
                                '공지사항',
                                style: TextStyle(
                                  color: _selectedTab == 0
                                      ? Colors.black
                                      : Color(0xFFB0B5C3),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onTabTap(1),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.ease,
                            margin: EdgeInsets.only(left: 3, right: 6),
                            height: 38,
                            decoration: _selectedTab == 1
                                ? BoxDecoration(
                                    color: Color(0xFFB4DBFF),
                                    borderRadius: BorderRadius.circular(19),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x22000000),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  )
                                : null,
                            child: Center(
                              child: Text(
                                '학과 커뮤니티',
                                style: TextStyle(
                                  color: _selectedTab == 1
                                      ? Colors.black
                                      : Color(0xFFB0B5C3),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Inter',
                                ),
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
          const SizedBox(height: 8), // 기존 16 -> 8로 간격 축소
          // 아래 컨텐츠는 Expanded로 감싸 overflow 방지
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _selectedTab = index);
              },
              children: [_buildNoticeList(), _buildCommunityList()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _noticeItem('[SW중심대학사업단] 산학협력객원 교수 채용 공고', '2025.09.17', badge: '9'),
        _noticeItem('[연구원 채용]', '2025.09.17'),
      ],
    );
  }

  Widget _buildCommunityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_noticeItem('2026학년도 전공 교육과정...', '2025.09.17', badge: '9')],
    );
  }

  Widget _noticeItem(String title, String date, {String? badge}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
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
                  date,
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
          if (badge != null)
            Container(
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF006FFD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
