import 'package:flutter/material.dart';
import '../models/inquiry.dart';
import '../repositories/inquiry_repository.dart';
import '../screens/inquiry/inquiry_detail_screen.dart';

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

  /// 민원 상세 페이지로 이동
  void _navigateToDetail(Inquiry inquiry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InquiryDetailScreen(inquiry: inquiry),
      ),
    );
  }

  /// 상태별 색상
  Color _getStatusColor(InquiryStatus status) {
    switch (status) {
      case InquiryStatus.registered:
        return const Color(0xFF006FFD);
      case InquiryStatus.inProgress:
        return const Color(0xFFF59E0B);
      case InquiryStatus.completed:
        return const Color(0xFF10B981);
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
              final statusColor = _getStatusColor(inquiry.status);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withOpacity(0.2),
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _navigateToDetail(inquiry),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // 상태 컬러 바
                          Container(
                            width: 4,
                            height: 60,
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // 민원 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 카테고리와 상태
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        inquiry.category.displayName,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        inquiry.status.displayName,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // 민원 내용
                                Text(
                                  inquiry.content,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2024),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),

                                // 등록일
                                Text(
                                  '등록일: ${inquiry.createdAt.year}년 ${inquiry.createdAt.month}월 ${inquiry.createdAt.day}일',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 화살표 아이콘
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF9CA3AF),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
