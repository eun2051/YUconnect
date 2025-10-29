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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                widget.onDateSelected(selectedDay);
                Navigator.of(context).pop();
              },
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.sunday,
            ),
          ],
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
