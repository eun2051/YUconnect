import 'package:flutter/material.dart';

/// 모드 선택 바텀시트 (다크모드/라이트모드)
class ModeSelectionBottomSheet extends StatefulWidget {
  const ModeSelectionBottomSheet({super.key});

  @override
  State<ModeSelectionBottomSheet> createState() =>
      _ModeSelectionBottomSheetState();
}

class _ModeSelectionBottomSheetState extends State<ModeSelectionBottomSheet> {
  bool _isDarkMode = false; // 현재 다크모드 여부

  @override
  void initState() {
    super.initState();
    // TODO: SharedPreferences에서 현재 모드 상태 로드
  }

  /// 모드 선택 처리
  void _selectMode(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  /// 확인 버튼 처리
  void _confirmSelection() {
    // TODO: SharedPreferences에 선택된 모드 저장
    // TODO: 테마 변경 적용
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isDarkMode ? '다크 모드로 변경되었습니다.' : '라이트 모드로 변경되었습니다.'),
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
              '모드 선택',
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

          // 다크 모드 옵션
          Positioned(
            left: 18,
            top: 87,
            child: GestureDetector(
              onTap: () => _selectMode(true),
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
                              color: _isDarkMode
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
                            child: Icon(
                              Icons.dark_mode,
                              size: 20,
                              color: _isDarkMode
                                  ? const Color(0xFF006FFD)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    '다크 모드',
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

          // 라이트 모드 옵션
          Positioned(
            left: 18,
            top: 147,
            child: GestureDetector(
              onTap: () => _selectMode(false),
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
                              color: !_isDarkMode
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
                            child: Icon(
                              Icons.light_mode,
                              size: 20,
                              color: !_isDarkMode
                                  ? const Color(0xFF006FFD)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    '라이트 모드',
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
