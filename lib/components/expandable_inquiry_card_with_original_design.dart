import 'package:flutter/material.dart';
import '../models/inquiry.dart';

/// 영대민원 화면과 동일한 디자인의 확장 가능한 민원 카드
class ExpandableInquiryCardWithOriginalDesign extends StatefulWidget {
  final Inquiry inquiry;
  final bool isAdminMode;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpandableInquiryCardWithOriginalDesign({
    super.key,
    required this.inquiry,
    required this.isAdminMode,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ExpandableInquiryCardWithOriginalDesign> createState() =>
      _ExpandableInquiryCardWithOriginalDesignState();
}

class _ExpandableInquiryCardWithOriginalDesignState
    extends State<ExpandableInquiryCardWithOriginalDesign>
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

  /// 민원 상태별 색상 (InquiryCard와 동일)
  Color _getStatusColor() {
    switch (widget.inquiry.status) {
      case InquiryStatus.registered:
        return const Color(0xFF006FFD);
      case InquiryStatus.inProgress:
        return const Color(0xFFFF6B35);
      case InquiryStatus.completed:
        return const Color(0xFF10B981);
    }
  }

  /// 상태 텍스트 (InquiryCard와 동일)
  String _getStatusText() {
    switch (widget.inquiry.status) {
      case InquiryStatus.registered:
        return '등록됨';
      case InquiryStatus.inProgress:
        return '진행중';
      case InquiryStatus.completed:
        return '답변완료';
    }
  }

  /// 카테고리 텍스트 (InquiryCard와 동일)
  String _getCategoryText() {
    switch (widget.inquiry.category) {
      case InquiryCategory.living:
        return '학생생활';
      case InquiryCategory.facility:
        return '안전 및 보안';
      case InquiryCategory.academic:
        return '행정/학과';
      case InquiryCategory.other:
        return '기타 건의';
    }
  }

  /// 제목 추출 (InquiryCard와 동일)
  String _extractTitle() {
    final content = widget.inquiry.content;
    if (content.startsWith('제목: ')) {
      final titleEnd = content.indexOf('\n');
      if (titleEnd != -1) {
        return content.substring(3, titleEnd).trim();
      }
      return content.substring(3).trim();
    }

    // 제목이 없는 경우 첫 줄을 제목으로 사용
    final firstLine = content.split('\n').first.trim();
    return firstLine.length > 30
        ? '${firstLine.substring(0, 30)}...'
        : firstLine;
  }

  /// 내용 추출 (InquiryCard와 동일)
  String _extractContent() {
    final content = widget.inquiry.content;
    if (content.startsWith('제목: ')) {
      final titleEnd = content.indexOf('\n');
      if (titleEnd != -1 && titleEnd + 1 < content.length) {
        return content.substring(titleEnd + 1).trim();
      }
      return '';
    }

    // 제목이 없는 경우 첫 줄 제외한 나머지를 내용으로 사용
    final lines = content.split('\n');
    if (lines.length > 1) {
      return lines.skip(1).join('\n').trim();
    }
    return '';
  }

  /// 날짜 포맷팅 (InquiryCard와 동일)
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
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

  /// 타임라인 스텝 위젯
  Widget _buildTimelineStep(Map<String, dynamic> step, bool isLast) {
    final bool isCompleted = step['isCompleted'];
    final bool isActive = step['isActive'];
    final DateTime? date = step['date'];

    Color stepColor;
    if (isCompleted) {
      stepColor = isActive ? _getStatusColor() : const Color(0xFF10B981);
    } else {
      stepColor = const Color(0xFFE5E7EB);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타임라인 아이콘과 라인
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: stepColor,
                shape: BoxShape.circle,
                border: Border.all(color: stepColor, width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : Container(),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? stepColor : const Color(0xFFE5E7EB),
              ),
          ],
        ),
        const SizedBox(width: 16),

        // 스텝 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? const Color(0xFF1F2024)
                      : const Color(0xFF9CA3AF),
                ),
              ),
              if (date != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDate(date),
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted
                        ? const Color(0xFF71727A)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
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
          // 메인 카드 (InquiryCard와 동일한 디자인)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _toggleExpanded,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getCategoryText(),
                            style: const TextStyle(
                              color: Color(0xFF71727A),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(widget.inquiry.createdAt),
                          style: const TextStyle(
                            color: Color(0xFF71727A),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        // 확장 아이콘
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: statusColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _extractTitle(),
                      style: const TextStyle(
                        color: Color(0xFF1F2024),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _extractContent(),
                      style: const TextStyle(
                        color: Color(0xFF71727A),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.isAdminMode) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '작성자: ${widget.inquiry.userName}',
                            style: const TextStyle(
                              color: Color(0xFF71727A),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // 확장 가능한 타임라인 섹션
          SizeTransition(
            sizeFactor: _animation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                border: Border(
                  top: BorderSide(
                    color: statusColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '민원 진행 상황',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 타임라인
                  ..._getTimelineSteps().asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    final isLast = index == _getTimelineSteps().length - 1;
                    return _buildTimelineStep(step, isLast);
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
