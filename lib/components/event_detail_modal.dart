import 'package:flutter/material.dart';
import '../models/student_event.dart';

/// 총학생회 행사 상세 정보 모달
class EventDetailModal extends StatelessWidget {
  final StudentEvent event;

  const EventDetailModal({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 핸들 바
            _buildHandleBar(),

            // 헤더 (제목과 닫기 버튼)
            _buildHeader(context),

            // 날짜 정보
            _buildDateSection(),

            // 이미지 (있다면)
            if (event.imageUrl.isNotEmpty) _buildImageSection(),

            // 내용
            _buildContentSection(),

            // 신청 버튼
            _buildApplyButton(context),

            // 하단 여백
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 상단 핸들 바
  Widget _buildHandleBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// 헤더 (제목과 닫기 버튼)
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              event.title,
              style: const TextStyle(
                color: Color(0xFF1F2024),
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.close,
                size: 20,
                color: Color(0xFF8F9098),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜 섹션
  Widget _buildDateSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF006FFD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event, size: 16, color: Color(0xFF006FFD)),
                const SizedBox(width: 6),
                Text(
                  _getFormattedDate(),
                  style: const TextStyle(
                    color: Color(0xFF006FFD),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 이미지 섹션
  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          event.imageUrl,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: double.infinity,
              height: 200,
              color: const Color(0xFFF1F2F4),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: double.infinity,
            height: 200,
            color: const Color(0xFFF1F2F4),
            child: const Center(child: Icon(Icons.broken_image)),
          ),
        ),
      ),
    );
  }

  /// 내용 섹션
  Widget _buildContentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '행사 안내',
            style: TextStyle(
              color: Color(0xFF1F2024),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            event.description,
            style: const TextStyle(
              color: Color(0xFF1F2024),
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 신청 버튼
  Widget _buildApplyButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ElevatedButton(
        onPressed: () => _handleApply(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006FFD),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          '신청하기',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 신청 처리
  void _handleApply(BuildContext context) {
    // TODO: 실제 신청 로직 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '신청 완료',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${event.title} 행사 신청이 완료되었습니다!',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 모달 닫기
            },
            child: const Text(
              '확인',
              style: TextStyle(
                color: Color(0xFF006FFD),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜 포맷팅
  String _getFormattedDate() {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[event.startDate.weekday % 7];
    return '${event.startDate.year}년 ${event.startDate.month}월 ${event.startDate.day}일 ($weekday)';
  }
}
