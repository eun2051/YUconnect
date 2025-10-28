import 'package:flutter/material.dart';
import '../models/inquiry.dart';

/// 확장 가능한 민원 카드 - 답변완료 탭에서 사용
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
      duration: const Duration(milliseconds: 300),
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
    print('DEBUG: 카드 클릭! 현재 상태: $_isExpanded'); // 디버그
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    print('DEBUG: 새로운 상태: $_isExpanded'); // 디버그
  }

  Color _getCategoryColor(InquiryCategory category) {
    switch (category) {
      case InquiryCategory.academic:
        return const Color(0xFF006FFD);
      case InquiryCategory.facility:
        return const Color(0xFF10B981);
      case InquiryCategory.living:
        return const Color(0xFFF59E0B);
      case InquiryCategory.other:
        return const Color(0xFF8B5CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(widget.inquiry.category);
    print('DEBUG: 확장 카드 빌드 중 - 답변: ${widget.inquiry.adminResponse}'); // 디버그

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 민원 기본 정보 카드
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 (카테고리, 상태, 날짜)
                  Row(
                    children: [
                      // 카테고리 태그
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.inquiry.category.displayName,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // 상태 배지
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '답변완료',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 사용자 모드일 때만 편집/삭제 버튼 표시
                      if (!widget.isAdminMode) ...[
                        const SizedBox(width: 8),
                        // 편집 버튼
                        InkWell(
                          onTap: widget.onEdit,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Color(0xFF006FFD),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // 삭제 버튼
                        InkWell(
                          onTap: widget.onDelete,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.delete,
                              size: 16,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 민원 내용
                  Text(
                    widget.inquiry.content,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2024),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // 하단 정보 (작성자, 날짜, 확장 아이콘)
                  Row(
                    children: [
                      // 작성자
                      Text(
                        widget.inquiry.userName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF71727A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 2,
                        height: 2,
                        decoration: const BoxDecoration(
                          color: Color(0xFF71727A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 답변 날짜
                      Text(
                        _formatDate(
                          widget.inquiry.responseAt ?? widget.inquiry.createdAt,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF71727A),
                        ),
                      ),

                      const Spacer(),

                      // 확장 아이콘
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF71727A),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 답변 슬라이드 영역
          SizeTransition(
            sizeFactor: _animation,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  // 구분선
                  Container(height: 1, color: const Color(0xFFE2E8F0)),

                  // 답변 내용
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 답변 헤더
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF006FFD).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.support_agent,
                                color: Color(0xFF006FFD),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '관리자 답변',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2024),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(
                                widget.inquiry.responseAt ??
                                    widget.inquiry.createdAt,
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF71727A),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 답변 내용
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF006FFD).withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            widget.inquiry.adminResponse ?? '답변 내용이 없습니다.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1F2024),
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 만족도 평가 (선택사항)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.thumb_up_outlined,
                                color: Color(0xFF006FFD),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '답변이 도움이 되셨나요?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF006FFD),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  _buildRatingButton(
                                    Icons.thumb_up,
                                    '도움됨',
                                    true,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildRatingButton(
                                    Icons.thumb_down,
                                    '아쉬움',
                                    false,
                                  ),
                                ],
                              ),
                            ],
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

  Widget _buildRatingButton(IconData icon, String label, bool isPositive) {
    return InkWell(
      onTap: () {
        // 만족도 평가 로직 (선택사항)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label 평가를 선택했습니다'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isPositive
                  ? const Color(0xFF10B981)
                  : const Color(0xFF71727A),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isPositive
                    ? const Color(0xFF10B981)
                    : const Color(0xFF71727A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
