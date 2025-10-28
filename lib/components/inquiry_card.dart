import 'package:flutter/material.dart';
import '../models/inquiry.dart';
import '../repositories/inquiry_repository.dart';
import '../screens/main/inquiry_detail_screen.dart';

/// 민원 카드 컴포넌트 - 홈 화면과 영대민원 화면에서 공통으로 사용
class InquiryCard extends StatelessWidget {
  final Inquiry inquiry;
  final bool isAdmin;

  const InquiryCard({
    super.key,
    required this.inquiry,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InquiryDetailScreen(
              inquiry: inquiry,
              isAdmin: isAdmin,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor().withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  _formatDate(inquiry.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF71727A),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
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
            if (isAdmin) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '작성자: ${inquiry.userName}',
                    style: const TextStyle(
                      color: Color(0xFF71727A),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (inquiry.status != InquiryStatus.completed)
                    _buildAdminActionButtons(context),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (inquiry.status) {
      case InquiryStatus.registered:
        return const Color(0xFF006FFD);
      case InquiryStatus.inProgress:
        return const Color(0xFFFF6B35);
      case InquiryStatus.completed:
        return const Color(0xFF10B981);
    }
  }

  String _getStatusText() {
    switch (inquiry.status) {
      case InquiryStatus.registered:
        return '등록됨';
      case InquiryStatus.inProgress:
        return '진행중';
      case InquiryStatus.completed:
        return '답변완료';
    }
  }

  String _getCategoryText() {
    switch (inquiry.category) {
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

  String _extractTitle() {
    final content = inquiry.content;
    if (content.startsWith('제목: ')) {
      final titleEnd = content.indexOf('\n');
      if (titleEnd != -1) {
        return content.substring(3, titleEnd).trim();
      }
      return content.substring(3).trim();
    }
    
    // 제목이 없는 경우 첫 줄을 제목으로 사용
    final firstLine = content.split('\n').first.trim();
    return firstLine.length > 30 ? '${firstLine.substring(0, 30)}...' : firstLine;
  }

  String _extractContent() {
    final content = inquiry.content;
    if (content.startsWith('제목: ')) {
      final titleEnd = content.indexOf('\n');
      if (titleEnd != -1 && titleEnd + 1 < content.length) {
        return content.substring(titleEnd + 1).trim();
      }
      return '';
    }
    
    // 제목이 없는 경우 전체 내용 반환
    return content;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  /// 관리자 액션 버튼들
  Widget _buildAdminActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (inquiry.status == InquiryStatus.registered)
          _buildActionButton(
            context,
            '처리 시작',
            const Color(0xFF006FFD),
            () => _updateInquiryStatus(context, InquiryStatus.inProgress),
          ),
        if (inquiry.status == InquiryStatus.inProgress) ...[
          _buildActionButton(
            context,
            '부서 전달',
            const Color(0xFFFF6B35),
            () => _notifyDepartment(context),
          ),
          const SizedBox(width: 4),
          _buildActionButton(
            context,
            '완료 처리',
            const Color(0xFF10B981),
            () => _updateInquiryStatus(context, InquiryStatus.completed),
          ),
        ],
      ],
    );
  }

  /// 액션 버튼 생성
  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 24,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }

  /// 민원 상태 업데이트
  Future<void> _updateInquiryStatus(BuildContext context, InquiryStatus newStatus) async {
    try {
      final repository = InquiryRepository();
      await repository.updateInquiryStatus(inquiry.id, newStatus);
      
      if (context.mounted) {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('상태 업데이트 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 부서 전달 알림
  Future<void> _notifyDepartment(BuildContext context) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('해당 민원이 담당 부서에 전달되었습니다.'),
            backgroundColor: Color(0xFFFF6B35),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('부서 전달 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
