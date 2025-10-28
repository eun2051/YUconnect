import 'package:cloud_firestore/cloud_firestore.dart';

/// 공지사항 모델
class Notice {
  final String id;
  final String title;
  final String content;
  final DateTime publishDate;
  final String author;
  final String department;
  final List<String> attachments;
  final int viewCount;
  final bool isImportant;
  final String category;
  final String? originalUrl; // 원본 공지사항 URL

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.publishDate,
    required this.author,
    required this.department,
    this.attachments = const [],
    this.viewCount = 0,
    this.isImportant = false,
    this.category = '일반',
    this.originalUrl,
  });

  /// Firestore 문서로부터 Notice 객체 생성
  factory Notice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Notice(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      publishDate: (data['publishDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      author: data['author'] ?? '',
      department: data['department'] ?? '',
      attachments: List<String>.from(data['attachments'] ?? []),
      viewCount: data['viewCount'] ?? 0,
      isImportant: data['isImportant'] ?? false,
      category: data['category'] ?? '일반',
      originalUrl: data['originalUrl'],
    );
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'publishDate': Timestamp.fromDate(publishDate),
      'author': author,
      'department': department,
      'attachments': attachments,
      'viewCount': viewCount,
      'isImportant': isImportant,
      'category': category,
      'originalUrl': originalUrl,
    };
  }

  /// 샘플 데이터 생성 (테스트용)
  factory Notice.sample({
    String? title,
    String? content,
    DateTime? publishDate,
    String? author,
    String? department,
  }) {
    return Notice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? '샘플 공지사항',
      content: content ?? '이것은 샘플 공지사항 내용입니다.',
      publishDate: publishDate ?? DateTime.now(),
      author: author ?? '관리자',
      department: department ?? '학생처',
      category: '일반',
    );
  }
}
