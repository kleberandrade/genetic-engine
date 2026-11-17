import 'package:material_ui/material_ui.dart';

/// Original vector mark: two crossing genomes and a gold mutation node.
class GeneticMark extends StatelessWidget {
  const GeneticMark({super.key, required this.label, this.size = 40});
  final String label;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: label,
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MarkPainter()),
    ),
  );
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 64);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 64, 64),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFF00695C),
    );
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(18, 14)
        ..cubicTo(46, 26, 18, 38, 46, 50),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(46, 14)
        ..cubicTo(18, 26, 46, 38, 18, 50),
      paint,
    );
    for (final bar in [
      (18.0, 46.0, 14.0),
      (27.0, 37.0, 26.0),
      (27.0, 37.0, 38.0),
      (18.0, 46.0, 50.0),
    ]) {
      canvas.drawLine(
        Offset(bar.$1, bar.$3),
        Offset(bar.$2, bar.$3),
        paint..color = const Color(0xFFCAEAE0),
      );
    }
    canvas.drawCircle(
      const Offset(46, 50),
      5,
      Paint()..color = const Color(0xFFF3C766),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => false;
}
