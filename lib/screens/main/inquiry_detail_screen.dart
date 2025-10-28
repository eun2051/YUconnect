import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/inquiry.dart';
import '../../repositories/inquiry_repository.dart';

/// 민원 상세 화면
class InquiryDetailScreen extends StatefulWidget {
  final Inquiry inquiry;
  final bool isAdmin;

  const InquiryDetailScreen({
    super.key,
    required this.inquiry,
    required this.isAdmin,
  });

  @override
  State<InquiryDetailScreen> createState() => _InquiryDetailScreenState();
}

class _InquiryDetailScreenState extends State<InquiryDetailScreen> {
  final InquiryRepository _inquiryRepository = InquiryRepository();
  late Inquiry _inquiry;

  @override
  void initState() {
    super.initState();
    _inquiry = widget.inquiry;
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 상태 배지 위젯
  Widget _buildStatusBadge(InquiryStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case InquiryStatus.registered:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        text = '등록됨';
        break;
      case InquiryStatus.inProgress:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        text = '진행중';
        break;
      case InquiryStatus.completed:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        text = '완료됨';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// 관리자 액션 버튼들
  Widget _buildAdminActions() {
    if (!widget.isAdmin || _inquiry.status == InquiryStatus.completed) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '관리자 작업',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_inquiry.status == InquiryStatus.registered) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(InquiryStatus.inProgress),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('처리 시작'),
                  ),
                ),
              ] else if (_inquiry.status == InquiryStatus.inProgress) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: _notifyDepartment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('부서 전달'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(InquiryStatus.completed),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('완료 처리'),
                  ),
                ),
              ],
            ],
          ),
          if (_inquiry.status != InquiryStatus.completed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _showResponseDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('답변 작성'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 민원 상태 업데이트
  Future<void> _updateStatus(InquiryStatus newStatus) async {
    try {
      await _inquiryRepository.updateInquiryStatus(_inquiry.id, newStatus);
      setState(() {
        _inquiry = _inquiry.copyWith(status: newStatus);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == InquiryStatus.inProgress 
                  ? '민원 처리를 시작했습니다.'
                  : '민원이 완료 처리되었습니다.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('상태 업데이트 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 부서 전달 알림
  Future<void> _notifyDepartment() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('해당 민원이 담당 부서에 전달되었습니다.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// 답변 작성 다이얼로그
  void _showResponseDialog() {
    final responseController = TextEditingController(text: _inquiry.adminResponse ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('답변 작성'),
        content: TextField(
          controller: responseController,
          decoration: const InputDecoration(
            labelText: '답변 내용',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (responseController.text.trim().isNotEmpty) {
                try {
                  await _inquiryRepository.updateInquiryResponse(
                    _inquiry.id,
                    responseController.text.trim(),
                  );
                  
                  setState(() {
                    _inquiry = _inquiry.copyWith(
                      adminResponse: responseController.text.trim(),
                    );
                  });
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('답변이 성공적으로 저장되었습니다.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('답변 저장 실패: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  /// 민원 편집
  void _editInquiry() {
    final contentController = TextEditingController(text: _inquiry.content);
    InquiryCategory selectedCategory = _inquiry.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('민원 편집'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<InquiryCategory>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(),
                  ),
                  items: InquiryCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.trim().isNotEmpty) {
                  try {
                    // Firestore에서 직접 업데이트
                    await FirebaseFirestore.instance
                        .collection('inquiries')
                        .doc(_inquiry.id)
                        .update({
                      'content': contentController.text.trim(),
                      'category': selectedCategory.value,
                      'updatedAt': Timestamp.now(),
                    });
                    
                    // 로컬 상태 업데이트
                    final updatedInquiry = _inquiry.copyWith(
                      content: contentController.text.trim(),
                      category: selectedCategory,
                    );
                    
                    if (mounted) {
                      setState(() {
                        _inquiry = updatedInquiry;
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('민원이 성공적으로 수정되었습니다.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('민원 수정 실패: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('수정'),
            ),
          ],
        ),
      ),
    );
  }

  /// 민원 삭제
  void _deleteInquiry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('민원 삭제'),
        content: const Text('정말로 이 민원을 삭제하시겠습니까?\n삭제된 민원은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _inquiryRepository.deleteInquiry(_inquiry.id);
                
                if (mounted) {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pop(); // 상세 화면 닫기
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('민원이 성공적으로 삭제되었습니다.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('민원 삭제 실패: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '민원 상세',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2024)),
        ),
        actions: [
          // 편집 버튼
          IconButton(
            onPressed: _editInquiry,
            icon: const Icon(Icons.edit, color: Color(0xFF1F2024)),
            tooltip: '편집',
          ),
          // 삭제 버튼
          IconButton(
            onPressed: _deleteInquiry,
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: '삭제',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상태 배지와 작성일
            Row(
              children: [
                _buildStatusBadge(_inquiry.status),
                const Spacer(),
                Text(
                  _formatDate(_inquiry.createdAt),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 기본 정보
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '작성자',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _inquiry.userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.category, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '카테고리',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _inquiry.category.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 민원 내용
            Text(
              '민원 내용',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _inquiry.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            
            // 답변 (있을 경우)
            if (_inquiry.adminResponse != null && _inquiry.adminResponse!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                '관리자 답변',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _inquiry.adminResponse!,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              if (_inquiry.responseAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  '답변일: ${_formatDate(_inquiry.responseAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
            
            // 관리자 액션 버튼들
            _buildAdminActions(),
          ],
        ),
      ),
    );
  }
}
