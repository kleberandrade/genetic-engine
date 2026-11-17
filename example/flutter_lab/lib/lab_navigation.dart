import 'package:material_ui/material_ui.dart';

import 'branding.dart';
import 'lab_copy.dart';
import 'learning_content.dart';

enum _Destination { laboratory, learn, examples, documentation, github }

class LabNavbar extends StatelessWidget {
  const LabNavbar({
    super.key,
    required this.copy,
    required this.section,
    required this.onNavigate,
    required this.onResource,
    required this.onLanguageChanged,
  });
  final LabCopy copy;
  final LabSection section;
  final ValueChanged<LabSection> onNavigate;
  final ValueChanged<LabResource> onResource;
  final ValueChanged<LabLanguage>? onLanguageChanged;
  String n(NavText text) => text.inLanguage(copy);

  Widget language() => SizedBox(
    width: 148,
    child: DropdownButtonFormField<LabLanguage>(
      key: ValueKey(copy.language),
      initialValue: copy.language,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: copy.text(LabText.language),
        isDense: true,
      ),
      items: LabLanguage.values
          .map(
            (value) => DropdownMenuItem(value: value, child: Text(value.label)),
          )
          .toList(),
      onChanged: onLanguageChanged == null
          ? null
          : (value) {
              if (value != null) {
                onLanguageChanged!(value);
              }
            },
    ),
  );

  Widget navigationButton(LabSection value) => Semantics(
    selected: value == section,
    child: TextButton(
      onPressed: () => onNavigate(value),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF00695C),
        backgroundColor: value == section ? const Color(0xFFE5F1E8) : null,
      ),
      child: Text(n(sectionLabel(value))),
    ),
  );

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDCE2DA))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final mobile =
                    constraints.maxWidth < 1000 ||
                    MediaQuery.textScalerOf(context).scale(1) > 1.3;
                final brand = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GeneticMark(label: n(NavText.logo), size: 36),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        mobile ? 'GENETIC' : 'GENETIC ENGINE',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: mobile ? 12 : 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                );
                return Row(
                  children: [
                    Expanded(child: brand),
                    if (!mobile) ...[
                      for (final value in LabSection.values)
                        navigationButton(value),
                      TextButton(
                        onPressed: () => onResource(LabResource.gettingStarted),
                        child: Text(n(NavText.documentation)),
                      ),
                      TextButton(
                        onPressed: () => onResource(LabResource.github),
                        child: Text(n(NavText.github)),
                      ),
                      const SizedBox(width: 16),
                    ],
                    language(),
                    if (mobile)
                      PopupMenuButton<_Destination>(
                        key: const Key('navigation-menu'),
                        requestFocus: true,
                        tooltip: n(NavText.menu),
                        icon: const Icon(Icons.menu),
                        onSelected: (value) {
                          switch (value) {
                            case _Destination.laboratory:
                              onNavigate(LabSection.laboratory);
                            case _Destination.learn:
                              onNavigate(LabSection.learn);
                            case _Destination.examples:
                              onNavigate(LabSection.examples);
                            case _Destination.documentation:
                              onResource(LabResource.gettingStarted);
                            case _Destination.github:
                              onResource(LabResource.github);
                          }
                        },
                        itemBuilder: (_) => [
                          for (final value in _Destination.values)
                            PopupMenuItem(
                              value: value,
                              child: Text(
                                n(switch (value) {
                                  _Destination.laboratory => NavText.laboratory,
                                  _Destination.learn => NavText.learn,
                                  _Destination.examples => NavText.examples,
                                  _Destination.documentation =>
                                    NavText.documentation,
                                  _Destination.github => NavText.github,
                                }),
                              ),
                            ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
