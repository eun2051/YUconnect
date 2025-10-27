import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/inquiry_repository.dart';
import '../../models/inquiry.dart';
import 'inquiry_detail_screen.dart';

/// 영대민원 화면 - 등록된 민원/진행중/완료된 민원을 슬라이드 형식으로 관리
class YUInquiryScreen extends StatefulWidget {
  const YUInquiryScreen({Key? key}) : super(key: key);

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
            fontSize: 18,
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
                  content: Text(_isAdmin ? '관리자 모드로 전환되었습니다' : '사용자 모드로 전환되었습니다'),
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
      floatingActionButton: !_isAdmin ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 검색 버튼 (돋보기) - 사용자 모드에서만
          FloatingActionButton(
            heroTag: "search",
            onPressed: _showSearchDialog,
            backgroundColor: Colors.grey[600],
            child: const Icon(Icons.search, color: Colors.white),
          ),
          const SizedBox(height: 16),
          // 추가 버튼 (+) - 사용자 모드에서만
          FloatingActionButton(
            heroTag: "add",
            onPressed: _showAddInquiryDialog,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ) : null,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: ShapeDecoration(
                    color: _tabController.index == 0 
                        ? (_isAdmin ? const Color(0xFFFFE082) : const Color(0xFFB4DBFF))
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadows: _tabController.index == 0 ? [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ] : [],
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
                          color: _tabController.index == 0 ? const Color(0xFF1F2024) : const Color(0xFF71727A),
                          fontSize: 12,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: ShapeDecoration(
                    color: _tabController.index == 1 
                        ? (_isAdmin ? const Color(0xFFFFE082) : const Color(0xFFB4DBFF))
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadows: _tabController.index == 1 ? [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ] : [],
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
                          color: _tabController.index == 1 ? const Color(0xFF1F2024) : const Color(0xFF71727A),
                          fontSize: 12,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: ShapeDecoration(
                    color: _tabController.index == 2 
                        ? (_isAdmin ? const Color(0xFFFFE082) : const Color(0xFFB4DBFF))
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadows: _tabController.index == 2 ? [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ] : [],
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
                          color: _tabController.index == 2 ? const Color(0xFF1F2024) : const Color(0xFF71727A),
                          fontSize: 12,
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
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '데이터를 불러오는 중 오류가 발생했습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[600],
                  ),
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
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(status),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
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
            return _buildInquiryCard(inquiry, status);
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

  /// 민원 카드 위젯 생성
  Widget _buildInquiryCard(Inquiry inquiry, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _navigateToInquiryDetail(inquiry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusBadge(inquiry.status),
                  const Spacer(),
                  Text(
                    _formatDate(inquiry.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                inquiry.content.length > 50 
                    ? '${inquiry.content.substring(0, 50)}...'
                    : inquiry.content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  FutureBuilder<String>(
                    future: _inquiryRepository.getUserName(inquiry.userId),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Loading...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  if (_isAdmin && inquiry.status != InquiryStatus.completed)
                    _buildAdminActionButtons(inquiry),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 상태 배지 위젯
  Widget _buildStatusBadge(InquiryStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case InquiryStatus.registered:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        text = '등록됨';
        break;
      case InquiryStatus.inProgress:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        text = '진행중';
        break;
      case InquiryStatus.completed:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        text = '완료됨';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  /// 관리자 액션 버튼들
  Widget _buildAdminActionButtons(Inquiry inquiry) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (inquiry.status == InquiryStatus.registered)
          ElevatedButton(
            onPressed: () => _updateInquiryStatus(inquiry, InquiryStatus.inProgress),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: const Text(
              '처리 시작',
              style: TextStyle(fontSize: 12),
            ),
          ),
        if (inquiry.status == InquiryStatus.inProgress) ...[
          ElevatedButton(
            onPressed: () => _notifyDepartment(inquiry),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: const Text(
              '부서 전달',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _updateInquiryStatus(inquiry, InquiryStatus.completed),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: const Text(
              '완료 처리',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// 민원 상태 업데이트
  Future<void> _updateInquiryStatus(Inquiry inquiry, InquiryStatus newStatus) async {
    try {
      await _inquiryRepository.updateInquiryStatus(inquiry.id, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == InquiryStatus.inProgress 
                  ? '민원 처리를 시작했습니다.'
                  : '민원이 완료 처리되었습니다.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('상태 업데이트 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 부서 전달 알림 (사용자에게 알림)
  Future<void> _notifyDepartment(Inquiry inquiry) async {
    try {
      // 여기서 실제로는 푸시 알림을 보내거나 이메일을 발송할 수 있습니다.
      // 현재는 상태 업데이트와 스낵바로 대체합니다.
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('해당 민원이 담당 부서에 전달되었습니다.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('부서 전달 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 민원 상세 페이지로 이동
  void _navigateToInquiryDetail(Inquiry inquiry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InquiryDetailScreen(
          inquiry: inquiry,
          isAdmin: _isAdmin,
        ),
      ),
    );
  }

  /// 새 민원 등록 다이얼로그
  void _showAddInquiryDialog() {
    final contentController = TextEditingController();
    InquiryCategory selectedCategory = InquiryCategory.other;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('새 민원 등록'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<InquiryCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(),
                  ),
                  items: InquiryCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.trim().isNotEmpty && _currentUser != null) {
                  
                  // 사용자 프로필에서 이름 가져오기
                  final userName = await _inquiryRepository.getUserName(_currentUser!.uid);
                  
                  final newInquiry = Inquiry(
                    id: '',
                    userId: _currentUser!.uid,
                    userName: userName,
                    content: contentController.text.trim(),
                    category: selectedCategory,
                    status: InquiryStatus.registered,
                    createdAt: DateTime.now(),
                  );

                  try {
                    await _inquiryRepository.addInquiry(newInquiry);
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('민원이 성공적으로 등록되었습니다.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('민원 등록 실패: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('등록'),
            ),
          ],
        ),
      ),
    );
  }

  /// 검색 다이얼로그
  void _showSearchDialog() {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('민원 검색'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: '검색어를 입력하세요',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (searchController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                // TODO: 검색 기능 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('검색어: ${searchController.text.trim()}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('검색'),
          ),
        ],
      ),
    );
  }
}
