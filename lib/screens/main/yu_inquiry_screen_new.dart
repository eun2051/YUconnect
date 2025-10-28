import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../inquiry/inquiry_registration_screen.dart';
import '../inquiry/inquiry_detail_screen.dart';
import '../../models/inquiry.dart';
import '../../repositories/inquiry_repository.dart';
import '../../components/expandable_inquiry_card.dart';
import '../../components/inquiry_search_bottom_sheet.dart';
import '../../utils/dummy_data_helper.dart';

/// 영대민원 화면 - 슬라이딩 애니메이션 지원
class YUInquiryScreen extends StatefulWidget {
  const YUInquiryScreen({super.key});

  @override
  State<YUInquiryScreen> createState() => _YUInquiryScreenState();
}

class _YUInquiryScreenState extends State<YUInquiryScreen>
    with SingleTickerProviderStateMixin {
  final InquiryRepository _inquiryRepository = InquiryRepository();
  late TabController _tabController;
  late PageController _pageController;
  bool _isAdminMode = false;

  final List<String> _tabTitles = ['등록됨', '진행중', '완료'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _pageController = PageController();
    _checkAdminStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
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
          // 탭 바
          _buildTabBar(),

          // 컨텐츠 (PageView로 슬라이딩)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                _tabController.animateTo(index);
              },
              itemCount: _tabTitles.length,
              itemBuilder: (context, index) {
                return _buildPageContent(index);
              },
            ),
          ),
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
        // 🔥 검색 버튼 - 변경 확인용
        Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: _showSearchBottomSheet,
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: '민원 검색 🔥',
          ),
        ),
        if (_isAdminMode)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE082),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '관리자',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  /// 탭바 생성
  Widget _buildTabBar() {
    final backgroundColor = _isAdminMode
        ? const Color(0xFFFFF8E1)
        : const Color(0xFFF7F8FD);
    final selectedColor = _isAdminMode
        ? const Color(0xFFFFE082)
        : const Color(0xFFB4DBFF);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        indicator: BoxDecoration(
          color: selectedColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: const Color(0xFF71727A),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
        tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
      ),
    );
  }

  /// 페이지 컨텐츠 생성
  Widget _buildPageContent(int index) {
    // 상태에 따른 필터링
    InquiryStatus targetStatus;
    if (index == 0) {
      targetStatus = InquiryStatus.registered;
    } else if (index == 1)
      targetStatus = InquiryStatus.inProgress;
    else
      targetStatus = InquiryStatus.completed;

    if (_isAdminMode) {
      return _buildAdminContent(targetStatus);
    } else {
      return _buildUserContent(targetStatus);
    }
  }

  /// 관리자 컨텐츠
  Widget _buildAdminContent(InquiryStatus status) {
    return StreamBuilder<List<Inquiry>>(
      stream: _inquiryRepository.getAllInquiries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }

        final allInquiries = snapshot.data ?? [];
        final filteredInquiries = allInquiries
            .where((inquiry) => inquiry.status == status)
            .toList();

        if (filteredInquiries.isEmpty) {
          return _buildEmptyState(isAdmin: true);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredInquiries.length,
          itemBuilder: (context, index) {
            final inquiry = filteredInquiries[index];
            // 관리자 모드 - 편집/삭제 비활성화
            return ExpandableInquiryCard(
              inquiry: inquiry,
              isAdminMode: _isAdminMode,
              onTap: () => _navigateToDetail(inquiry),
            );
          },
        );
      },
    );
  }

  /// 사용자 컨텐츠
  Widget _buildUserContent(InquiryStatus status) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('로그인이 필요합니다.'));
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
            .where((inquiry) => inquiry.status == status)
            .toList();

        if (filteredInquiries.isEmpty) {
          return _buildEmptyState(isAdmin: false);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredInquiries.length,
          itemBuilder: (context, index) {
            final inquiry = filteredInquiries[index];
            // 사용자 모드 - 편집/삭제 가능
            return ExpandableInquiryCard(
              inquiry: inquiry,
              isAdminMode: _isAdminMode,
              onTap: () => _navigateToDetail(inquiry),
              onEdit: () => _editInquiry(inquiry),
              onDelete: () => _deleteInquiry(inquiry),
            );
          },
        );
      },
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState({required bool isAdmin}) {
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
              color: isAdmin
                  ? const Color(0xFFFFF8E1)
                  : const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              isAdmin
                  ? Icons.admin_panel_settings_outlined
                  : Icons.inbox_outlined,
              color: isAdmin ? Colors.orange : const Color(0xFFB3DAFF),
              size: 20,
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              Text(
                '등록된 민원이 없습니다.',
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
                isAdmin ? '사용자가 민원을 등록하면 여기에 표시됩니다.' : '민원을 등록해주세요.',
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
          if (!isAdmin) ...[
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
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

              // 작성자 (회원가입시 이름 표시)
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    inquiry.userName, // 회원가입시 작성한 이름
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

              // 관리자 액션 버튼
              const SizedBox(height: 16),
              _buildAdminActionButtons(inquiry),
            ],
          ),
        ),
      ),
    );
  }

  /// 관리자 액션 버튼들
  Widget _buildAdminActionButtons(Inquiry inquiry) {
    return Row(
      children: [
        // 진행중으로 변경 버튼 (등록된 상태일 때만)
        if (inquiry.status == InquiryStatus.registered) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () =>
                  _updateInquiryStatus(inquiry.id, InquiryStatus.inProgress),
              icon: const Icon(Icons.play_arrow, size: 16),
              label: const Text('진행중으로 변경'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _notifyDepartment(inquiry),
              icon: const Icon(Icons.send, size: 16),
              label: const Text('부서에 전달'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],

        // 답변하기 버튼 (진행중 상태일 때만)
        if (inquiry.status == InquiryStatus.inProgress)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showResponseDialog(inquiry),
              icon: const Icon(Icons.reply, size: 16),
              label: const Text('답변하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

        // 완료된 상태 표시
        if (inquiry.status == InquiryStatus.completed)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  SizedBox(width: 4),
                  Text('답변 완료', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ),
      ],
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // 상태 표시
              _buildStatusChip(inquiry.status),
            ],
          ),
        ),
      ),
    );
  }

  /// 상태 칩 생성
  Widget _buildStatusChip(InquiryStatus status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case InquiryStatus.registered:
        chipColor = Colors.blue;
        statusText = '등록됨';
        break;
      case InquiryStatus.inProgress:
        chipColor = Colors.orange;
        statusText = '진행중';
        break;
      case InquiryStatus.completed:
        chipColor = Colors.green;
        statusText = '완료';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 카테고리 칩 생성
  Widget _buildCategoryChip(InquiryCategory category) {
    String categoryText;
    switch (category) {
      case InquiryCategory.facility:
        categoryText = '시설';
        break;
      case InquiryCategory.academic:
        categoryText = '학사';
        break;
      case InquiryCategory.living:
        categoryText = '생활';
        break;
      case InquiryCategory.other:
        categoryText = '기타';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        categoryText,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w500,
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

  /// 날짜 포맷
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

  /// 민원 상태 업데이트
  Future<void> _updateInquiryStatus(
    String inquiryId,
    InquiryStatus status,
  ) async {
    try {
      await _inquiryRepository.updateInquiryStatus(inquiryId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '민원 상태가 ${status == InquiryStatus.inProgress ? "진행중" : "완료"}으로 변경되었습니다.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('상태 변경 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 부서 전달 알림
  void _notifyDepartment(Inquiry inquiry) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('부서에 전달되었습니다.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// 답변 다이얼로그 표시
  void _showResponseDialog(Inquiry inquiry) {
    final TextEditingController responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('민원 답변'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '문의: ${inquiry.content}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: responseController,
                decoration: const InputDecoration(
                  labelText: '답변을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (responseController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('답변을 입력해주세요.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await _inquiryRepository.addResponse(
                    inquiry.id,
                    responseController.text.trim(),
                  );

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('답변이 등록되었습니다.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('답변 등록 중 오류가 발생했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('답변 등록'),
            ),
          ],
        );
      },
    );
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

  /// 민원 편집
  void _editInquiry(Inquiry inquiry) {
    // 현재는 상세 페이지로 이동 (추후 편집 기능 구현)
    _navigateToDetail(inquiry);
  }

  /// 민원 삭제
  void _deleteInquiry(Inquiry inquiry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '민원 삭제',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2024),
          ),
        ),
        content: const Text(
          '이 민원을 삭제하시겠습니까?\n삭제된 민원은 복구할 수 없습니다.',
          style: TextStyle(color: Color(0xFF71727A), height: 1.5),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '취소',
              style: TextStyle(
                color: Color(0xFF71727A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                await _inquiryRepository.deleteInquiry(inquiry.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('민원이 삭제되었습니다.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('삭제 중 오류가 발생했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              '삭제',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
