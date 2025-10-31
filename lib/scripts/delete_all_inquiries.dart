import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  await Firebase.initializeApp();

  // 더미 데이터 삭제
  await deleteAllInquiries();

  print('✅ 모든 더미 데이터 삭제 완료!');
}

Future<void> deleteAllInquiries() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore.collection('inquiries').get();

    print('삭제할 민원 총 개수: ${querySnapshot.docs.length}');

    // 배치로 삭제
    final batch = firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
      print('삭제 예정: ${doc.id}');
    }

    await batch.commit();
    print('🗑️ 모든 민원 데이터가 삭제되었습니다.');
  } catch (e) {
    print('❌ 삭제 중 오류 발생: $e');
  }
}
