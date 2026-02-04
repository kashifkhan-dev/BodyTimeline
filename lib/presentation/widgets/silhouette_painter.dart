import 'package:flutter/material.dart';
import '../../domain/value_objects/zone_type.dart';

class SilhouettePainter extends CustomPainter {
  final ZoneType mode;
  final bool showGuides;

  SilhouettePainter({required this.mode, this.showGuides = true});

  @override
  void paint(Canvas canvas, Size size) {
    if (!showGuides) return;

    final paint = Paint()
      ..color = Colors.white.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final guidePaint = Paint()
      ..color = Colors.white.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    switch (mode) {
      case ZoneType.face:
        _drawFaceSilhouette(canvas, size, paint, guidePaint);
        break;
      case ZoneType.bodyFront:
        _drawBodyFrontSilhouette(canvas, size, paint, guidePaint);
        break;
      case ZoneType.bodySide:
        _drawBodySideSilhouette(canvas, size, paint, guidePaint);
        break;
      default:
        break;
    }
  }

  void _drawFaceSilhouette(Canvas canvas, Size size, Paint paint, Paint guidePaint) {
    final centerX = size.width / 2;
    final w = size.width;
    final h = size.height;

    // RULE: Face fills ~65-70% of width, ~55-60% of height
    final faceWidth = w * 0.68;
    final faceHeight = h * 0.58;
    final centerY = h * 0.45;

    final path = Path();
    final rect = Rect.fromCenter(center: Offset(centerX, centerY), width: faceWidth, height: faceHeight);

    // Top forehead
    path.addArc(rect, 3.14, 3.14);

    // Defined jaw/chin curve
    path.moveTo(centerX - faceWidth / 2, centerY);
    path.quadraticBezierTo(
      centerX - faceWidth / 2,
      centerY + faceHeight * 0.4,
      centerX,
      centerY + faceHeight * 0.5, // Chin tip
    );
    path.quadraticBezierTo(centerX + faceWidth / 2, centerY + faceHeight * 0.4, centerX + faceWidth / 2, centerY);

    // Neck connecting naturally
    path.moveTo(centerX - faceWidth * 0.25, centerY + faceHeight * 0.45);
    path.lineTo(centerX - faceWidth * 0.35, centerY + faceHeight * 0.7);
    path.moveTo(centerX + faceWidth * 0.25, centerY + faceHeight * 0.45);
    path.lineTo(centerX + faceWidth * 0.35, centerY + faceHeight * 0.7);

    canvas.drawPath(path, paint);

    // Eye line and vertical center
    canvas.drawLine(Offset(centerX - faceWidth * 0.4, centerY), Offset(centerX + faceWidth * 0.4, centerY), guidePaint);
    canvas.drawLine(
      Offset(centerX, centerY - faceHeight * 0.4),
      Offset(centerX, centerY + faceHeight * 0.5),
      guidePaint,
    );
  }

  void _drawBodyFrontSilhouette(Canvas canvas, Size size, Paint paint, Paint guidePaint) {
    final centerX = size.width / 2;
    final h = size.height;
    final w = size.width;

    // RULE: Adjusting head-to-body ratio to ~6.5 heads tall for better visual anchor
    final silhouetteHeight = h * 0.85;
    final headHeight = silhouetteHeight / 6.5;
    final headWidth = headHeight * 0.8;
    final headTop = h * 0.05;

    final path = Path();

    // Head
    path.addOval(Rect.fromLTWH(centerX - headWidth / 2, headTop, headWidth, headHeight));

    // Neck
    final neckTop = headTop + headHeight;
    final neckBottom = neckTop + headHeight * 0.2;
    path.moveTo(centerX - headWidth * 0.3, neckTop);
    path.lineTo(centerX - headWidth * 0.3, neckBottom);
    path.moveTo(centerX + headWidth * 0.3, neckTop);
    path.lineTo(centerX + headWidth * 0.3, neckBottom);

    // Shoulders (RULE: ≈ 2.5-3 head widths)
    final shoulderWidth = headWidth * 2.8;
    final shoulderY = neckBottom + headHeight * 0.1;
    path.moveTo(centerX - shoulderWidth / 2, shoulderY);
    path.lineTo(centerX + shoulderWidth / 2, shoulderY);

    // Body Taper (Torso)
    final waistY = shoulderY + headHeight * 2;
    final waistWidth = headWidth * 1.8;
    final hipY = waistY + headHeight;
    final hipWidth = headWidth * 2.2;
    final feetY = shoulderY + headHeight * 7;

    path.moveTo(centerX - shoulderWidth / 2, shoulderY);
    path.quadraticBezierTo(centerX - waistWidth, waistY, centerX - hipWidth / 2, hipY);
    path.lineTo(centerX - headWidth * 0.6, feetY); // Left leg

    path.moveTo(centerX + shoulderWidth / 2, shoulderY);
    path.quadraticBezierTo(centerX + waistWidth, waistY, centerX + hipWidth / 2, hipY);
    path.lineTo(centerX + headWidth * 0.6, feetY); // Right leg

    canvas.drawPath(path, paint);

    // Vertical symmetry & baseline
    canvas.drawLine(Offset(centerX, headTop), Offset(centerX, feetY), guidePaint);
    canvas.drawLine(Offset(centerX - w * 0.3, feetY), Offset(centerX + w * 0.3, feetY), guidePaint);
  }

  void _drawBodySideSilhouette(Canvas canvas, Size size, Paint paint, Paint guidePaint) {
    final centerX = size.width / 2;
    final h = size.height;
    final w = size.width;

    final silhouetteHeight = h * 0.85;
    final headHeight = silhouetteHeight / 6.5;
    final headWidth = headHeight * 0.75;
    final headTop = h * 0.05;

    final path = Path();

    // Head Profile
    path.addOval(Rect.fromLTWH(centerX - headWidth / 2, headTop, headWidth, headHeight));

    final shoulderY = headTop + headHeight * 1.2;
    final waistY = shoulderY + headHeight * 2;
    final hipY = waistY + headHeight;
    final feetY = shoulderY + headHeight * 7;

    // Side Profile Line
    path.moveTo(centerX, headTop + headHeight); // Neck
    path.quadraticBezierTo(centerX + headWidth * 1.2, shoulderY + headHeight, centerX, waistY); // Chest
    path.quadraticBezierTo(centerX - headWidth * 0.5, hipY, centerX, feetY); // Back/Glute/Leg

    canvas.drawPath(path, paint);

    // Balance line & baseline
    canvas.drawLine(Offset(centerX, headTop), Offset(centerX, feetY), guidePaint);
    canvas.drawLine(Offset(centerX - w * 0.2, feetY), Offset(centerX + w * 0.2, feetY), guidePaint);
  }

  @override
  bool shouldRepaint(covariant SilhouettePainter oldDelegate) {
    return oldDelegate.mode != mode || oldDelegate.showGuides != showGuides;
  }
}
