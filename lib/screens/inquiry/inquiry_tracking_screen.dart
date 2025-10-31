import 'package:flutter/material.dart';
import '../../models/inquiry.dart';
import '../../repositories/inquiry_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// 민원 조회 화면 (택배 조회 스타일)
class InquiryTrackingScreen extends StatefulWidget {
  const InquiryTrackingScreen({super.key});

  @override
  State<InquiryTrackingScreen> createState() => _InquiryTrackingScreenState();
}

class _InquiryTrackingScreenState extends State<InquiryTrackingScreen> {
  final _inquiryRepository = InquiryRepository();
  Inquiry? _selectedInquiry;
  List<Inquiry> _userInquiries = [];
  bool _isLoading = true;
  StreamSubscription<List<Inquiry>>? _inquirySubscription;

  @override
  void initState() {
    super.initState();
    _loadUserInquiries();
  }

  @override
  void dispose() {
    _inquirySubscription?.cancel();
    super.dispose();
  }

  /// 사용자의 민원 목록 로드
  Future<void> _loadUserInquiries() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final inquiriesStream = _inquiryRepository.getInquiriesByUserId(
          user.uid,
        );
        _inquirySubscription = inquiriesStream.listen((inquiries) {
          if (mounted) {
            setState(() {
              _userInquiries = inquiries;
              _isLoading = false;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006FFD)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '민원 조회',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _selectedInquiry == null
          ? _buildInquirySelection()
          : _buildTrackingView(),
    );
  }

  /// 민원 선택 화면
  Widget _buildInquirySelection() {
    return Column(
      children: [
        // 헤더
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 16,
            left: 24,
            right: 24,
            bottom: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '확인하고 싶은 민원을 선택해주세요',
                style: TextStyle(
                  color: Color(0xFF1F2024),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.08,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '작성한 민원 중 조회하고 싶은 민원 하나를 선택해주세요.',
                style: TextStyle(
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
        // 민원 목록
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _userInquiries.isEmpty
                ? const Center(
                    child: Text(
                      '등록된 민원이 없습니다.',
                      style: TextStyle(
                        color: Color(0xFF71727A),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _userInquiries.length,
                    itemBuilder: (context, index) {
                      final inquiry = _userInquiries[index];
                      return _buildInquiryItem(inquiry);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  /// 민원 항목 위젯
  Widget _buildInquiryItem(Inquiry inquiry) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedInquiry = inquiry;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: const Color(0xFFEAF2FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inquiry.content, // inquiry.title에서 inquiry.content로 변경
                    style: const TextStyle(
                      color: Color(0xFF1F2024),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.43,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    inquiry.category.displayName,
                    style: const TextStyle(
                      color: Color(0xFF71727A),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      letterSpacing: 0.12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(inquiry.createdAt),
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
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF006FFD),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// 민원 진행 상황 조회 화면
  Widget _buildTrackingView() {
    if (_selectedInquiry == null) {
      return const Center(child: Text('민원 정보가 없습니다.'));
    }

    return Column(
      children: [
        // 선택된 민원 정보
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: ShapeDecoration(
                  color: const Color(0xFF006FFD),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFF006FFD)),
                    borderRadius: BorderRadius.circular(500),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.circle, color: Colors.white, size: 6),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '나의 민원',
                style: TextStyle(
                  color: Color(0xFF71727A),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // 선택된 민원 카드
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: const Color(0xFFEAF2FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedInquiry!
                    .content, // _selectedInquiry!.title에서 _selectedInquiry!.content로 변경
                style: const TextStyle(
                  color: Color(0xFF1F2024),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.43,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(_selectedInquiry!.createdAt),
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

        const SizedBox(height: 32),

        // 진행 상황 타임라인
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildProgressTimeline(),
          ),
        ),

        // 새 민원 등록 버튼
        Container(
          padding: const EdgeInsets.all(24),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context); // 민원 조회 화면 닫기
              // 민원 등록 화면으로 이동하는 로직은 부모 화면에서 처리
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(color: Color(0xFF006FFD)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '새 민원 등록',
                    style: TextStyle(
                      color: Color(0xFF006FFD),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 진행 상황 타임라인 생성
  Widget _buildProgressTimeline() {
    final steps = _getProgressSteps();

    return ListView.separated(
      itemCount: steps.length,
      separatorBuilder: (context, index) =>
          _buildConnectingLine(index < _getCurrentStepIndex()),
      itemBuilder: (context, index) {
        final step = steps[index];
        final isCompleted = index <= _getCurrentStepIndex();
        final isCurrent = index == _getCurrentStepIndex();

        return _buildTimelineStep(
          step['title']!,
          step['date']!,
          isCompleted,
          isCurrent,
        );
      },
    );
  }

  /// 진행 단계 목록 반환
  List<Map<String, String>> _getProgressSteps() {
    if (_selectedInquiry == null) return [];
    return [
      {'title': '민원 등록', 'date': _formatDate(_selectedInquiry!.createdAt)},
      {
        'title': '민원 확인',
        'date': _selectedInquiry!.status.index >= 1
            ? _formatDate(_selectedInquiry!.updatedAt)
            : '',
      },
      {
        'title': '민원 부서 전달',
        'date': _selectedInquiry!.status.index >= 1
            ? _formatDate(_selectedInquiry!.updatedAt)
            : '',
      },
      {
        'title': '답변 완료',
        'date': _selectedInquiry!.status == InquiryStatus.completed
            ? (_selectedInquiry!.responseAt != null
                  ? _formatDate(_selectedInquiry!.responseAt!)
                  : _formatDate(_selectedInquiry!.updatedAt))
            : '',
      },
    ];
  }

  /// 현재 진행 단계 인덱스 반환
  int _getCurrentStepIndex() {
    if (_selectedInquiry == null) return 0;
    switch (_selectedInquiry!.status) {
      case InquiryStatus.registered:
        return 0;
      case InquiryStatus.inProgress:
        return 2;
      case InquiryStatus.completed:
        return 3;
    }
  }

  /// 타임라인 단계 위젯
  Widget _buildTimelineStep(
    String title,
    String date,
    bool isCompleted,
    bool isCurrent,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상태 아이콘
        Container(
          width: 17,
          height: 17,
          decoration: ShapeDecoration(
            color: isCompleted
                ? const Color(0xFF006FFD)
                : const Color(0xFF66686C),
            shape: const OvalBorder(),
          ),
          child: isCompleted
              ? const Center(
                  child: Icon(Icons.check, color: Colors.white, size: 10),
                )
              : null,
        ),
        const SizedBox(width: 16),
        // 단계 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isCompleted
                      ? const Color(0xFF1F2024)
                      : const Color(0xFF71727A),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
                  height: 1.43,
                ),
              ),
              if (date.isNotEmpty) ...[
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
            ],
          ),
        ),
      ],
    );
  }

  /// 연결선 위젯
  Widget _buildConnectingLine(bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      width: 3,
      height: 32,
      decoration: ShapeDecoration(
        color: isCompleted ? const Color(0xFF006FFD) : const Color(0xFF66686C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.5)),
      ),
    );
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
