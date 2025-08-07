import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;
  
  const AppLogo({
    super.key,
    this.size = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/everysleep_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        // 색상 필터링이 필요한 경우 사용 (옵션)
        color: color,
        colorBlendMode: color != null ? BlendMode.srcIn : null,
      ),
    );
  }
}