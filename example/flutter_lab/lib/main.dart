import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:genetic_engine/genetic_engine.dart';

import 'lab_model.dart';
import 'lab_copy.dart';
import 'language_preference.dart';
import 'plots.dart';
import 'lab_navigation.dart';
import 'learning_page.dart';
import 'learning_content.dart';
import 'link_launcher_stub.dart'
    if (dart.library.js_interop) 'link_launcher_web.dart'
    as links;

void main() => runApp(const EvolutionLab());

const ink = Color(0xFF182C36);
const teal = Color(0xFF00695C);

class EvolutionLab extends StatefulWidget {
  const EvolutionLab({super.key, this.languagePreference, this.onOpenResource});
  final ValueChanged<LabResource>? onOpenResource;
  final LanguagePreference? languagePreference;
  @override
  State<EvolutionLab> createState() => _EvolutionLabState();
}

class _EvolutionLabState extends State<EvolutionLab> {
  late final LanguagePreference preference;
  late LabLanguage language;

  @override
  void initState() {
    super.initState();
    preference = widget.languagePreference ?? LanguagePreference();
    language = preference.initialLanguage(
      WidgetsBinding.instance.platformDispatcher.locales.map(
        (locale) => locale.toLanguageTag(),
      ),
    );
  }

  void changeLanguage(LabLanguage value) {
    setState(() => language = value);
    preference.remember(value);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: Locale(language.code),
    supportedLocales: const [Locale('en'), Locale('pt')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    title: LabCopy(language).text(LabText.title),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: teal),
      scaffoldBackgroundColor: const Color(0xFFF4F5EF),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: ink,
        displayColor: ink,
      ),
    ),
    home: Semantics(
      localeForSubtree: Locale(language.code),
      child: LabPage(
        language: language,
        onLanguageChanged: changeLanguage,
        onOpenResource: widget.onOpenResource,
      ),
    ),
  );
}

