import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main/notification_screen.dart';
import '../../models/inquiry.dart';
import '../../repositories/inquiry_repository.dart';

/// 민원 등록 화면
class InquiryRegistrationScreen extends StatefulWidget {
  const InquiryRegistrationScreen({super.key});

  @override
  State<InquiryRegistrationScreen> createState() => _InquiryRegistrationScreenState();
}

class _InquiryRegistrationScreenState extends State<InquiryRegistrationScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _inquiryRepository = InquiryRepository();
  
  InquiryCategory? _selectedCategory;
  bool _isSubmitting = false;
  bool _agreeTerms = false;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '민원 등록',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          // 알림 아이콘
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              },
              child: const SizedBox(
                width: 28,
                height: 28,
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF2563EB),
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력
            _buildInputSection(
              '제목',
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFC5C6CC)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: '제목을 입력해주세요.',
                    hintStyle: TextStyle(
                      color: Color(0xFF8F9098),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 카테고리 선택
            _buildInputSection(
              '카테고리',
              GestureDetector(
                onTap: _showCategoryBottomSheet,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFC5C6CC)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory?.displayName ?? '카테고리를 선택해주세요.',
                        style: TextStyle(
                          color: _selectedCategory != null 
                              ? Colors.black 
                              : const Color(0xFF8F9098),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Color(0xFF8F9098)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 사진/동영상 첨부
            _buildInputSection(
              '사진/동영상 첨부',
              Container(
                height: 128,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 49,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB3DAFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 민원 내용
            _buildInputSection(
              '민원 내용',
              Container(
                height: 154,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFC5C6CC)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: '민원 내용을 입력해주세요.',
                    hintStyle: TextStyle(
                      color: Color(0xFF8F9098),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 약관 동의
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _agreeTerms = !_agreeTerms;
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _agreeTerms 
                            ? const Color(0xFF006FFD) 
                            : const Color(0xFFC5C6CC),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      color: _agreeTerms ? const Color(0xFF006FFD) : Colors.white,
                    ),
                    child: _agreeTerms 
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '민원 접수에 동의하며 ',
                          style: TextStyle(
                            color: Color(0xFF71727A),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const TextSpan(
                          text: '이용약관',
                          style: TextStyle(
                            color: Color(0xFF006FFD),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(
                          text: '과 ',
                          style: TextStyle(
                            color: Color(0xFF71727A),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const TextSpan(
                          text: '개인정보처리방침',
                          style: TextStyle(
                            color: Color(0xFF006FFD),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(
                          text: '에 동의합니다.',
                          style: TextStyle(
                            color: Color(0xFF71727A),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 등록 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _canSubmit() ? _submitInquiry : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006FFD),
                  disabledBackgroundColor: const Color(0xFFC5C6CC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '민원 등록',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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

  Widget _buildInputSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2E3036),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryBottomSheet(
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  bool _canSubmit() {
    return _titleController.text.isNotEmpty &&
           _contentController.text.isNotEmpty &&
           _selectedCategory != null &&
           _agreeTerms &&
           !_isSubmitting;
  }

  Future<void> _submitInquiry() async {
    if (!_canSubmit()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      final inquiry = Inquiry(
        id: '',
        userId: user.uid,
        userName: user.email ?? '알 수 없음',
        content: '${_titleController.text}\n\n${_contentController.text}',
        category: _selectedCategory!,
        status: InquiryStatus.registered,
        createdAt: DateTime.now(),
      );

      await _inquiryRepository.addInquiry(inquiry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('민원이 성공적으로 등록되었습니다.'),
            backgroundColor: Color(0xFF006FFD),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('민원 등록 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

/// 카테고리 선택 바텀시트
class CategoryBottomSheet extends StatefulWidget {
  final InquiryCategory? selectedCategory;
  final Function(InquiryCategory) onCategorySelected;

  const CategoryBottomSheet({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  InquiryCategory? _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 425,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '카테고리 선택',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 33,
                    height: 33,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6E6E6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // 카테고리 목록
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildCategoryItem(
                    InquiryCategory.living,
                    '학생생활',
                    '[동아리 / 학생회 등]',
                    Icons.groups,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryItem(
                    InquiryCategory.facility,
                    '안전 및 보안',
                    '[건물 문제 / 분실물 등]',
                    Icons.security,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryItem(
                    InquiryCategory.living,
                    '기숙사',
                    '[시설 / 보안 / 생활 등]',
                    Icons.home,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryItem(
                    InquiryCategory.academic,
                    '행정/학과',
                    '[행정 오류 / 학과 문의 등]',
                    Icons.school,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryItem(
                    InquiryCategory.other,
                    '기타 건의',
                    '',
                    Icons.more_horiz,
                  ),
                ],
              ),
            ),
          ),

          // 확인 버튼
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _tempSelected != null
                    ? () => widget.onCategorySelected(_tempSelected!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006FFD),
                  disabledBackgroundColor: const Color(0xFFC5C6CC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    InquiryCategory category,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _tempSelected == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tempSelected = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF006FFD) 
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF006FFD) 
                    : const Color(0xFFB4DBFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check : icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF4B4B4B),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF8F9098),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
