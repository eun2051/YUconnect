import 'package:flutter/material.dart';
import '../models/academic_event.dart';
import '../repositories/academic_event_repository.dart';

/// 학사일정 캘린더 바텀시트
class AcademicCalendarBottomSheet extends StatefulWidget {
  AcademicCalendarBottomSheet({super.key});

  @override
  State<AcademicCalendarBottomSheet> createState() =>
      _AcademicCalendarBottomSheetState();
}

class _AcademicCalendarBottomSheetState
    extends State<AcademicCalendarBottomSheet> {
  final AcademicEventRepository _eventRepository = AcademicEventRepository();
  int _currentYear = DateTime.now().year;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// 초기 데이터 로드
  Future<void> _initializeData() async {
    if (_hasInitialized) return;

    try {
      // 기존 데이터 확인
      final events = await _eventRepository.getEventsByYear(_currentYear).first;

      // 데이터가 없으면 샘플 데이터 자동 추가
      if (events.isEmpty) {
        await _eventRepository.addSampleData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('학사일정 샘플 데이터가 자동으로 추가되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      _hasInitialized = true;
    } catch (e) {
      print('데이터 초기화 오류: $e');
    }
  }

  /// 샘플 데이터 추가
  Future<void> _addSampleData() async {
    try {
      await _eventRepository.addSampleData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('학사일정 샘플 데이터가 추가되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 연도 변경
  void _changeYear(int newYear) {
    setState(() {
      _currentYear = newYear;
    });
  }

  /// 이벤트 카테고리별 색상
  Color _getEventColor(AcademicEventCategory category) {
    switch (category) {
      case AcademicEventCategory.regular:
        return const Color(0xFF006FFD);
      case AcademicEventCategory.exam:
        return const Color(0xFFFF6B35);
      case AcademicEventCategory.holiday:
        return const Color(0xFF10B981);
      case AcademicEventCategory.registration:
        return const Color(0xFF8B5CF6);
      case AcademicEventCategory.special:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeYear(_currentYear - 1),
                  icon: const Icon(Icons.chevron_left, size: 28),
                ),
                Text(
                  '$_currentYear년 학사일정',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2024),
                  ),
                ),
                IconButton(
                  onPressed: () => _changeYear(_currentYear + 1),
                  icon: const Icon(Icons.chevron_right, size: 28),
                ),
              ],
            ),
          ),

          // 샘플 데이터 추가 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: _addSampleData,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text(
                '학사일정 샘플 데이터 추가',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006FFD),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 구분선
          Container(
            height: 1,
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),

          // 학사일정 목록
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StreamBuilder<List<AcademicEvent>>(
                stream: _eventRepository.getEventsByYear(_currentYear),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF006FFD)),
                          SizedBox(height: 16),
                          Text(
                            '학사일정을 불러오는 중...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF71727A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '오류가 발생했습니다\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final events = snapshot.data ?? [];

                  if (events.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$_currentYear년 학사일정이 없습니다',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '위의 버튼을 눌러 샘플 데이터를 추가해보세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이벤트 개수 표시
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF006FFD).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_note,
                              color: Color(0xFF006FFD),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '총 ${events.length}개의 학사일정',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF006FFD),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 이벤트 목록
                      Expanded(
                        child: ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            final eventColor = _getEventColor(event.category);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: eventColor.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // 카테고리 컬러 바
                                  Container(
                                    width: 4,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: eventColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // 이벤트 정보
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 카테고리 태그
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: eventColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            event.category.displayName,
                                            style: TextStyle(
                                              color: eventColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // 이벤트 제목
                                        Text(
                                          event.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1F2024),
                                          ),
                                        ),
                                        const SizedBox(height: 4),

                                        // 날짜 정보
                                        Text(
                                          _formatEventDate(event),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF71727A),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        // 설명 (있는 경우)
                                        if (event.description != null &&
                                            event.description!.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            event.description!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 이벤트 날짜 포맷팅
  String _formatEventDate(AcademicEvent event) {
    final startDate = event.startDate;
    if (event.endDate == null) {
      return '${startDate.year}년 ${startDate.month}월 ${startDate.day}일';
    } else {
      final endDate = event.endDate!;
      if (startDate.year == endDate.year && startDate.month == endDate.month) {
        return '${startDate.year}년 ${startDate.month}월 ${startDate.day}일 - ${endDate.day}일';
      } else if (startDate.year == endDate.year) {
        return '${startDate.year}년 ${startDate.month}월 ${startDate.day}일 - ${endDate.month}월 ${endDate.day}일';
      } else {
        return '${startDate.year}년 ${startDate.month}월 ${startDate.day}일 - ${endDate.year}년 ${endDate.month}월 ${endDate.day}일';
      }
    }
  }
}
