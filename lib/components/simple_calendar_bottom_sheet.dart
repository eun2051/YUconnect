import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// 학사일정 캘린더 바텀시트
class SimpleCalendarBottomSheet extends StatefulWidget {
  const SimpleCalendarBottomSheet({super.key});

  @override
  State<SimpleCalendarBottomSheet> createState() => _SimpleCalendarBottomSheetState();
}

class _SimpleCalendarBottomSheetState extends State<SimpleCalendarBottomSheet> {
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // 샘플 학사일정 데이터
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime(2025, 3, 2): [
      {'title': '2025년 1학기 개강', 'category': '일반', 'color': Colors.blue}
    ],
    DateTime(2025, 4, 14): [
      {'title': '중간고사 시작', 'category': '시험', 'color': Colors.red}
    ],
    DateTime(2025, 4, 25): [
      {'title': '중간고사 종료', 'category': '시험', 'color': Colors.red}
    ],
    DateTime(2025, 5, 5): [
      {'title': '어린이날', 'category': '휴일', 'color': Colors.green}
    ],
    DateTime(2025, 6, 6): [
      {'title': '현충일', 'category': '휴일', 'color': Colors.green}
    ],
    DateTime(2025, 6, 16): [
      {'title': '기말고사 시작', 'category': '시험', 'color': Colors.red}
    ],
    DateTime(2025, 6, 27): [
      {'title': '기말고사 종료', 'category': '시험', 'color': Colors.red}
    ],
    DateTime(2025, 6, 28): [
      {'title': '여름방학 시작', 'category': '휴일', 'color': Colors.green}
    ],
    DateTime(2025, 8, 31): [
      {'title': '여름방학 종료', 'category': '휴일', 'color': Colors.green}
    ],
    DateTime(2025, 9, 1): [
      {'title': '2학기 개강', 'category': '일반', 'color': Colors.blue}
    ],
    DateTime(2025, 10, 15): [
      {'title': '중간고사 시작', 'category': '시험', 'color': Colors.red}
    ],
    DateTime(2025, 10, 26): [
      {'title': '중간고사 종료', 'category': '시험', 'color': Colors.red}
    ],
    DateTime(2025, 12, 16): [
      {'title': '기말고사 시작', 'category': '시험', 'color': Colors.red}
    ],
    DateTime(2025, 12, 27): [
      {'title': '기말고사 종료', 'category': '시험', 'color': Colors.red}
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: const Text(
              '학사일정 캘린더',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2024),
              ),
            ),
          ),
          
          // 캘린더
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar<Map<String, dynamic>>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: const TextStyle(color: Colors.red),
                holidayTextStyle: const TextStyle(color: Colors.red),
                selectedDecoration: BoxDecoration(
                  color: const Color(0xFF006FFD),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF006FFD).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                canMarkersOverflow: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF006FFD),
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF006FFD),
                ),
                titleTextStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2024),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 선택된 날짜의 일정 표시
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _selectedDay != null 
                          ? '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일 일정'
                          : '날짜를 선택해주세요',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2024),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedEvents,
                      builder: (context, events, _) {
                        if (events.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  '해당 날짜에 일정이 없습니다.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: event['color'].withOpacity(0.3),
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
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: event['color'],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // 이벤트 정보
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 카테고리 태그
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: event['color'].withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            event['category'],
                                            style: TextStyle(
                                              color: event['color'],
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        
                                        // 이벤트 제목
                                        Text(
                                          event['title'],
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F2024),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
