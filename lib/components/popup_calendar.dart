import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// 팝업 캘린더 위젯
class PopupCalendar extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const PopupCalendar({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<PopupCalendar> createState() => _PopupCalendarState();
}

class _PopupCalendarState extends State<PopupCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate ?? DateTime.now();
    _selectedDay = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Container(
          height: 400, // 고정 높이를 크게 증가
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 캘린더 헤더
              Container(
                color: const Color(0xFF006FFD),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month - 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                    ),
                    Text(
                      '${_focusedDay.year}년 ${_focusedDay.month}월',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month + 1,
                          );
                        });
                      },
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // 캘린더 본체
              SizedBox(
                height: 280, // 높이를 크게 증가
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: TableCalendar<dynamic>(
                    firstDay: DateTime.now(),
                    lastDay: DateTime(2026, 12, 31),
                    focusedDay: _focusedDay,
                    rowHeight: 38, // 행 높이 정상화
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                    },
                    headerVisible: false,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    daysOfWeekHeight: 28, // 요일 헤더 높이 정상화
                    // 스타일링
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: const TextStyle(
                        color: Color(0xFF1F2024),
                        fontSize: 14, // 텍스트 크기 정상화
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                      defaultTextStyle: const TextStyle(
                        color: Color(0xFF1F2024),
                        fontSize: 14, // 텍스트 크기 정상화
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF006FFD),
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFF006FFD).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(
                        color: Color(0xFF006FFD),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      disabledTextStyle: const TextStyle(
                        color: Color(0xFFC5C6CC),
                        fontSize: 14,
                      ),
                      cellMargin: const EdgeInsets.all(2),
                      cellPadding: const EdgeInsets.all(0),
                    ),

                    // 요일 헤더 스타일
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Color(0xFF8F9098),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                      weekendStyle: TextStyle(
                        color: Color(0xFF8F9098),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    enabledDayPredicate: (day) {
                      // 오늘 이후의 날짜만 선택 가능
                      return day.isAfter(
                        DateTime.now().subtract(const Duration(days: 1)),
                      );
                    },

                    onDaySelected: (selectedDay, focusedDay) {
                      if (selectedDay.isAfter(
                        DateTime.now().subtract(const Duration(days: 1)),
                      )) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });

                        // 날짜 선택 후 잠시 대기 후 콜백 호출
                        Future.delayed(
                          const Duration(milliseconds: 200),
                          () {
                            widget.onDateSelected(selectedDay);
                          },
                        );
                      }
                    },

                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                  ),
                ),
              ),
                              _focusedDay = focusedDay;
                            });

                            // 날짜 선택 후 잠시 대기 후 콜백 호출
                            Future.delayed(
                              Duration(milliseconds = 200),
                              () {
                                widget.onDateSelected(selectedDay);
                              },
                            );
                          }
                        },

                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // 하단 버튼 영역
              Container(
                padding = const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration = const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF1F2F4), width: 1),
                  ),
                ),
                child = Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8F9098),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedDay != null
                            ? () {
                                widget.onDateSelected(_selectedDay!);
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF006FFD,
                          ), // 헤더와 동일한 색상
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '선택',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
}

/// 말풍선 캘린더를 보여주는 함수
Future<DateTime?> showPopupCalendar({
  required BuildContext context,
  DateTime? selectedDate,
  Offset? position,
}) async {
  DateTime? result;

  await showDialog<DateTime>(
    context: context,
    barrierColor: Colors.black26,
    barrierDismissible: true,
    builder: (BuildContext context) {
      final screenSize = MediaQuery.of(context).size;
      const calendarWidth = 300.0;
      const calendarHeight = 280.0; // 높이 더 줄임

      // position이 제공되면 해당 위치 사용, 그렇지 않으면 중앙 배치
      double left, top;

      if (position != null) {
        left = position.dx;
        top = position.dy;

        // 화면 경계 체크 및 조정
        if (left + calendarWidth > screenSize.width - 20) {
          left = screenSize.width - calendarWidth - 20;
        }
        if (left < 20) {
          left = 20;
        }

        // 캘린더가 화면 아래로 나가지 않도록 조정
        if (top + calendarHeight > screenSize.height - 50) {
          top = screenSize.height - calendarHeight - 50; // 화면 하단에서 50px 위
        }
        if (top < 50) {
          top = 50;
        }
      } else {
        // 기본 중앙 배치
        left = (screenSize.width - calendarWidth) / 2;
        top = (screenSize.height - calendarHeight) / 2;
      }

      return Stack(
        children: [
          // 배경 터치로 닫기
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
          ),

          // 캘린더 위치 조정
          Positioned(
            left: left,
            top: top,
            child: SizedBox(
              width: calendarWidth,
              child: PopupCalendar(
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  result = date;
                  Navigator.pop(context, date);
                },
              ),
            ),
          ),
        ],
      );
    },
  );

  return result;
}
