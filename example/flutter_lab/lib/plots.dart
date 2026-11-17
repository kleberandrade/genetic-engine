import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:genetic_engine/genetic_engine.dart';

import 'lab_model.dart';
import 'lab_copy.dart';

const _teal = Color(0xFF00695C);
const _amber = Color(0xFF966400);
void _text(
  Canvas canvas,
  String text,
  Offset point, {
  Color color = const Color(0xFF182C36),
  double size = 12,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: size),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, point);
}

class GenomePainter extends CustomPainter {
  GenomePainter(this.problem, this.genome);
  final Problem problem;
  final List<int> genome;
  @override
  void paint(Canvas canvas, Size size) {
    switch (problem) {
      case Problem.oneMax:
        final cell = min(size.width / 8, size.height / 4);
        final origin = Offset((size.width - cell * 8) / 2, 0);
        for (var i = 0; i < 32; i++) {
          final rect = Rect.fromLTWH(
            origin.dx + i % 8 * cell + 3,
            i ~/ 8 * cell + 3,
            cell - 6,
            cell - 6,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(6)),
            Paint()..color = genome[i] == 1 ? _teal : const Color(0xFFE6EBE5),
          );
          _text(
            canvas,
            '${genome[i]}',
            rect.center - const Offset(5, 9),
            color: genome[i] == 1 ? Colors.white : const Color(0xFF344E55),
            size: 16,
          );
        }
      case Problem.queens:
        final cell = min(size.width, size.height) / 8;
        final left = (size.width - cell * 8) / 2;
        for (var row = 0; row < 8; row++) {
          for (var col = 0; col < 8; col++) {
            final rect = Rect.fromLTWH(
              left + col * cell,
              row * cell,
              cell,
              cell,
            );
            canvas.drawRect(
              rect,
              Paint()
                ..color = (row + col).isEven
                    ? const Color(0xFFE6EBE5)
                    : const Color(0xFFB8C9BC),
            );
            if (genome[col] == row) {
              canvas.drawCircle(
                rect.center,
                cell * .33,
                Paint()..color = _teal,
              );
              _text(
                canvas,
                'Q',
                rect.center - Offset(cell * .16, cell * .27),
                color: Colors.white,
                size: cell * .45,
              );
            }
          }
        }
      case Problem.salesman:
        Offset location(int i) => Offset(
          16 + cities[i].x * (size.width - 32),
          12 + cities[i].y * (size.height - 24),
        );
        final path = Path()
          ..moveTo(location(genome.first).dx, location(genome.first).dy);
        for (final city in genome.skip(1)) {
          path.lineTo(location(city).dx, location(city).dy);
        }
        path.close();
        canvas.drawPath(
          path,
          Paint()
            ..color = _teal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
        for (var i = 0; i < cities.length; i++) {
          canvas.drawCircle(location(i), 13, Paint()..color = _teal);
          _text(
            canvas,
            '$i',
            location(i) - const Offset(4, 8),
            color: Colors.white,
          );
        }
    }
  }

  @override
  bool shouldRepaint(GenomePainter old) =>
      old.problem != problem || old.genome != genome;
}

class HistoryPainter extends CustomPainter {
  HistoryPainter(
    this.history, {
    this.copy = const LabCopy(LabLanguage.english),
  });
  final LabCopy copy;
  final List<Generation<List<int>>> history;
  @override
  void paint(Canvas canvas, Size size) {
    final maxY = max(1.0, history.map((g) => g.meanFitness).reduce(max));
    final plot = Rect.fromLTWH(
      40,
      8,
      max(1, size.width - 54),
      size.height - 32,
    );
    final axis = Paint()
      ..color = const Color(0xFFDCE2DA)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = plot.bottom - plot.height * i / 4;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), axis);
      _text(
        canvas,
        (maxY * i / 4).toStringAsFixed(1),
        Offset(0, y - 6),
        size: 10,
      );
    }
    _text(canvas, '0', Offset(plot.left, plot.bottom + 5), size: 10);
    _text(
      canvas,
      '${copy.text(LabText.generation)} ${history.last.index}',
      Offset(max(plot.left, plot.right - 105), plot.bottom + 5),
      size: 10,
    );
    void line(
      double Function(Generation<List<int>>) score,
      Color color,
      bool dashed,
    ) {
      final points = List.generate(
        history.length,
        (i) => Offset(
          plot.left + plot.width * i / max(1, history.length - 1),
          plot.bottom - plot.height * score(history[i]) / maxY,
        ),
      );
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      if (points.length == 1) {
        canvas.drawCircle(points.first, 3, Paint()..color = color);
      }
      for (var i = 1; i < points.length; i++) {
        if (!dashed) {
          canvas.drawLine(points[i - 1], points[i], paint);
        } else {
          final a = points[i - 1], b = points[i];
          final distance = (b - a).distance;
          for (double d = 0; d < distance; d += 10) {
            canvas.drawLine(
              Offset.lerp(a, b, d / distance)!,
              Offset.lerp(a, b, min(d + 6, distance) / distance)!,
              paint,
            );
          }
        }
      }
    }

    line((g) => g.meanFitness, _amber, true);
    line((g) => g.best.fitness, _teal, false);
  }

  @override
  bool shouldRepaint(HistoryPainter old) => true;
}
