import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notice.dart';
import '../../repositories/notice_repository.dart';

/// 공지사항 상세 페이지
class NoticeDetailScreen extends StatefulWidget {
  final Notice notice;

  const NoticeDetailScreen({super.key, required this.notice});

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  final NoticeRepository _noticeRepository = NoticeRepository();

  @override
  void initState() {
    super.initState();
    _incrementViewCount();
  }

  /// 조회수 증가
  Future<void> _incrementViewCount() async {
    try {
      await _noticeRepository.incrementViewCount(widget.notice.id);
    } catch (e) {
      print('조회수 증가 오류: $e');
    }
  }

  /// 원본 링크 열기
  Future<void> _openOriginalUrl() async {
    if (widget.notice.originalUrl != null) {
      // TODO: URL 열기 기능 구현 (url_launcher 패키지 필요)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('원본 링크: ${widget.notice.originalUrl}')),
      );
    }
  }

  /// 카테고리별 색상
  Color _getCategoryColor(String category) {
    switch (category) {
      case '학사':
        return const Color(0xFF006FFD);
      case '일반':
        return const Color(0xFF10B981);
      case '입학':
        return const Color(0xFF8B5CF6);
      case '취업':
        return const Color(0xFFF59E0B);
      case '장학':
        return const Color(0xFFEF4444);
      case '행사':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(widget.notice.category);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1F2024),
            size: 20,
          ),
        ),
        title: const Text(
          '공지사항 상세',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.notice.originalUrl != null)
            IconButton(
              onPressed: _openOriginalUrl,
              icon: const Icon(
                Icons.open_in_new,
                color: Color(0xFF006FFD),
                size: 24,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리와 중요도
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.notice.category,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (widget.notice.isImportant)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.priority_high,
                                color: Color(0xFFEF4444),
                                size: 12,
                              ),
                              SizedBox(width: 2),
                              Text(
                                '중요',
                                style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 제목
                  Text(
                    widget.notice.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2024),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 작성자 정보
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: categoryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.notice.author,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2024),
                              ),
                            ),
                            Text(
                              widget.notice.department,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF71727A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat(
                              'yyyy.MM.dd',
                            ).format(widget.notice.publishDate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF71727A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.visibility,
                                size: 12,
                                color: Color(0xFF71727A),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.notice.viewCount + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF71727A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 내용
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '내용',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2024),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.notice.content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1F2024),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // 첨부파일 (있는 경우)
            if (widget.notice.attachments.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '첨부파일',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2024),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.notice.attachments.map(
                      (attachment) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.attach_file,
                              color: Color(0xFF006FFD),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                attachment,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1F2024),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // TODO: 첨부파일 다운로드 기능
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('첨부파일 다운로드 기능은 준비 중입니다.'),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.download,
                                color: Color(0xFF006FFD),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
