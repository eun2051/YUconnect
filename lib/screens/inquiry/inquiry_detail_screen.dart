import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main/notification_screen.dart';
import '../../models/inquiry.dart';
import '../../repositories/inquiry_repository.dart';

/// 민원 상세 화면
class InquiryDetailScreen extends StatefulWidget {
  final Inquiry inquiry;

  const InquiryDetailScreen({super.key, required this.inquiry});

  @override
  State<InquiryDetailScreen> createState() => _InquiryDetailScreenState();
}

class _InquiryDetailScreenState extends State<InquiryDetailScreen>
    with SingleTickerProviderStateMixin {
  final InquiryRepository _inquiryRepository = InquiryRepository();
  final TextEditingController _responseController = TextEditingController();

  bool _isAdminMode = false;
  bool _isSubmittingResponse = false;
  bool _showResponse = false;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _initAnimation();

    // 답변이 있으면 자동으로 슬라이드 다운
    if (widget.inquiry.adminResponse != null &&
        widget.inquiry.adminResponse!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _toggleResponse();
      });
    }
  }

  @override
  void dispose() {
    _responseController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _checkAdminStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isAdminMode =
            user.email == 'admin@yu.ac.kr' || user.email == 'admin@test.com';
      });
    }
  }

  void _toggleResponse() {
    setState(() {
      _showResponse = !_showResponse;
    });

    if (_showResponse) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '민원 상세',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 민원 카드
            _buildInquiryCard(),

            const SizedBox(height: 16),

            // 답변 영역 (슬라이드)
            if (widget.inquiry.adminResponse != null &&
                widget.inquiry.adminResponse!.isNotEmpty)
              _buildResponseSection(),

            // 관리자 답변 입력 (관리자 모드)
            if (_isAdminMode &&
                widget.inquiry.status != InquiryStatus.completed)
              _buildAdminResponseInput(),
          ],
        ),
      ),
    );
  }

  /// 민원 카드
  Widget _buildInquiryCard() {
    final lines = widget.inquiry.content.split('\n');
    final title = lines.isNotEmpty ? lines[0] : '';
    final content = lines.length > 2
        ? lines.skip(2).join('\n')
        : widget.inquiry.content;

    return GestureDetector(
      onTap:
          widget.inquiry.adminResponse != null &&
              widget.inquiry.adminResponse!.isNotEmpty
          ? _toggleResponse
          : null,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  _buildCategoryChip(widget.inquiry.category),
                  const Spacer(),
                  _buildStatusChip(widget.inquiry.status),
                ],
              ),
              const SizedBox(height: 12),

              // 제목
              if (title.isNotEmpty)
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2024),
                  ),
                ),
              const SizedBox(height: 8),

              // 작성자 및 날짜
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.inquiry.userName,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(widget.inquiry.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 내용
              Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF2D2D2D),
                ),
              ),

              // 답변 보기 버튼 (답변이 있을 때)
              if (widget.inquiry.adminResponse != null &&
                  widget.inquiry.adminResponse!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showResponse
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF006FFD),
                      ),
                      Text(
                        _showResponse ? '답변 숨기기' : '답변 보기',
                        style: const TextStyle(
                          color: Color(0xFF006FFD),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 답변 섹션 (슬라이드 애니메이션)
  Widget _buildResponseSection() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _slideAnimation,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFB4DBFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // 답변 헤더
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '관리자 답변',
                          style: TextStyle(
                            color: Color(0xFF1F2024),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (widget.inquiry.responseAt != null)
                          Text(
                            _formatDate(widget.inquiry.responseAt!),
                            style: const TextStyle(
                              color: Color(0xFF71727A),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 답변 내용
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.inquiry.adminResponse!,
                      style: const TextStyle(
                        color: Color(0xFF2D2D2D),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 관리자 답변 입력
  Widget _buildAdminResponseInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '답변 작성',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _responseController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '답변을 입력해주세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFC5C6CC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF006FFD)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmitResponse() ? _submitResponse : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006FFD),
                  disabledBackgroundColor: const Color(0xFFC5C6CC),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmittingResponse
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '답변 등록',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
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

  bool _canSubmitResponse() {
    return _responseController.text.trim().isNotEmpty && !_isSubmittingResponse;
  }

  Future<void> _submitResponse() async {
    if (!_canSubmitResponse()) return;

    setState(() {
      _isSubmittingResponse = true;
    });

    try {
      await _inquiryRepository.addResponse(
        widget.inquiry.id,
        _responseController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('답변이 성공적으로 등록되었습니다.'),
            backgroundColor: Color(0xFF006FFD),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('답변 등록 실패: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingResponse = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
