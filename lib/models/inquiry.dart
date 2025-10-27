import 'package:cloud_firestore/cloud_firestore.dart';

/// 민원 상태 enum
enum InquiryStatus {
  registered('등록됨', 'registered'),
  inProgress('진행 중', 'in_progress'),
  completed('답변 완료', 'completed');

  const InquiryStatus(this.displayName, this.value);
  final String displayName;
  final String value;

  static InquiryStatus fromString(String value) {
    return InquiryStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => InquiryStatus.registered,
    );
  }
}

/// 민원 카테고리 enum
enum InquiryCategory {
  academic('학사', 'academic'),
  facility('시설', 'facility'),
  living('생활', 'living'),
  other('기타', 'other');

  const InquiryCategory(this.displayName, this.value);
  final String displayName;
  final String value;

  static InquiryCategory fromString(String value) {
    return InquiryCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => InquiryCategory.other,
    );
  }
}

/// 민원 모델
class Inquiry {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final InquiryCategory category;
  final InquiryStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminResponse;
  final DateTime? responseAt;
  final List<String> imageUrls;

  Inquiry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.category,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.adminResponse,
    this.responseAt,
    this.imageUrls = const [],
  });

  /// Firestore에서 생성
  factory Inquiry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Inquiry(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      content: data['content'] ?? '',
      category: InquiryCategory.fromString(data['category'] ?? 'other'),
      status: InquiryStatus.fromString(data['status'] ?? 'registered'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      adminResponse: data['adminResponse'],
      responseAt: (data['responseAt'] as Timestamp?)?.toDate(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'content': content,
      'category': category.value,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'adminResponse': adminResponse,
      'responseAt': responseAt != null ? Timestamp.fromDate(responseAt!) : null,
      'imageUrls': imageUrls,
    };
  }

  /// 복사본 생성
  Inquiry copyWith({
    String? id,
    String? userId,
    String? userName,
    String? content,
    InquiryCategory? category,
    InquiryStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminResponse,
    DateTime? responseAt,
    List<String>? imageUrls,
  }) {
    return Inquiry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminResponse: adminResponse ?? this.adminResponse,
      responseAt: responseAt ?? this.responseAt,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}
