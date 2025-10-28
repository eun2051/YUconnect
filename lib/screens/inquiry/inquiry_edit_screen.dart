import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/inquiry.dart';
import '../../repositories/inquiry_repository.dart';

/// 민원 편집 화면
/// 사용자가 등록된 상태의 민원을 편집할 수 있는 폼
class InquiryEditScreen extends StatefulWidget {
  final Inquiry inquiry;

  const InquiryEditScreen({super.key, required this.inquiry});

  @override
  State<InquiryEditScreen> createState() => _InquiryEditScreenState();
}

class _InquiryEditScreenState extends State<InquiryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _inquiryRepository = InquiryRepository();

  String? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 기존 민원 데이터로 초기화
    _titleController = TextEditingController(text: widget.inquiry.title);
    _contentController = TextEditingController(text: widget.inquiry.content);
    _selectedCategory = widget.inquiry.category.value;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1F2024),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '민원 수정',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 선택
                    _buildCategorySection(),
                    const SizedBox(height: 32),

                    // 제목 입력
                    _buildTitleSection(),
                    const SizedBox(height: 24),

                    // 내용 입력
                    _buildContentSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  /// 카테고리 선택 섹션
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '카테고리 선택',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildCategoryGrid(),
      ],
    );
  }

  /// 카테고리 그리드
  Widget _buildCategoryGrid() {
    final categories = [
      {'value': 'academic', 'label': '학사문의', 'icon': Icons.school},
      {'value': 'facility', 'label': '시설관리', 'icon': Icons.business},
      {'value': 'living', 'label': '생활관련', 'icon': Icons.home},
      {'value': 'other', 'label': '기타문의', 'icon': Icons.more_horiz},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategory == category['value'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category['value'] as String;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFB4DBFF)
                  : const Color(0xFFF7F8FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF006FFD)
                    : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: isSelected
                      ? const Color(0xFF006FFD)
                      : const Color(0xFF71727A),
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  category['label'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF006FFD)
                        : const Color(0xFF71727A),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 제목 입력 섹션
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '제목',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: '민원 제목을 입력해주세요',
            hintStyle: const TextStyle(
              color: Color(0xFFB0B3B8),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF7F8FD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF006FFD), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '제목을 입력해주세요';
            }
            if (value.trim().length < 5) {
              return '제목은 5자 이상 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 내용 입력 섹션
  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '상세 내용',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _contentController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: '민원 내용을 자세히 작성해주세요',
            hintStyle: const TextStyle(
              color: Color(0xFFB0B3B8),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF7F8FD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF006FFD), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '내용을 입력해주세요';
            }
            if (value.trim().length < 10) {
              return '내용은 10자 이상 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 하단 버튼들
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 취소 버튼
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Center(
                    child: Text(
                      '취소',
                      style: TextStyle(
                        color: Color(0xFF71727A),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 수정 완료 버튼
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _isSubmitting ? null : _submitForm,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isSubmitting
                        ? const Color(0xFFB0B3B8)
                        : const Color(0xFF006FFD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            '수정 완료',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 폼 제출
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      _showErrorSnackBar('카테고리를 선택해주세요');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar('로그인이 필요합니다');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final category = InquiryCategory.values.firstWhere(
        (c) => c.value == _selectedCategory,
      );

      await _inquiryRepository.updateInquiry(
        inquiryId: widget.inquiry.id,
        userId: user.uid,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: category,
      );

      if (mounted) {
        _showSuccessSnackBar('민원이 성공적으로 수정되었습니다');
        Navigator.pop(context, true); // true를 반환하여 수정됨을 알림
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 에러 스낵바 표시
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// 성공 스낵바 표시
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
