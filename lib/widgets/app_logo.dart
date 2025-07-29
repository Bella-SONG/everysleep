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
    final logoColor = color ?? Colors.white;
    
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(color: logoColor),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;
  
  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    // 달 그리기 - 더 부드러운 초승달
    final moonPath = Path();
    final centerX = size.width * 0.45;
    final centerY = size.height * 0.5;
    final radius = size.width * 0.25;
    
    // 외부 원
    moonPath.addOval(Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius,
    ));
    
    // 내부 원 (빼기용)
    final innerPath = Path();
    innerPath.addOval(Rect.fromCircle(
      center: Offset(centerX + radius * 0.4, centerY),
      radius: radius * 0.85,
    ));
    
    // 달 모양 만들기
    final moonFinal = Path.combine(
      PathOperation.difference,
      moonPath,
      innerPath,
    );
    
    canvas.drawPath(moonFinal, paint);
    
    // 별 그리기 - 미니멀한 4각 별
    _drawMinimalStar(
      canvas,
      Offset(size.width * 0.75, size.height * 0.3),
      size.width * 0.06,
      paint,
    );
    
    _drawMinimalStar(
      canvas,
      Offset(size.width * 0.82, size.height * 0.5),
      size.width * 0.045,
      paint,
    );
    
    _drawMinimalStar(
      canvas,
      Offset(size.width * 0.7, size.height * 0.65),
      size.width * 0.035,
      paint,
    );
  }
  
  void _drawMinimalStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // 4각 별 - 다이아몬드 모양
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size * 0.7, center.dy);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size * 0.7, center.dy);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}