class LabPage extends StatefulWidget {
  const LabPage({
    super.key,
    this.language = LabLanguage.english,
    this.onLanguageChanged,
    this.onOpenResource,
  });
  final LabLanguage language;
  final ValueChanged<LabLanguage>? onLanguageChanged;
  final ValueChanged<LabResource>? onOpenResource;
  @override
  State<LabPage> createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> {
  LabSection section = LabSection.laboratory;
  LabPreset? loadedPreset;
  String n(NavText value) => value.inLanguage(copy);

  void openResource(LabResource resource) {
    if (widget.onOpenResource != null) {
      widget.onOpenResource!(resource);
      return;
    }
    if (!links.launchResource(resource.url)) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(n(NavText.address)),
          content: SelectableText(resource.url),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(n(NavText.close)),
            ),
          ],
        ),
      );
    }
  }

  void loadPreset(LabPreset preset) {
    final config = preset.config;
    problem = config.problem;
    population = config.population;
    selection = config.selection;
    alternative = config.alternative;
    crossover = config.crossoverRate;
    mutation = config.mutationRate;
    seed.text = '${config.seed}';
    section = LabSection.laboratory;
    loadedPreset = preset;
    restart();
  }

  Problem problem = Problem.oneMax;
  Problem activeProblem = Problem.oneMax;
  ParentSelection selection = ParentSelection.tournament;
  int population = 100;
  bool alternative = false;
  double mutation = .3, crossover = .8;
  final seed = TextEditingController(text: '42');
  bool invalidSeed = false;
  RunStatus status = RunStatus.ready;
  LabCopy get copy => LabCopy(widget.language);
  String t(LabText value) => copy.text(value);
  Timer? timer;
  Iterator<Generation<List<int>>>? iterator;
  final history = <Generation<List<int>>>[];
  bool get running => timer != null;
  bool get locked => status == RunStatus.running || status == RunStatus.paused;
  bool get canAdvance => iterator != null;

  @override
  void initState() {
    super.initState();
    restart();
  }

  void restart() {
    final parsed = int.tryParse(seed.text);
    if (parsed == null || parsed < 0 || parsed > 2147483647) {
      setState(() => invalidSeed = true);
      return;
    }
    timer?.cancel();
    timer = null;
    invalidSeed = false;
    activeProblem = problem;
    iterator = LabConfig(
      problem: problem,
      population: population,
      seed: parsed,
      selection: selection,
      alternative: alternative,
      mutationRate: mutation,
      crossoverRate: crossover,
    ).engine().generations().iterator;
    history.clear();
    iterator!.moveNext();
    history.add(iterator!.current);
    status = RunStatus.ready;
    if (mounted) {
      setState(() {});
    }
  }

  void advance() {
    if (iterator == null) {
      return;
    }
    if (iterator!.moveNext()) {
      setState(() {
        history.add(iterator!.current);
      });
    } else {
      timer?.cancel();
      timer = null;
      iterator = null;
      setState(
        () => status = history.last.best.fitness == 0
            ? RunStatus.targetReached
            : RunStatus.generationLimit,
      );
    }
  }

  void toggle() {
    if (running) {
      timer!.cancel();
      timer = null;
      setState(() => status = RunStatus.paused);
    } else if (canAdvance) {
      setState(() => status = RunStatus.running);
      timer = Timer.periodic(
        const Duration(milliseconds: 70),
        (_) => advance(),
      );
    }
  }

  void cancel() {
    timer?.cancel();
    timer = null;
    iterator = null;
    setState(() => status = RunStatus.cancelled);
  }

  @override
  void dispose() {
    timer?.cancel();
    seed.dispose();
    super.dispose();
  }

  Widget panel(Widget child) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFFDCE2DA)),
    ),
    child: Padding(padding: const EdgeInsets.all(22), child: child),
  );

  Widget dropdown<T>(
    String label,
    T value,
    List<T> values,
    String Function(T) name,
    void Function(T) change,
  ) => DropdownButtonFormField<T>(
    key: ValueKey('$label:$value'),
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: values
        .map((v) => DropdownMenuItem(value: v, child: Text(name(v))))
        .toList(),
    onChanged: locked
        ? null
        : (v) {
            if (v != null) {
              change(v);
              restart();
            }
          },
  );

  Widget controls() => panel(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t(LabText.experiment),
          style: const TextStyle(
            letterSpacing: 2,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        dropdown(
          t(LabText.scenario),
          problem,
          Problem.values,
          (p) => copy.problemName(p),
          (v) => problem = v,
        ),
        const SizedBox(height: 10),
        Text(copy.problemDescription(problem)),
        const SizedBox(height: 14),
        dropdown(
          t(LabText.population),
          population,
          [40, 100, 200],
          (v) => '$v ${t(LabText.individuals)}',
          (v) => population = v,
        ),
        const SizedBox(height: 14),
        dropdown(
          t(LabText.parentSelection),
          selection,
          ParentSelection.values,
          (v) => switch (v) {
            ParentSelection.tournament => t(LabText.tournament),
            ParentSelection.rank => t(LabText.rank),
            ParentSelection.sus => t(LabText.sus),
          },
          (v) => selection = v,
        ),
        const SizedBox(height: 14),
        dropdown(
          t(LabText.operators),
          alternative,
          [false, true],
          (v) => problem == Problem.oneMax
              ? (v ? t(LabText.uniformBits) : t(LabText.singleBits))
              : (v ? t(LabText.orderReverse) : t(LabText.pmxSwap)),
          (v) => alternative = v,
        ),
        const SizedBox(height: 14),
        rate(t(LabText.crossover), crossover, (v) => crossover = v),
        rate(t(LabText.mutation), mutation, (v) => mutation = v),
        TextField(
          controller: seed,
          enabled: !locked,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: t(LabText.seed),
            errorText: invalidSeed ? t(LabText.seedError) : null,
            helperText: t(LabText.seedHelp),
          ),
          onSubmitted: (_) => restart(),
        ),
        const SizedBox(height: 18),
        Text(
          t(LabText.limits),
          style: const TextStyle(fontSize: 12, color: Color(0xFF4C6269)),
        ),
      ],
    ),
  );

  Widget rate(String label, double value, void Function(double) change) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label · ${(value * 100).round()}%'),
          Slider(
            value: value,
            divisions: 10,
            label: '${(value * 100).round()}%',
            semanticFormatterCallback: (v) =>
                '${(v * 100).round()} ${t(LabText.percent)}',
            onChanged: locked
                ? null
                : (v) {
                    change(v);
                    restart();
                  },
          ),
        ],
      );

  Widget results() {
    final generation = history.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t(LabText.live),
                      style: const TextStyle(
                        letterSpacing: 2,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      copy.status(status),
                      style: const TextStyle(
                        color: teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 30,
                runSpacing: 12,
                children: [
                  metric(t(LabText.generation), '${generation.index} / 300'),
                  metric(
                    t(LabText.bestFitness),
                    generation.best.fitness.toStringAsFixed(3),
                  ),
                  metric(
                    t(LabText.meanFitness),
                    generation.meanFitness.toStringAsFixed(3),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: canAdvance ? toggle : null,
                    icon: Icon(running ? Icons.pause : Icons.play_arrow),
                    label: Text(
                      running
                          ? t(LabText.pause)
                          : status == RunStatus.paused
                          ? t(LabText.resume)
                          : t(LabText.run),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: !running && canAdvance ? advance : null,
                    icon: const Icon(Icons.skip_next),
                    label: Text(t(LabText.step)),
                  ),
                  OutlinedButton.icon(
                    onPressed: restart,
                    icon: const Icon(Icons.refresh),
                    label: Text(t(LabText.restart)),
                  ),
                  TextButton.icon(
                    onPressed: canAdvance ? cancel : null,
                    icon: const Icon(Icons.stop),
                    label: Text(t(LabText.cancel)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(t(LabText.lifecycle), style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${t(LabText.bestIndividual)} · ${copy.problemName(activeProblem)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 510),
                  child: AspectRatio(
                    aspectRatio: 1.65,
                    child: Semantics(
                      label:
                          '${copy.problemName(activeProblem)} ${t(LabText.bestGenome)} ${generation.best.genome.join(', ')}; ${t(LabText.fitness)} ${generation.best.fitness.toStringAsFixed(3)}',
                      child: CustomPaint(
                        painter: GenomePainter(
                          activeProblem,
                          generation.best.genome,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                '${t(LabText.genome)}: ${generation.best.genome.join(', ')}',
                style: const TextStyle(fontSize: 12),
              ),
              if (activeProblem == Problem.salesman)
                Text(t(LabText.route), style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(LabText.history),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(t(LabText.legend), style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 14),
              SizedBox(
                height: 170,
                width: double.infinity,
                child: Semantics(
                  label: copy.historySummary(
                    history.length,
                    generation.best.fitness,
                    generation.meanFitness,
                  ),
                  child: CustomPaint(
                    painter: HistoryPainter(List.of(history), copy: copy),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${t(LabText.ranked)} · ${generation.population.length} ${t(LabText.individuals)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                generation.population
                    .take(8)
                    .map((c) => c.fitness.toStringAsFixed(2))
                    .join('  ·  '),
              ),
              Text(t(LabText.topEight), style: const TextStyle(fontSize: 12)),
              ExpansionTile(
                title: Text(t(LabText.inspect)),
                children: [
                  for (var i = 0; i < generation.population.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: SelectableText(
                        '#${i + 1} · ${t(LabText.fitness)} ${generation.population[i].fitness.toStringAsFixed(3)} · ${generation.population[i].genome.join(', ')}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget metric(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF4C6269)),
      ),
      Text(
        value,
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
      ),
    ],
  );

  Widget laboratory() => SingleChildScrollView(
    key: const PageStorageKey('laboratory'),
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(LabText.brand),
              style: const TextStyle(
                color: teal,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t(LabText.heading),
              style: const TextStyle(
                fontSize: 40,
                height: 1.1,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Text(t(LabText.introduction), style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            if (loadedPreset != null)
              Text(
                '${n(NavText.loaded)}: ${loadedPreset!.title.inLanguage(copy)}',
              ),
            const SizedBox(height: 26),
            LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth < 820
                  ? Column(
                      children: [
                        controls(),
                        const SizedBox(height: 16),
                        results(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 320, child: controls()),
                        const SizedBox(width: 20),
                        Expanded(child: results()),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            Text(
              t(LabText.footer),
              style: const TextStyle(color: Color(0xFF4C6269), fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          LabNavbar(
            copy: copy,
            section: section,
            onNavigate: (value) => setState(() => section = value),
            onResource: openResource,
            onLanguageChanged: widget.onLanguageChanged,
          ),
          Expanded(
            child: section == LabSection.laboratory
                ? laboratory()
                : SingleChildScrollView(
                    key: PageStorageKey(section),
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: LearningPage(
                          copy: copy,
                          examplesOnly: section == LabSection.examples,
                          onPreset: loadPreset,
                          onResource: openResource,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}
