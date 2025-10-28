import 'package:flutter/material.dart';
import '../models/inquiry.dart';

/// 확장 가능한 민원 카드 - 타임라인 스타일
class ExpandableInquiryCard extends StatefulWidget {
  final Inquiry inquiry;
  final bool isAdminMode;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpandableInquiryCard({
    super.key,
    required this.inquiry,
    required this.isAdminMode,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ExpandableInquiryCard> createState() => _ExpandableInquiryCardState();
}

class _ExpandableInquiryCardState extends State<ExpandableInquiryCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  /// 민원 상태별 색상
  Color _getStatusColor(InquiryStatus status) {
    switch (status) {
      case InquiryStatus.registered:
        return const Color(0xFF006FFD);
      case InquiryStatus.inProgress:
        return const Color(0xFFF59E0B);
      case InquiryStatus.completed:
        return const Color(0xFF10B981);
    }
  }

  /// 타임라인 스텝 정보
  List<Map<String, dynamic>> _getTimelineSteps() {
    final List<Map<String, dynamic>> steps = [
      {
        'title': '민원 등록',
        'date': widget.inquiry.createdAt,
        'isCompleted': true,
        'isActive': widget.inquiry.status == InquiryStatus.registered,
      },
      {
        'title': '민원 확인',
        'date': widget.inquiry.status != InquiryStatus.registered
            ? widget.inquiry.createdAt.add(const Duration(hours: 1))
            : null,
        'isCompleted': widget.inquiry.status != InquiryStatus.registered,
        'isActive': widget.inquiry.status == InquiryStatus.inProgress,
      },
      {
        'title': '민원 부서 전달',
        'date': widget.inquiry.status == InquiryStatus.completed
            ? widget.inquiry.createdAt.add(const Duration(hours: 2))
            : null,
        'isCompleted': widget.inquiry.status == InquiryStatus.completed,
        'isActive': false,
      },
      {
        'title': '답변 완료',
        'date': widget.inquiry.status == InquiryStatus.completed
            ? widget.inquiry.updatedAt ??
                  widget.inquiry.createdAt.add(const Duration(days: 1))
            : null,
        'isCompleted': widget.inquiry.status == InquiryStatus.completed,
        'isActive': widget.inquiry.status == InquiryStatus.completed,
      },
    ];
    return steps;
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.inquiry.status);
    final timelineSteps = _getTimelineSteps();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD3D5DD), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 메인 카드 (클릭 가능)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              onTap: _toggleExpanded,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단: 나의 민원 헤더
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: statusColor, width: 1),
                          ),
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '나의 민원',
                          style: TextStyle(
                            color: Color(0xFF71727A),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        // 편집/삭제 버튼 (사용자 모드에서만)
                        if (!widget.isAdminMode) ...[
                          if (widget.onEdit != null)
                            IconButton(
                              onPressed: widget.onEdit,
                              icon: const Icon(Icons.edit, size: 18),
                              iconSize: 18,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          if (widget.onDelete != null)
                            IconButton(
                              onPressed: widget.onDelete,
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.red,
                              ),
                              iconSize: 18,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 민원 카드
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
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
                                  widget.inquiry.category.displayName,
                                  style: const TextStyle(
                                    color: Color(0xFF1F2024),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.43,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(widget.inquiry.createdAt),
                                  style: const TextStyle(
                                    color: Color(0xFF71727A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    height: 1.33,
                                    letterSpacing: 0.12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 확장 아이콘
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: statusColor,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 확장 가능한 타임라인 영역
          SizeTransition(
            sizeFactor: _animation,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // 타임라인
                  ...timelineSteps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    final isLast = index == timelineSteps.length - 1;

                    return _buildTimelineStep(
                      title: step['title'],
                      date: step['date'],
                      isCompleted: step['isCompleted'],
                      isActive: step['isActive'],
                      isLast: isLast,
                    );
                  }),

                  const SizedBox(height: 24),

                  // 답변 내용 (완료된 경우)
                  if (widget.inquiry.status == InquiryStatus.completed &&
                      widget.inquiry.adminResponse != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFC5C6CC),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '답변 내용',
                            style: TextStyle(
                              color: Color(0xFF1F2024),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.43,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.inquiry.adminResponse!,
                            style: const TextStyle(
                              color: Color(0xFF71727A),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 새 민원 등록 버튼
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF006FFD),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '새 민원 등록',
                          style: TextStyle(
                            color: Color(0xFF006FFD),
                            fontSize: 12,
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
        ],
      ),
    );
  }

  /// 타임라인 스텝 위젯
  Widget _buildTimelineStep({
    required String title,
    required DateTime? date,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타임라인 점과 선
        Column(
          children: [
            // 원형 점
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF006FFD)
                    : const Color(0xFF66686C),
                shape: BoxShape.circle,
              ),
              child: isActive && isCompleted
                  ? const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
            ),

            // 연결선 (마지막이 아닌 경우)
            if (!isLast) ...[
              const SizedBox(height: 8),
              Container(
                width: 3,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFF006FFD),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),

        const SizedBox(width: 16),

        // 스텝 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1F2024),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
              if (date != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDate(date),
                  style: const TextStyle(
                    color: Color(0xFF71727A),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    letterSpacing: 0.12,
                  ),
                ),
              ],
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
