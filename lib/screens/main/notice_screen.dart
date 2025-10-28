import 'package:flutter/material.dart';
import 'notification_screen.dart';
import '../../models/notice.dart';
import '../../repositories/notice_repository.dart';
import '../notices/notice_detail_screen.dart';

/// 공지사항/학과 커뮤니티 전체보기 화면
class NoticeScreen extends StatefulWidget {
  final int initialTab;
  const NoticeScreen({super.key, this.initialTab = 0});

  @override
  NoticeScreenState createState() => NoticeScreenState();
}

class NoticeScreenState extends State<NoticeScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedTab;
  late final PageController _pageController;
  final NoticeRepository _noticeRepository = NoticeRepository();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _pageController = PageController(initialPage: _selectedTab);
    _initializeData();
  }

  /// 초기 데이터 로드
  Future<void> _initializeData() async {
    if (_hasInitialized) return;

    try {
      // 기존 공지사항 데이터 확인
      final notices = await _noticeRepository.getNotices(limit: 1).first;

      // 데이터가 없으면 영남대학교 샘플 데이터 자동 추가
      if (notices.isEmpty) {
        await _noticeRepository.addYeungnamUniversitySampleData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('영남대학교 공지사항 샘플 데이터가 자동으로 추가되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      _hasInitialized = true;
    } catch (e) {
      print('공지사항 데이터 초기화 오류: $e');
    }
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

  Widget _buildContentSwitcher() {
    return Column(
      children: [
        Container(
          width: 343,
          padding: const EdgeInsets.all(4),
          decoration: ShapeDecoration(
            color: const Color(0xFFF7F8FD),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _onTabTap(0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: ShapeDecoration(
                      color: _selectedTab == 0
                          ? const Color(0xFFB4DBFF)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadows: _selectedTab == 0
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '공지사항',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 0
                                ? Colors.black
                                : const Color(0xFF71727A),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _onTabTap(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: ShapeDecoration(
                      color: _selectedTab == 1
                          ? const Color(0xFFB4DBFF)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadows: _selectedTab == 1
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '학과 커뮤니티',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 1
                                ? Colors.black
                                : const Color(0xFF71727A),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 72),
          // 그룹: 타이틀 + 검색 + 새로운 탭
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
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
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationScreen(),
                            ),
                          );
                        },
                        child: const SizedBox(
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
              ),
              const SizedBox(height: 24),
              // 새로운 컨텐츠 스위처
              _buildContentSwitcher(),
            ],
          ),
          const SizedBox(height: 20),
          // 페이지뷰 컨텐츠
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 샘플 데이터 추가 버튼 (개발/테스트용)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: _addSampleData,
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 16,
              ),
              label: const Text(
                '영남대 공지사항 샘플 데이터 추가',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006FFD),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // 실제 공지사항 목록 (영남대학교 공식 소식)
          Expanded(
            child: StreamBuilder<List<Notice>>(
              stream: _noticeRepository.getUniversityNotices(limit: 10),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF006FFD)),
                        SizedBox(height: 16),
                        Text(
                          '영남대학교 공지사항을 불러오는 중...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF71727A),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '오류가 발생했습니다\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final notices = snapshot.data ?? [];

                if (notices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.announcement_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '등록된 공지사항이 없습니다',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '위의 버튼을 눌러 샘플 데이터를 추가해보세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: notices.length,
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    return _noticeItemFromData(notice);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 샘플 데이터 추가
  Future<void> _addSampleData() async {
    try {
      await _noticeRepository.addYeungnamUniversitySampleData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('영남대학교 공지사항 샘플 데이터가 추가되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildCommunityList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 학과 공지사항 목록
          Expanded(
            child: StreamBuilder<List<Notice>>(
              stream: _noticeRepository.getDepartmentNotices(limit: 10),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF006FFD)),
                        SizedBox(height: 16),
                        Text(
                          '학과 공지사항을 불러오는 중...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF71727A),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '오류가 발생했습니다\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final notices = snapshot.data ?? [];

                if (notices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '학과 공지사항이 없습니다',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '샘플 데이터를 추가하면 학과 공지를 확인할 수 있습니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: notices.length,
                  itemBuilder: (context, index) {
                    return _noticeItemFromData(notices[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 실제 Notice 데이터를 사용하는 공지사항 아이템
  Widget _noticeItemFromData(Notice notice) {
    final formattedDate =
        '${notice.publishDate.year}.${notice.publishDate.month.toString().padLeft(2, '0')}.${notice.publishDate.day.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoticeDetailScreen(notice: notice),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notice.isImportant
                ? const Color(0xFF006FFD).withOpacity(0.3)
                : const Color(0xFFF0F0F0),
            width: notice.isImportant ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 카테고리 태그
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(notice.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notice.category,
                    style: TextStyle(
                      color: _getCategoryColor(notice.category),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (notice.isImportant) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '중요',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                // 조회수 표시
                if (notice.viewCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006FFD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      notice.viewCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notice.title,
              style: const TextStyle(
                color: Color(0xFF1F2024),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  notice.department,
                  style: const TextStyle(
                    color: Color(0xFF006FFD),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
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
          ],
        ),
      ),
    );
  }

  /// 카테고리별 색상 반환
  Color _getCategoryColor(String category) {
    switch (category) {
      case '영대소식':
        return const Color(0xFF2563EB); // 진한 파란색
      case '영대정보':
        return const Color(0xFF059669); // 녹색
      case '채용':
        return const Color(0xFF006FFD);
      case '장학':
        return const Color(0xFF10B981);
      case '학사':
        return const Color(0xFF8B5CF6);
      case '시설':
        return const Color(0xFFF59E0B);
      case '학과':
        return const Color(0xFFFF6B35);
      default:
        return const Color(0xFF71727A);
    }
  }
}
