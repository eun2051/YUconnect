import 'package:flutter/material.dart';

/// 라인형 라운드 벨(알림) 아이콘 위젯
class LineRoundedBell extends StatelessWidget {
  const LineRoundedBell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 20.42,
          height: 20.42,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(),
          child: Stack(),
        ),
      ],
    );
  }
}
