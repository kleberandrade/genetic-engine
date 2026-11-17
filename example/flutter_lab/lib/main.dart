import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:genetic_engine/genetic_engine.dart';

import 'lab_model.dart';
import 'plots.dart';

void main() => runApp(const EvolutionLab());

const ink = Color(0xFF182C36);
const teal = Color(0xFF00695C);

class EvolutionLab extends StatelessWidget {
  const EvolutionLab({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Genetic Engine · Evolution Lab',
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
    home: const LabPage(),
  );
}

class LabPage extends StatefulWidget {
  const LabPage({super.key});
  @override
  State<LabPage> createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> {
  Problem problem = Problem.oneMax;
  Problem activeProblem = Problem.oneMax;
  ParentSelection selection = ParentSelection.tournament;
  int population = 100;
  bool alternative = false;
  double mutation = .3, crossover = .8;
  final seed = TextEditingController(text: '42');
  String? seedError;
  String status = 'Ready';
  Timer? timer;
  Iterator<Generation<List<int>>>? iterator;
  final history = <Generation<List<int>>>[];
  bool get running => timer != null;
  bool get locked => status == 'Running' || status == 'Paused';
  bool get canAdvance => iterator != null;

  @override
  void initState() {
    super.initState();
    restart();
  }

  void restart() {
    final parsed = int.tryParse(seed.text);
    if (parsed == null || parsed < 0 || parsed > 2147483647) {
      setState(() => seedError = 'Enter an integer from 0 to 2147483647.');
      return;
    }
    timer?.cancel();
    timer = null;
    seedError = null;
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
    status = 'Ready';
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
            ? 'Target reached'
            : 'Generation limit',
      );
    }
  }

  void toggle() {
    if (running) {
      timer!.cancel();
      timer = null;
      setState(() => status = 'Paused');
    } else if (canAdvance) {
      setState(() => status = 'Running');
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
    setState(() => status = 'Cancelled');
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
        const Text(
          '01 / EXPERIMENT',
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        dropdown(
          'Scenario',
          problem,
          Problem.values,
          (p) => p.label,
          (v) => problem = v,
        ),
        const SizedBox(height: 10),
        Text(problem.description),
        const SizedBox(height: 14),
        dropdown(
          'Population',
          population,
          [40, 100, 200],
          (v) => '$v individuals',
          (v) => population = v,
        ),
        const SizedBox(height: 14),
        dropdown(
          'Parent selection',
          selection,
          ParentSelection.values,
          (v) => switch (v) {
            ParentSelection.tournament => 'Tournament',
            ParentSelection.rank => 'Rank',
            ParentSelection.sus => 'SUS · inverse cost',
          },
          (v) => selection = v,
        ),
        const SizedBox(height: 14),
        dropdown(
          'Operator pair',
          alternative,
          [false, true],
          (v) => problem == Problem.oneMax
              ? (v ? 'Uniform + bit flip' : 'Single point + bit flip')
              : (v ? 'Order + reverse' : 'PMX + swap'),
          (v) => alternative = v,
        ),
        const SizedBox(height: 14),
        rate('Crossover probability', crossover, (v) => crossover = v),
        rate('Mutation probability', mutation, (v) => mutation = v),
        TextField(
          controller: seed,
          enabled: !locked,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Random seed',
            errorText: seedError,
            helperText: 'Applied by Restart. Same seed, same experiment.',
          ),
          onSubmitted: (_) => restart(),
        ),
        const SizedBox(height: 18),
        const Text(
          '1 elite survives unchanged. Maximum 300 generations. Lower fitness is better in all three scenarios.',
          style: TextStyle(fontSize: 12, color: Color(0xFF4C6269)),
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
            semanticFormatterCallback: (v) => '${(v * 100).round()} percent',
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
                  const Expanded(
                    child: Text(
                      '02 / LIVE EVOLUTION',
                      style: TextStyle(
                        letterSpacing: 2,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      status,
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
                  metric('Generation', '${generation.index} / 300'),
                  metric(
                    'Best fitness',
                    generation.best.fitness.toStringAsFixed(3),
                  ),
                  metric(
                    'Mean fitness',
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
                          ? 'Pause'
                          : status == 'Paused'
                          ? 'Resume'
                          : 'Run',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: !running && canAdvance ? advance : null,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Step'),
                  ),
                  OutlinedButton.icon(
                    onPressed: restart,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Restart'),
                  ),
                  TextButton.icon(
                    onPressed: canAdvance ? cancel : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Cancel'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Pause retains the population. Restart replays the seed. Cancel ends this run.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Best individual · ${activeProblem.label}',
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
                          '${activeProblem.label} best genome ${generation.best.genome.join(', ')}; fitness ${generation.best.fitness.toStringAsFixed(3)}',
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
                'Genome: ${generation.best.genome.join(', ')}',
                style: const TextStyle(fontSize: 12),
              ),
              if (activeProblem == Problem.salesman)
                const Text(
                  'The route closes back to its first city. Distances use normalized coordinates.',
                  style: TextStyle(fontSize: 12),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fitness history',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const Text(
                'Best (solid teal) / population mean (dashed amber) · lower is better',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 170,
                width: double.infinity,
                child: Semantics(
                  label:
                      'Fitness history across ${history.length} observations. Current best ${generation.best.fitness}, mean ${generation.meanFitness}.',
                  child: CustomPaint(painter: HistoryPainter(List.of(history))),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ranked population · ${generation.population.length} individuals',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                generation.population
                    .take(8)
                    .map((c) => c.fitness.toStringAsFixed(2))
                    .join('  ·  '),
              ),
              const Text(
                'Top eight fitness values shown; all individuals contribute to the mean.',
                style: TextStyle(fontSize: 12),
              ),
              ExpansionTile(
                title: const Text('Inspect population'),
                children: [
                  for (var i = 0; i < generation.population.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: SelectableText(
                        '#${i + 1} · fitness ${generation.population[i].fitness.toStringAsFixed(3)} · ${generation.population[i].genome.join(', ')}',
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

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GENETIC ENGINE / INTERACTIVE LAB',
                  style: TextStyle(
                    color: teal,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Small changes.\nBetter generations.',
                  style: TextStyle(
                    fontSize: 40,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Explore selection, crossover and mutation — one generation at a time.',
                  style: TextStyle(fontSize: 16),
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
                const Text(
                  'Pure Dart core · Flutter interface · MIT licensed\nA teaching tool: stochastic search does not guarantee an optimum.',
                  style: TextStyle(color: Color(0xFF4C6269), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
