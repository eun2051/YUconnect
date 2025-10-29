import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../inquiry/inquiry_registration_screen.dart';
import '../inquiry/inquiry_detail_screen.dart';
import '../../models/inquiry.dart';
import '../../repositories/inquiry_repository.dart';
import '../../repositories/user_repository.dart';

/// 민원 시스템 메인 화면
/// 등록된 민원, 진행 중, 답변 완료 탭으로 구성
class InquiryScreen extends StatefulWidget {
  const InquiryScreen({super.key});

  @override
  State<InquiryScreen> createState() => _InquiryScreenState();
}

class _InquiryScreenState extends State<InquiryScreen>
    with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  final List<String> _tabTitles = ['등록된 민원', '진행 중', '답변 완료'];
  final _inquiryRepository = InquiryRepository();

  late PageController _pageController;
  late AnimationController _tabAnimationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 고정된 AppBar 영역
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.white),
            child: SafeArea(
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    // 중앙에 위치한 영대민원 텍스트 (아래쪽 정렬)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: const Text(
                          '영대민원',
                          style: TextStyle(
                            color: Color(0xFF1F2024),
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // 오른쪽 상단의 알림 아이콘
                    Positioned(
                      right: 14,
                      top: 0,
                      bottom: 0,
                      child: Icon(
                        Icons.notifications_outlined,
                        color: const Color(0xFF006FFD),
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 탭 스위처
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildTabSwitcher(),
          ),
          // 컨텐츠 영역
          Expanded(child: _buildContent()),
        ],
      ),
      // 플로팅 액션 버튼
      floatingActionButton: Container(
        width: 59,
        height: 59,
        decoration: BoxDecoration(
          color: const Color(0xFF006FFD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1, color: const Color(0xFF0078D4)),
        ),
        child: IconButton(
          onPressed: () {
            // TODO: 민원 등록 페이지로 이동
            _navigateToRegisterInquiry();
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  /// 3개 탭이 있는 스위처 위젯 (애니메이션 포함)
  Widget _buildTabSwitcher() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // 배경 선택 인디케이터 (애니메이션)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left:
                (_currentTabIndex *
                (MediaQuery.of(context).size.width - 32 - 12) /
                3),
            top: 0,
            bottom: 0,
            child: Container(
              width: (MediaQuery.of(context).size.width - 32 - 12) / 3,
              decoration: BoxDecoration(
                color: const Color(0xFFB4DBFF),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
          // 탭 텍스트들
          Row(
            children: List.generate(3, (index) {
              final isSelected = _currentTabIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentTabIndex = index;
                    });
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(
                      _tabTitles[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.black
                            : const Color(0xFF71727A),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 현재 선택된 탭에 따른 컨텐츠 (PageView 사용)
  Widget _buildContent() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text(
          '로그인이 필요합니다',
          style: TextStyle(
            color: Color(0xFF71727A),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentTabIndex = index;
        });
      },
      children: [
        // 등록된 민원 탭
        _buildInquiryList(InquiryStatus.registered),
        // 진행 중 탭
        _buildInquiryList(InquiryStatus.inProgress),
        // 답변 완료 탭
        _buildInquiryList(InquiryStatus.completed),
      ],
    );
  }

  /// 특정 상태의 민원 목록을 표시하는 위젯
  Widget _buildInquiryList(InquiryStatus status) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text(
          '로그인이 필요합니다',
          style: TextStyle(
            color: Color(0xFF71727A),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // 모든 데이터를 가져와서 클라이언트에서 필터링 (인덱스 문제 해결)
    return StreamBuilder<List<Inquiry>>(
      stream: _inquiryRepository.getInquiriesByUserId(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final allInquiries = snapshot.data ?? [];

        // 전달받은 상태에 따라 필터링
        final filteredInquiries = allInquiries
            .where((inquiry) => inquiry.status == status)
            .toList();

        // 디버깅을 위한 로그 추가
        print(
          '📊 상태 ${status.value} - 전체: ${allInquiries.length}, 필터링됨: ${filteredInquiries.length}',
        );
        for (int i = 0; i < allInquiries.length; i++) {
          final inquiry = allInquiries[i];
          print(
            '민원 $i: ${inquiry.content} - 상태: ${inquiry.status.value} - 답변: ${inquiry.adminResponse != null ? "있음" : "없음"}',
          );
        }

        if (filteredInquiries.isEmpty) {
          return _buildEmptyState();
        }

        return _buildInquiryListView(filteredInquiries);
      },
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘 컨테이너
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFB3DAFF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF006FFD),
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 텍스트 영역
          Column(
            children: [
              const Text(
                '아무것도 등록되지 않았습니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1F2024),
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.09,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '민원을 등록해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF71727A),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // 민원 등록 버튼
          GestureDetector(
            onTap: _navigateToRegisterInquiry,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF006FFD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '민원 등록',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
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

  /// 민원 등록 페이지로 이동
  void _navigateToRegisterInquiry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InquiryRegistrationScreen(),
      ),
    );
  }

  /// 에러 상태 UI
  Widget _buildErrorState(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            '오류가 발생했습니다',
            style: const TextStyle(
              color: Color(0xFF1F2024),
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF71727A),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// 민원 리스트 UI
  Widget _buildInquiryListView(List<Inquiry> inquiries) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: inquiries.length,
      itemBuilder: (context, index) {
        final inquiry = inquiries[index];
        return _buildInquiryCard(inquiry);
      },
    );
  }

  /// 민원 카드 UI
  Widget _buildInquiryCard(Inquiry inquiry) {
    return _InquiryCard(inquiry: inquiry);
  }
}

/// 확장 가능한 민원 카드 위젯
class _InquiryCard extends StatefulWidget {
  final Inquiry inquiry;

  const _InquiryCard({required this.inquiry});

  @override
  State<_InquiryCard> createState() => _InquiryCardState();
}

class _InquiryCardState extends State<_InquiryCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  final _userRepository = UserRepository();
  String _authorName = ''; // 작성자 이름

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadAuthorName(); // 작성자 이름 로드
  }

  /// 작성자 이름 로드
  Future<void> _loadAuthorName() async {
    try {
      final user = await _userRepository.getUserByUid(widget.inquiry.userId);
      if (user != null && mounted) {
        setState(() {
          _authorName = user.name;
        });
      }
    } catch (e) {
      // 오류 발생 시 기본값 유지
      if (mounted) {
        setState(() {
          _authorName = '알 수 없음';
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (widget.inquiry.status) {
      case InquiryStatus.registered:
        statusColor = const Color(0xFF006FFD);
        statusText = '등록됨';
        break;
      case InquiryStatus.inProgress:
        statusColor = const Color(0xFFFF9500);
        statusText = '진행 중';
        break;
      case InquiryStatus.completed:
        statusColor = const Color(0xFF34C759);
        statusText = '답변 완료';
        break;
    }

    // 답변이 있는지 확인
    bool hasResponse =
        widget.inquiry.adminResponse != null &&
        widget.inquiry.adminResponse!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // 답변이 있는 경우 슬라이딩 애니메이션으로 답변 표시
          if (hasResponse) ...[
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: const Color(0xFFB4DBFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    // 답변 헤더
                    Container(
                      width: double.infinity,
                      height: 69,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFEAF2FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, top: 20),
                        child: Text(
                          widget.inquiry.category.displayName,
                          style: const TextStyle(
                            color: Color(0xFF1F2024),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),
                      ),
                    ),
                    // 답변 날짜와 내용
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 10,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatResponseDate(widget.inquiry.responseAt!),
                            style: const TextStyle(
                              color: Color(0xFF71727A),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.33,
                              letterSpacing: 0.12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.inquiry.adminResponse!,
                            style: const TextStyle(
                              color: Color(0xFF2D2D2D),
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
                  ],
                ),
              ),
            ),
          ],
          // 원본 민원 카드
          GestureDetector(
            onTap: () {
              if (hasResponse) {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
                // 애니메이션 트리거
                if (_isExpanded) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InquiryDetailScreen(inquiry: widget.inquiry),
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 0.50, color: Color(0xFFC5C6CC)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 카테고리와 상태
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.inquiry.category.displayName,
                                  style: const TextStyle(
                                    color: Color(0xFF1F2024),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.43,
                                  ),
                                ),
                                if (_authorName.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '작성자: $_authorName',
                                    style: const TextStyle(
                                      color: Color(0xFF71727A),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.33,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // 날짜
                        Text(
                          _formatDate(widget.inquiry.createdAt),
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
                  // 답변이 있는 경우 화살표 표시
                  if (hasResponse) ...[
                    const SizedBox(width: 8),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF71727A),
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 답변 날짜 포맷팅
  String _formatResponseDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  /// 일반 날짜 포맷팅
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
