import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../inquiry/inquiry_registration_screen.dart';
import '../inquiry/inquiry_detail_screen.dart';
import 'notification_screen.dart';
import '../../models/inquiry.dart';
import '../../repositories/inquiry_repository.dart';

/// 영대민원 화면 - 깔끔한 새 디자인
class YUInquiryScreen extends StatefulWidget {
  const YUInquiryScreen({super.key});

  @override
  State<YUInquiryScreen> createState() => _YUInquiryScreenState();
}

class _YUInquiryScreenState extends State<YUInquiryScreen> {
  final InquiryRepository _inquiryRepository = InquiryRepository();
  int _selectedTabIndex = 0;
  bool _isAdminMode = false;

  final List<String> _tabTitles = ['등록됨', '진행중', '완료'];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  /// 관리자 권한 확인
  void _checkAdminStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isAdminMode =
            user.email == 'admin@yu.ac.kr' || user.email == 'admin@test.com';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 탭 바 (사용자 모드에서만)
          if (!_isAdminMode) _buildTabBar(),

          // 컨텐츠
          Expanded(child: _isAdminMode ? _buildAdminView() : _buildUserView()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// 앱바 생성
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        '영대민원',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        // 알림 아이콘
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
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
    );
  }

  /// 탭바 생성 (사용자 모드)
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(_tabTitles.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFB4DBFF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          const BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _tabTitles[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.black : const Color(0xFF71727A),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 관리자 뷰
  Widget _buildAdminView() {
    return StreamBuilder<List<Inquiry>>(
      stream: _inquiryRepository.getAllInquiries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }

        final inquiries = snapshot.data ?? [];

        if (inquiries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '등록된 민원이 없습니다',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: inquiries.length,
          itemBuilder: (context, index) {
            return _buildAdminInquiryCard(inquiries[index]);
          },
        );
      },
    );
  }

  /// 사용자 뷰
  Widget _buildUserView() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('로그인이 필요합니다'));
    }

    // 선택된 탭에 따른 상태
    InquiryStatus targetStatus;
    switch (_selectedTabIndex) {
      case 0:
        targetStatus = InquiryStatus.registered;
        break;
      case 1:
        targetStatus = InquiryStatus.inProgress;
        break;
      case 2:
        targetStatus = InquiryStatus.completed;
        break;
      default:
        targetStatus = InquiryStatus.registered;
    }

    return StreamBuilder<List<Inquiry>>(
      stream: _inquiryRepository.getInquiriesByUserId(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }

        final allInquiries = snapshot.data ?? [];
        final filteredInquiries = allInquiries
            .where((inquiry) => inquiry.status == targetStatus)
            .toList();

        if (filteredInquiries.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                    decoration: const BoxDecoration(color: Color(0xFFB3DAFF)),
                    child: const Icon(
                      Icons.inbox_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Column(
                  children: [
                    Text(
                      '아무것도 등록되지 않았습니다',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1F2024),
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.09,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_tabTitles[_selectedTabIndex]} 민원을 볼 수 있습니다.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                ElevatedButton(
                  onPressed: _navigateToRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006FFD),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '민원 등록',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredInquiries.length,
          itemBuilder: (context, index) {
            return _buildUserInquiryCard(filteredInquiries[index]);
          },
        );
      },
    );
  }

  /// 관리자용 민원 카드
  Widget _buildAdminInquiryCard(Inquiry inquiry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(inquiry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (상태, 카테고리, 날짜)
              Row(
                children: [
                  _buildStatusChip(inquiry.status),
                  const SizedBox(width: 8),
                  _buildCategoryChip(inquiry.category),
                  const Spacer(),
                  Text(
                    _formatDate(inquiry.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 작성자
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    inquiry.userName,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 내용
              Text(
                inquiry.content,
                style: const TextStyle(fontSize: 15, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 사용자용 민원 카드
  Widget _buildUserInquiryCard(Inquiry inquiry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(inquiry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  _buildCategoryChip(inquiry.category),
                  const Spacer(),
                  Text(
                    _formatSimpleDate(inquiry.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 내용
              Text(
                inquiry.content,
                style: const TextStyle(fontSize: 15, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 상태 칩
  Widget _buildStatusChip(InquiryStatus status) {
    Color chipColor;
    switch (status) {
      case InquiryStatus.registered:
        chipColor = Colors.blue;
        break;
      case InquiryStatus.inProgress:
        chipColor = Colors.orange;
        break;
      case InquiryStatus.completed:
        chipColor = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 카테고리 칩
  Widget _buildCategoryChip(InquiryCategory category) {
    Color chipColor;
    switch (category) {
      case InquiryCategory.academic:
        chipColor = Colors.purple.shade100;
        break;
      case InquiryCategory.facility:
        chipColor = Colors.green.shade100;
        break;
      case InquiryCategory.living:
        chipColor = Colors.blue.shade100;
        break;
      case InquiryCategory.other:
        chipColor = Colors.grey.shade200;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category.displayName,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 플로팅 액션 버튼
  Widget? _buildFloatingActionButton() {
    if (_isAdminMode) return null;

    return Container(
      width: 59,
      height: 59,
      decoration: BoxDecoration(
        color: const Color(0xFF006FFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1, color: const Color(0xFF0078D4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _navigateToRegistration,
          child: const Center(
            child: Icon(Icons.add, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  /// 민원 등록 화면으로 이동
  void _navigateToRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InquiryRegistrationScreen(),
      ),
    );
  }

  /// 민원 상세 화면으로 이동
  void _navigateToDetail(Inquiry inquiry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InquiryDetailScreen(inquiry: inquiry),
      ),
    );
  }

  /// 날짜 포맷 (전체)
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 날짜 포맷 (간단)
  String _formatSimpleDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}.${date.day}';
    }
  }
}
