import 'package:material_ui/material_ui.dart';

import 'lab_copy.dart';
import 'learning_content.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({
    super.key,
    required this.copy,
    required this.examplesOnly,
    required this.onPreset,
    required this.onResource,
  });
  final LabCopy copy;
  final bool examplesOnly;
  final ValueChanged<LabPreset> onPreset;
  final ValueChanged<LabResource> onResource;
  String n(NavText value) => value.inLanguage(copy);

  Widget card(Widget child) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    color: Colors.white,
    child: Padding(padding: const EdgeInsets.all(24), child: child),
  );

  Widget preset(LabPreset preset) => card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          preset.title.inLanguage(copy),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(preset.description.inLanguage(copy)),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => onPreset(preset),
          icon: const Icon(Icons.play_arrow),
          label: Text(n(NavText.load)),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        n(examplesOnly ? NavText.exampleTitle : NavText.learnTitle),
        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      Text(
        n(examplesOnly ? NavText.exampleIntro : NavText.learnIntro),
        style: const TextStyle(fontSize: 17),
      ),
      const SizedBox(height: 12),
      Text(
        n(NavText.version),
        style: const TextStyle(color: Color(0xFF4C6269)),
      ),
      const SizedBox(height: 24),
      if (examplesOnly)
        ...labPresets.map(preset)
      else ...[
        for (final topic in learningTopics)
          card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title.inLanguage(copy),
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  topic.body.inLanguage(copy),
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
                if (topic.formula != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFFEAF1E8),
                    child: Semantics(
                      label: topic.formula!,
                      container: true,
                      excludeSemantics: true,
                      child: SelectableText(
                        topic.formula!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
                if (topic.preset != null) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => onPreset(labPresets[topic.preset!]),
                    icon: const Icon(Icons.science_outlined),
                    label: Text(n(NavText.load)),
                  ),
                ],
              ],
            ),
          ),
        card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n(NavText.references),
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(n(NavText.sources)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  for (final resource in LabResource.values)
                    Tooltip(
                      message: n(NavText.external),
                      child: OutlinedButton.icon(
                        onPressed: () => onResource(resource),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text(resource.label.inLanguage(copy)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Text(
          n(NavText.exercises),
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        for (final exercise in learningExercises)
          card(
            Text(
              exercise.inLanguage(copy),
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
      ],
    ],
  );
}
