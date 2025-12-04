import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/theme.dart';

class FHHLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool useImage; // Toggle between image and custom paint

  const FHHLogo({
    super.key,
    this.size = 120,
    this.showText = true,
    this.useImage = true, // Default to use image if available
  });

  @override
  Widget build(BuildContext context) {
    // Try to use the actual logo image first
    if (useImage) {
      return _buildImageLogo();
    }

    // Fallback to custom drawn logo
    return _buildCustomLogo();
  }

  Widget _buildImageLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/fhh_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // If image fails to load, show custom painted logo
            return _buildCustomLogo();
          },
        ),
      ),
    );
  }

  Widget _buildCustomLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Two interlocking gears
          CustomPaint(size: Size(size, size), painter: GearLogoPainter()),
          // FKK Text overlay
          if (showText)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FKK',
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accentColor,
                    fontFamily: 'Poppins',
                    letterSpacing: 2,
                    height: 1,
                  ),
                ),
                Text(
                  'ENTERPRISE',
                  style: TextStyle(
                    fontSize: size * 0.07,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Poppins',
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class GearLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final gearRadius = size.width * 0.18;

    // Draw left black gear
    _drawGear(
      canvas,
      Offset(center.dx - gearRadius * 1.3, center.dy),
      gearRadius,
      AppTheme.primaryColor,
      0,
    );

    // Draw right red gear
    _drawGear(
      canvas,
      Offset(center.dx + gearRadius * 1.3, center.dy),
      gearRadius,
      AppTheme.accentColor,
      math.pi / 10,
    );
  }

  void _drawGear(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double rotation,
  ) {
    const teeth = 10;
    const toothHeight = 0.25;
    const innerRadiusRatio = 0.55;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0; i < teeth * 2; i++) {
      final angle = (i * math.pi / teeth) + rotation;
      final r = i.isEven ? radius : radius * (1 + toothHeight);

      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);

    // Draw inner circle (white center)
    canvas.drawCircle(
      center,
      radius * innerRadiusRatio,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Draw center hole
    canvas.drawCircle(
      center,
      radius * 0.15,
      Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Simple gear icon widget
class GearIcon extends StatelessWidget {
  final double size;
  final Color color;

  const GearIcon({super.key, this.size = 60, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.settings, size: size, color: color);
  }
}
