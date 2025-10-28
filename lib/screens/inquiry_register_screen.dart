import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/inquiry.dart';
import '../repositories/inquiry_repository.dart';
import '../services/user_profile_service.dart';

/// 민원 등록 화면
class InquiryRegisterScreen extends StatefulWidget {
  const InquiryRegisterScreen({super.key});

  @override
  State<InquiryRegisterScreen> createState() => _InquiryRegisterScreenState();
}

class _InquiryRegisterScreenState extends State<InquiryRegisterScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _inquiryRepository = InquiryRepository();
  final _userProfileService = UserProfileService();
  final _imagePicker = ImagePicker();
  
  String? _selectedCategory;
  InquiryCategory? _selectedCategoryEnum;
  final List<File> _selectedImages = [];
  bool _isLoading = false;

  // 카테고리 목록
  final List<Map<String, dynamic>> _categories = [
    {'name': '학생생활', 'description': '[동아리 / 학생회 등]', 'category': InquiryCategory.living},
    {'name': '안전 및 보안', 'description': '[건물 문제 / 분실물 등]', 'category': InquiryCategory.facility},
    {'name': '기숙사', 'description': '[시설 / 보안 / 생활 등]', 'category': InquiryCategory.living},
    {'name': '행정/학과', 'description': '[행정 오류 / 학과 문의 등]', 'category': InquiryCategory.academic},
    {'name': '기타 건의', 'description': '[기타 모든 건의사항]', 'category': InquiryCategory.other},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 카테고리 선택 바텀시트 표시
  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CategoryBottomSheet(
        categories: _categories,
        selectedCategory: _selectedCategory,
        onCategorySelected: (categoryName, categoryEnum) {
          setState(() {
            _selectedCategory = categoryName;
            _selectedCategoryEnum = categoryEnum;
          });
        },
      ),
    );
  }

  /// 이미지 선택
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지를 선택하는 중 오류가 발생했습니다: $e')),
      );
    }
  }

  /// 이미지 제거
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// 민원 등록
  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryEnum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인이 필요합니다.');

      // 사용자 이름 가져오기
      final userName = await _userProfileService.getUserName(user.uid);

      // 제목과 내용을 합쳐서 content로 저장
      final fullContent = '제목: ${_titleController.text.trim()}\n\n${_contentController.text.trim()}';

      final inquiry = Inquiry(
        id: '',
        content: fullContent,
        category: _selectedCategoryEnum!,
        userId: user.uid,
        userName: userName,
        status: InquiryStatus.registered,
        createdAt: DateTime.now(),
        imageUrls: [], // TODO: 이미지 업로드 구현
      );

      await _inquiryRepository.addInquiry(inquiry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('민원이 성공적으로 등록되었습니다.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('민원 등록 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '민원 등록',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 22,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), // 상단 패딩을 24로 설정
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 입력
              _buildInputSection(
                label: '제목',
                child: _buildTextField(
                  controller: _titleController,
                  hintText: '제목을 입력해주세요.',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '제목을 입력해주세요.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24), // 12에서 24로 증가
              
              // 카테고리 선택
              _buildInputSection(
                label: '카테고리',
                child: _buildCategorySelector(),
              ),
              const SizedBox(height: 24), // 12에서 24로 증가
              
              // 사진/동영상 첨부
              _buildInputSection(
                label: '사진/동영상 첨부',
                child: _buildImageUploadSection(),
              ),
              const SizedBox(height: 24), // 12에서 24로 증가
              
              // 민원 내용
              _buildInputSection(
                label: '민원 내용',
                child: _buildTextField(
                  controller: _contentController,
                  hintText: '민원 내용을 입력해주세요.',
                  maxLines: 6,
                  height: 154,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '민원 내용을 입력해주세요.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32), // 24에서 32로 증가
              
              // 등록 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitInquiry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006FFD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
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
      ),
    );
  }

  Widget _buildInputSection({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2E3036),
            fontSize: 16, // 12에서 16으로 증가
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12), // 8에서 12로 증가
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    double? height,
    String? Function(String?)? validator,
  }) {
    return Container(
      width: double.infinity,
      height: height ?? 48,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFC5C6CC)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF8F9098),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return GestureDetector(
      onTap: _showCategoryBottomSheet,
      child: Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFC5C6CC)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedCategory ?? '카테고리를 선택해주세요.',
                style: TextStyle(
                  color: _selectedCategory != null 
                      ? const Color(0xFF2E3036)
                      : const Color(0xFF8F9098),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8F9098)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 100, // 높이를 더 줄임
            padding: const EdgeInsets.all(16), // 패딩을 더 줄임
            decoration: ShapeDecoration(
              color: const Color(0xFFEAF2FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, // 아이콘 크기 줄임
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB3DAFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20, // 아이콘 사이즈 줄임
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '사진 추가',
                  style: TextStyle(
                    color: Color(0xFF006FFD),
                    fontSize: 11, // 폰트 사이즈 줄임
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// 카테고리 선택 바텀시트
class _CategoryBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategory;
  final Function(String, InquiryCategory) onCategorySelected;

  const _CategoryBottomSheet({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<_CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<_CategoryBottomSheet> {
  String? _tempSelectedCategory;
  InquiryCategory? _tempSelectedCategoryEnum;

  @override
  void initState() {
    super.initState();
    _tempSelectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, // 화면 높이의 60%로 조정
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(27, 24, 27, 16), // 상단 29에서 24로, 하단 20에서 16으로 줄임
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '카테고리 선택',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 33,
                    height: 33,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFE6E6E6),
                      shape: OvalBorder(),
                    ),
                    child: const Icon(Icons.close, size: 18, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          
          // 카테고리 목록
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0), // 위쪽에 12px 패딩으로 헤더와 간격 조정
              child: Column(
                children: widget.categories.map((category) {
                  final isSelected = _tempSelectedCategory == category['name'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16), // 4에서 16으로 다시 넓힘
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _tempSelectedCategory = category['name'];
                          _tempSelectedCategoryEnum = category['category'];
                        });
                      },
                      child: Row(
                        children: [
                          // 선택 표시
                          Container(
                            width: 32,
                            height: 32,
                            decoration: ShapeDecoration(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: isSelected 
                                      ? const Color(0xFF0078D4) 
                                      : const Color(0xFFE6E6E6),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Color(0xFF0078D4),
                                    size: 16,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          
                          // 카테고리 이름과 설명
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category['name']!,
                                  style: const TextStyle(
                                    color: Color(0xFF4B4B4B),
                                    fontSize: 18, // 16에서 18로 폰트 크기 증가
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500, // w400에서 w500으로 조금 더 굵게
                                  ),
                                ),
                                Text(
                                  category['description']!,
                                  style: const TextStyle(
                                    color: Color(0xFF8F9098),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.43,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // 확인 버튼
          Transform.translate(
            offset: const Offset(0, -24), // 버튼을 위로 24px 더 강하게 끌어올림
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32), // 위 패딩을 4에서 0으로 완전히 제거
            child: GestureDetector(
              onTap: () {
                if (_tempSelectedCategory != null && _tempSelectedCategoryEnum != null) {
                  widget.onCategorySelected(_tempSelectedCategory!, _tempSelectedCategoryEnum!);
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: ShapeDecoration(
                  color: _tempSelectedCategory != null 
                      ? const Color(0xFF006FFD)
                      : const Color(0xFFE6E6E6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    '확인',
                    style: TextStyle(
                      color: _tempSelectedCategory != null 
                          ? Colors.white 
                          : const Color(0xFF8F9098),
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}
