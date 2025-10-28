import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/inquiry.dart';
import '../../repositories/inquiry_repository.dart';
import '../../components/inquiry_card.dart';
import '../../components/inquiry_search_bottom_sheet.dart';
import '../inquiry_register_screen.dart';

/// 영대민원 화면 - 등록된 민원/진행중/완료된 민원을 슬라이드 형식으로 관리
class YUInquiryScreen extends StatefulWidget {
  const YUInquiryScreen({super.key});

  @override
  State<YUInquiryScreen> createState() => _YUInquiryScreenState();
}

class _YUInquiryScreenState extends State<YUInquiryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  final InquiryRepository _inquiryRepository = InquiryRepository();
  User? _currentUser;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    _getCurrentUser();
    _checkAdminStatus();
    _fixExistingUserNames(); // 기존 이메일 형태 userName 수정
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// 현재 로그인된 사용자 정보 가져오기
  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  /// 관리자 권한 확인 (이메일 기반)
  void _checkAdminStatus() {
    if (_currentUser?.email?.contains('admin') ?? false) {
      setState(() {
        _isAdmin = true;
      });
    }
  }

  /// 탭 변경 시 PageView도 함께 변경
  void _onTabChanged(int index) {
    setState(() {}); // 탭바 UI 업데이트를 위해 추가
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// PageView 변경 시 탭도 함께 변경
  void _onPageChanged(int index) {
    _tabController.animateTo(index);
    setState(() {}); // 탭바 UI 업데이트를 위해 추가
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '영대민원',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF1F2024),
            fontSize: 22,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // 관리자 전환 버튼 추가
          IconButton(
            onPressed: () {
              setState(() {
                _isAdmin = !_isAdmin;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isAdmin ? '관리자 모드로 전환되었습니다' : '사용자 모드로 전환되었습니다',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _isAdmin ? Colors.orange : const Color(0xFF006FFD),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                _isAdmin ? Icons.admin_panel_settings : Icons.person,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCustomTabBar(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildPageContent('registered'), // 등록된 민원
                _buildPageContent('in_progress'), // 진행중 민원
                _buildPageContent('completed'), // 완료된 민원
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !_isAdmin
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 검색 버튼 (돋보기) - 사용자 모드에서만
                FloatingActionButton(
                  heroTag: "search",
                  onPressed: _showSearchBottomSheet, // 🔥 바텀시트 호출로 변경
                  backgroundColor: Colors.grey[600],
                  child: const Icon(Icons.search, color: Colors.white),
                ),
                const SizedBox(height: 16),
                // 추가 버튼 (+) - 사용자 모드에서만
                FloatingActionButton(
                  heroTag: "add",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InquiryRegisterScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            )
          : null,
    );
  }

  /// 커스텀 탭바 위젯 생성 (사용자 요청 디자인)
  Widget _buildCustomTabBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
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
                onTap: () => _onTabChanged(0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: ShapeDecoration(
                    color: _tabController.index == 0
                        ? (_isAdmin
                              ? const Color(0xFFFFE082)
                              : const Color(0xFFB4DBFF))
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadows: _tabController.index == 0
                        ? [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '등록된 민원',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _tabController.index == 0
                              ? const Color(0xFF1F2024)
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
                onTap: () => _onTabChanged(1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: ShapeDecoration(
                    color: _tabController.index == 1
                        ? (_isAdmin
                              ? const Color(0xFFFFE082)
                              : const Color(0xFFB4DBFF))
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadows: _tabController.index == 1
                        ? [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '진행중',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _tabController.index == 1
                              ? const Color(0xFF1F2024)
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
                onTap: () => _onTabChanged(2),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: ShapeDecoration(
                    color: _tabController.index == 2
                        ? (_isAdmin
                              ? const Color(0xFFFFE082)
                              : const Color(0xFFB4DBFF))
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadows: _tabController.index == 2
                        ? [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '답변 완료',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _tabController.index == 2
                              ? const Color(0xFF1F2024)
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
    );
  }

  /// 페이지 컨텐츠 생성 (상태별 민원 목록)
  Widget _buildPageContent(String status) {
    return StreamBuilder<List<Inquiry>>(
      stream: _isAdmin
          ? _inquiryRepository.getAllInquiries()
          : _inquiryRepository.getCurrentUserInquiries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                _isAdmin ? Colors.orange : Colors.blue,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          print('Error loading inquiries: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  '데이터를 불러오는 중 오류가 발생했습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(fontSize: 12, color: Colors.red[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final allInquiries = snapshot.data ?? [];
        final inquiries = allInquiries.where((inquiry) {
          switch (status) {
            case 'registered':
              return inquiry.status == InquiryStatus.registered;
            case 'in_progress':
              return inquiry.status == InquiryStatus.inProgress;
            case 'completed':
              return inquiry.status == InquiryStatus.completed;
            default:
              return true;
          }
        }).toList();

        if (inquiries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(status),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: inquiries.length,
          itemBuilder: (context, index) {
            final inquiry = inquiries[index];
            return InquiryCard(inquiry: inquiry, isAdmin: _isAdmin);
          },
        );
      },
    );
  }

  /// 상태별 빈 목록 메시지
  String _getEmptyMessage(String status) {
    switch (status) {
      case 'registered':
        return '등록된 민원이 없습니다.';
      case 'in_progress':
        return '진행중인 민원이 없습니다.';
      case 'completed':
        return '완료된 민원이 없습니다.';
      default:
        return '민원이 없습니다.';
    }
  }

  /// 기존 이메일 형태 userName 수정 (앱 시작 시 한 번만 실행)
  void _fixExistingUserNames() async {
    try {
      await _inquiryRepository.fixEmailUserNames();
    } catch (e) {
      print('Error fixing existing usernames: $e');
    }
  }

  /// 검색 바텀시트 표시
  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InquirySearchBottomSheet(),
    );
  }
}
