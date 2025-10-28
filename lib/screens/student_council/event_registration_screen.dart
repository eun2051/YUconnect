import 'package:flutter/material.dart';

/// 총학생회 행사 등록 화면
class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  State<EventRegistrationScreen> createState() => _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF006FFD), // 선택된 날짜 색상
              onPrimary: Colors.white, // 선택된 날짜 텍스트 색상
              surface: Colors.white, // 캘린더 배경색
              onSurface: Colors.black, // 일반 텍스트 색상
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF006FFD), // 버튼 텍스트 색상
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _submitEvent() {
    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 필드를 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 성공 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '행사가 성공적으로 등록되었습니다!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text('제목: ${_titleController.text}'),
            Text('장소: ${_locationController.text}'),
            Text('날짜: ${_formatDateRange()}'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // 폼 초기화
    _titleController.clear();
    _contentController.clear();
    _locationController.clear();
    setState(() {
      _selectedDateRange = null;
    });
  }

  String _formatDateRange() {
    if (_selectedDateRange == null) return '';
    
    final startDate = _selectedDateRange!.start;
    final endDate = _selectedDateRange!.end;
    
    if (startDate == endDate) {
      return '${startDate.year}년 ${startDate.month}월 ${startDate.day}일';
    } else {
      return '${startDate.year}년 ${startDate.month}월 ${startDate.day}일 ~ ${endDate.year}년 ${endDate.month}월 ${endDate.day}일';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2024)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '행사 등록',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력
            _buildInputSection(
              label: '제목',
              child: _buildTextInput(
                controller: _titleController,
                placeholder: '제목을 입력해주세요.',
              ),
            ),
            const SizedBox(height: 16),

            // 장소 입력
            _buildInputSection(
              label: '장소',
              child: _buildTextInput(
                controller: _locationController,
                placeholder: '행사 장소를 입력해주세요.',
              ),
            ),
            const SizedBox(height: 16),

            // 날짜 선택 (범위 선택 가능)
            _buildInputSection(
              label: '행사 날짜',
              child: GestureDetector(
                onTap: _selectDateRange,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: ShapeDecoration(
                    color: _selectedDateRange != null 
                        ? const Color(0xFFF0F7FF) 
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: _selectedDateRange != null 
                            ? const Color(0xFF006FFD) 
                            : const Color(0xFFC5C6CC),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDateRange != null
                              ? _formatDateRange()
                              : '행사 날짜를 선택해주세요 (하루 또는 기간)',
                          style: TextStyle(
                            color: _selectedDateRange != null
                                ? const Color(0xFF006FFD)
                                : const Color(0xFF8F9098),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.date_range,
                        color: _selectedDateRange != null
                            ? const Color(0xFF006FFD)
                            : const Color(0xFF8F9098),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 사진/동영상 첨부
            _buildInputSection(
              label: '사진/동영상 첨부',
              child: Container(
                width: double.infinity,
                height: 100,
                padding: const EdgeInsets.all(30),
                decoration: ShapeDecoration(
                  color: const Color(0xFFEAF2FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB3DAFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate,
                        color: Color(0xFF006FFD),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 행사 내용
            _buildInputSection(
              label: '행사 내용',
              child: Container(
                width: double.infinity,
                height: 120,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFC5C6CC),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: '행사 내용을 입력해주세요.',
                    hintStyle: TextStyle(
                      color: Color(0xFF8F9098),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF1F2024),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 등록 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006FFD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '행사 등록하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2E3036),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String placeholder,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFC5C6CC),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(
            color: Color(0xFF8F9098),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          color: Color(0xFF1F2024),
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          height: 1.43,
        ),
      ),
    );
  }
}
