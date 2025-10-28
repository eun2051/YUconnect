import 'package:flutter/material.dart';
import '../models/inquiry.dart';
import '../repositories/inquiry_repository.dart';
import './expandable_inquiry_card.dart';

/// 민원 조회 바텀시트 - 모든 민원을 날짜순으로 표시
class InquirySearchBottomSheet extends StatefulWidget {
  const InquirySearchBottomSheet({super.key});

  @override
  State<InquirySearchBottomSheet> createState() =>
      _InquirySearchBottomSheetState();
}

class _InquirySearchBottomSheetState extends State<InquirySearchBottomSheet> {
  final InquiryRepository _inquiryRepository = InquiryRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Inquiry> _allInquiries = [];
  List<Inquiry> _filteredInquiries = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllInquiries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 모든 민원 로드 - 날짜순 정렬
  Future<void> _loadAllInquiries() async {
    try {
      final allInquiries = await _inquiryRepository.getAllInquiries().first;
      // 최신순으로 정렬
      allInquiries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _allInquiries = allInquiries;
        _filteredInquiries = allInquiries; // 초기에는 모든 민원 표시
        _isLoading = false;
      });

      print('🔥 민원 로드 완료: ${allInquiries.length}개'); // 디버그용
    } catch (e) {
      print('❌ 민원 로드 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 검색 실행
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.trim().isEmpty) {
        _filteredInquiries = _allInquiries; // 검색어가 없으면 모든 민원 표시
      } else {
        _filteredInquiries = _allInquiries.where((inquiry) {
          return inquiry.content.toLowerCase().contains(query.toLowerCase()) ||
              inquiry.category.displayName.toLowerCase().contains(
                query.toLowerCase(),
              );
        }).toList();
      }
    });
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
          // 드래그 핸들 - 눈에 띄게 빨간색
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red, // 🔥 변경 확인용
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF006FFD), size: 24),
                const SizedBox(width: 12),
                const Text(
                  '민원 조회 📋', // 🔥 변경 확인용
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2024),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Color(0xFF71727A)),
                ),
              ],
            ),
          ),

          // 검색 입력 필드
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: '민원 내용이나 카테고리로 검색하세요',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                        icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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

          // 민원 목록
          Expanded(child: _buildInquiryList()),
        ],
      ),
    );
  }

  /// 민원 목록 위젯
  Widget _buildInquiryList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF006FFD)),
            SizedBox(height: 16),
            Text(
              '민원을 불러오는 중...',
              style: TextStyle(fontSize: 16, color: Color(0xFF71727A)),
            ),
          ],
        ),
      );
    }

    if (_filteredInquiries.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
            Text(
              '"$_searchQuery"에 대한\n검색 결과가 없습니다',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_filteredInquiries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Color(0xFFE5E7EB)),
            SizedBox(height: 16),
            Text(
              '등록된 민원이 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 민원 개수 표시
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF006FFD).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                _searchQuery.isEmpty ? Icons.inbox : Icons.search,
                color: const Color(0xFF006FFD),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _searchQuery.isEmpty
                    ? '전체 민원 ${_filteredInquiries.length}개 (최신순)'
                    : '검색 결과 ${_filteredInquiries.length}개',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006FFD),
                ),
              ),
            ],
          ),
        ),

        // 민원 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filteredInquiries.length,
            itemBuilder: (context, index) {
              final inquiry = _filteredInquiries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ExpandableInquiryCard(
                  inquiry: inquiry,
                  isAdminMode: false, // 바텀시트에서는 항상 사용자 모드
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
