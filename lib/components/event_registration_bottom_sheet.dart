import 'package:flutter/material.dart';
import 'dart:io';
import '../models/student_event.dart';
import '../services/student_event_service.dart';
import '../services/image_service.dart';
import 'popup_calendar_new.dart';

/// 총학생회 행사 등록 바텀시트
class EventRegistrationBottomSheet extends StatefulWidget {
  const EventRegistrationBottomSheet({super.key});

  @override
  State<EventRegistrationBottomSheet> createState() =>
      _EventRegistrationBottomSheetState();
}

class _EventRegistrationBottomSheetState
    extends State<EventRegistrationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dateFieldKey = GlobalKey(); // 날짜 필드 위치 추적용
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  // 사진 관련 상태 변수
  File? _selectedImage;
  bool _isImageUploading = false;

  final ImageService _imageService = ImageService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final result = await showPopupCalendar(
      context: context,
      selectedDate: _selectedDate,
      // 간단한 위치 지정: 화면 중앙 상단
      position: const Offset(80, 150), // 좌측에서 80px, 상단에서 150px
    );

    if (result != null) {
      setState(() {
        _selectedDate = result;
      });
    }
  }

  Future<void> _selectImage() async {
    try {
      setState(() {
        _isImageUploading = true;
      });

      final File? image = await _imageService.showImagePickerDialog(context);

      if (image != null) {
        // 이미지 파일 유효성 검사
        if (_imageService.isValidImageFile(image)) {
          setState(() {
            _selectedImage = image;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('지원하지 않는 파일 형식이거나 파일 크기가 10MB를 초과합니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미지 선택 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isImageUploading = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 필드를 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 이벤트 ID 생성
      final eventId = DateTime.now().millisecondsSinceEpoch.toString();
      String? imageUrl;

      // 이미지가 선택된 경우 Firebase Storage에 업로드
      if (_selectedImage != null) {
        imageUrl = await _imageService.uploadImageToFirebase(
          _selectedImage!,
          eventId,
        );
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이미지 업로드에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final newEvent = StudentEvent(
        id: eventId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        eventDate: _selectedDate!,
        createdAt: DateTime.now(),
        createdBy: 'current_user', // 실제로는 현재 로그인한 사용자 ID
        imageUrl: imageUrl, // 이미지 URL 추가
      );

      final success = await StudentEventService.addEvent(newEvent);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('행사가 성공적으로 등록되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // 성공 시 true 반환
      } else {
        // 실패 시 업로드된 이미지 삭제
        if (imageUrl != null) {
          await _imageService.deleteImageFromFirebase(imageUrl);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('행사 등록에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('행사 등록 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 핸들바
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 스크롤 가능한 폼 영역
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '행사 등록',
                          style: TextStyle(
                            color: Color(0xFF1F2024),
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.10,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 제목 입력
                    _buildFieldLabel('제목'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _titleController,
                      hintText: '제목을 입력해주세요.',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '제목을 입력해주세요.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 날짜 선택
                    _buildFieldLabel('날짜'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      key: _dateFieldKey,
                      onTap: _selectDate,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0xFFC5C6CC),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                                  : '행사 날짜를 선택해주세요.',
                              style: TextStyle(
                                color: _selectedDate != null
                                    ? const Color(0xFF1F2024)
                                    : const Color(0xFF8F9098),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF8F9098),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 사진/동영상 첨부
                    _buildFieldLabel('사진 첨부'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _isImageUploading ? null : _selectImage,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          minHeight: 100,
                          maxHeight: 200,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEAF2FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: _selectedImage != null
                                  ? const Color(0xFF006FFD)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: _selectedImage != null
                            ? _buildSelectedImage()
                            : _buildImagePlaceholder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 행사 내용
                    _buildFieldLabel('행사 내용'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descriptionController,
                      hintText: '행사 내용을 입력해주세요.',
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '행사 내용을 입력해주세요.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // 등록 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006FFD),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                '행사 등록',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF2E3036),
        fontSize: 12,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF8F9098),
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          height: 1.43,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1, color: Color(0xFFC5C6CC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1, color: Color(0xFFC5C6CC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2, color: Color(0xFF006FFD)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1, color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isImageUploading)
          const CircularProgressIndicator(
            color: Color(0xFF006FFD),
            strokeWidth: 2,
          )
        else ...[
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFB3DAFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_photo_alternate,
              color: Color(0xFF006FFD),
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '사진을 선택해주세요',
            style: TextStyle(
              color: Color(0xFF006FFD),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '탭해서 카메라/갤러리에서 선택',
            style: TextStyle(
              color: Color(0xFF8F9098),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImage!,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(_imageService.getImageSizeInMB(_selectedImage!)).toStringAsFixed(1)}MB',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
