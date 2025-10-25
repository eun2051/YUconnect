import 'package:flutter/material.dart';
import 'new_home_screen.dart';
import 'notice_screen.dart';

/// 앱 메인 네비게이터 화면 (홈/영대공지/영대민원/프로필)
class MainScreen extends StatefulWidget {
  final int tabIndex;
  const MainScreen({Key? key, this.tabIndex = 0}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  // 홈화면의 탭 상태를 제어하기 위한 키
  final GlobalKey<NewHomeScreenState> _homeKey =
      GlobalKey<NewHomeScreenState>();
  final GlobalKey<NoticeScreenState> _noticeKey =
      GlobalKey<NoticeScreenState>();

  // 외부에서 탭을 변경할 수 있도록 메서드 추가
  void setTab(int index, {int? noticeTab}) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        _homeKey.currentState?.setTab(0);
      }
    });
    // 공지사항 탭 진입 시, noticeTab 파라미터로 NoticeScreen의 탭도 변경
    if (index == 1 && noticeTab != null) {
      _noticeKey.currentState?.setTab(noticeTab);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.tabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      NewHomeScreen(key: _homeKey),
      NoticeScreen(key: _noticeKey),
      Center(child: Text('영대민원')), // 임시
      Center(child: Text('프로필')), // 임시
    ];
    final navItems = [
      {'icon': Icons.explore, 'label': '홈'},
      {'icon': Icons.grid_view_rounded, 'label': '영대공지'},
      {'icon': Icons.store_mall_directory, 'label': '영대민원'},
      {'icon': Icons.person, 'label': '프로필'},
    ];
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (i) {
            final selected = _currentIndex == i;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = i;
                  if (i == 0) {
                    _homeKey.currentState?.setTab(0);
                  }
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  selected
                      ? Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            navItems[i]['icon'] as IconData,
                            color: Colors.white,
                            size: 24,
                          ),
                        )
                      : Icon(
                          navItems[i]['icon'] as IconData,
                          color: const Color(0xFFD1D5DB),
                          size: 28,
                        ),
                  const SizedBox(height: 6),
                  Text(
                    navItems[i]['label'] as String,
                    style: TextStyle(
                      color: selected ? Color(0xFF23272F) : Color(0xFFB0B5C3),
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
