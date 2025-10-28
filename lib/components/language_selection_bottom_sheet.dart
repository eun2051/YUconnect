import 'package:flutter/material.dart';

/// 언어 선택 바텀시트 (한국어/영어)
class LanguageSelectionBottomSheet extends StatefulWidget {
  const LanguageSelectionBottomSheet({super.key});

  @override
  State<LanguageSelectionBottomSheet> createState() =>
      _LanguageSelectionBottomSheetState();
}

class _LanguageSelectionBottomSheetState
    extends State<LanguageSelectionBottomSheet> {
  bool _isKorean = true; // 현재 한국어 여부 (true: 한국어, false: 영어)

  @override
  void initState() {
    super.initState();
    // TODO: SharedPreferences에서 현재 언어 상태 로드
  }

  /// 언어 선택 처리
  void _selectLanguage(bool isKorean) {
    setState(() {
      _isKorean = isKorean;
    });
  }

  /// 확인 버튼 처리
  void _confirmSelection() {
    // TODO: SharedPreferences에 선택된 언어 저장
    // TODO: 앱 전체 언어 변경 적용
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isKorean ? '한국어로 변경되었습니다.' : 'Language changed to English.',
        ),
        backgroundColor: const Color(0xFF006FFD),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 278,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: Stack(
        children: [
          // 제목
          const Positioned(
            left: 27,
            top: 27,
            child: Text(
              '언어 선택',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 닫기 버튼
          Positioned(
            left: 311,
            top: 27,
            child: GestureDetector(
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
          ),

          // 한국어 옵션
          Positioned(
            left: 18,
            top: 87,
            child: GestureDetector(
              onTap: () => _selectLanguage(true),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 4.30,
                          top: 4.30,
                          child: Container(
                            width: 34.40,
                            height: 34.40,
                            decoration: ShapeDecoration(
                              color: _isKorean
                                  ? const Color(0xFFB4DBFF)
                                  : Colors.grey[200],
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          top: 10,
                          child: Container(
                            width: 24,
                            height: 24,
                            child: Center(
                              child: Text(
                                '한',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _isKorean
                                      ? const Color(0xFF006FFD)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    '한국어',
                    style: TextStyle(
                      color: Color(0xFF4B4B4B),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 영어 옵션
          Positioned(
            left: 18,
            top: 147,
            child: GestureDetector(
              onTap: () => _selectLanguage(false),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 4.30,
                          top: 4.30,
                          child: Container(
                            width: 34.40,
                            height: 34.40,
                            decoration: ShapeDecoration(
                              color: !_isKorean
                                  ? const Color(0xFFB4DBFF)
                                  : Colors.grey[200],
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          top: 10,
                          child: Container(
                            width: 24,
                            height: 24,
                            child: Center(
                              child: Text(
                                'EN',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: !_isKorean
                                      ? const Color(0xFF006FFD)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    '영어',
                    style: TextStyle(
                      color: Color(0xFF4B4B4B),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 확인 버튼
          Positioned(
            left: 19,
            top: 208,
            child: GestureDetector(
              onTap: _confirmSelection,
              child: Container(
                width: 343,
                height: 50,
                decoration: const ShapeDecoration(
                  color: Color(0xFF006FFD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                child: const Center(
                  child: Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
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
