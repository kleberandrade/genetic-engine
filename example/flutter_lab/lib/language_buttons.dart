import 'package:material_ui/material_ui.dart';

import 'lab_copy.dart';

String languageButtonLabel(LabLanguage language) =>
    language == LabLanguage.portuguese
    ? 'Português (Brasil)'
    : 'English (United Kingdom)';

/// Locally drawn, recognizable flags with no external asset dependency.
class LanguageButtons extends StatelessWidget {
  const LanguageButtons({super.key, required this.language, this.onChanged});
  final LabLanguage language;
  final ValueChanged<LabLanguage>? onChanged;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final value in [LabLanguage.portuguese, LabLanguage.english])
        Semantics(
          key: ValueKey('language-${value.code}'),
          button: true,
          selected: value == language,
          enabled: onChanged != null,
          label: languageButtonLabel(value),
          child: Tooltip(
            message: languageButtonLabel(value),
            excludeFromSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onChanged == null ? null : () => onChanged!(value),
              child: SizedBox.square(
                dimension: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: value == language
                              ? const Color(0xFF00695C)
                              : const Color(0xFF82958B),
                          width: value == language ? 3 : 1,
                        ),
                      ),
                      child: ExcludeSemantics(
                        child: ClipOval(
                          child: CustomPaint(painter: _FlagPainter(value)),
                        ),
                      ),
                    ),
                    if (value == language)
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00695C),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

class _FlagPainter extends CustomPainter {
  const _FlagPainter(this.language);
  final LabLanguage language;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 40, size.height / 40);
    if (language == LabLanguage.portuguese) {
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 40, 40),
        Paint()..color = const Color(0xFF009739),
      );
      canvas.drawPath(
        Path()
          ..moveTo(20, 5)
          ..lineTo(38, 20)
          ..lineTo(20, 35)
          ..lineTo(2, 20)
          ..close(),
        Paint()..color = const Color(0xFFFEDD00),
      );
      canvas.drawCircle(
        const Offset(20, 20),
        9,
        Paint()..color = const Color(0xFF012169),
      );
      canvas.save();
      canvas.clipPath(Path()..addOval(const Rect.fromLTWH(11, 11, 18, 18)));
      canvas.drawPath(
        Path()
          ..moveTo(10, 18)
          ..quadraticBezierTo(20, 13, 31, 22),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      for (final star in [
        Offset(17, 23),
        Offset(22, 25),
        Offset(24, 20),
        Offset(18, 18),
      ]) {
        canvas.drawCircle(star, .7, Paint()..color = Colors.white);
      }
      canvas.restore();
    } else {
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 40, 40),
        Paint()..color = const Color(0xFF012169),
      );
      void cross(double width, Color color, bool diagonal) {
        final paint = Paint()
          ..color = color
          ..strokeWidth = width;
        if (diagonal) {
          canvas.drawLine(const Offset(0, 0), const Offset(40, 40), paint);
          canvas.drawLine(const Offset(40, 0), const Offset(0, 40), paint);
        } else {
          canvas.drawLine(const Offset(20, 0), const Offset(20, 40), paint);
          canvas.drawLine(const Offset(0, 20), const Offset(40, 20), paint);
        }
      }

      cross(8, Colors.white, true);
      cross(3, const Color(0xFFC8102E), true);
      cross(12, Colors.white, false);
      cross(7, const Color(0xFFC8102E), false);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FlagPainter old) => old.language != language;
}
