import 'lab_model.dart';

enum LabLanguage {
  english('en', 'English'),
  portuguese('pt', 'Português');

  const LabLanguage(this.code, this.label);
  final String code, label;
}

enum RunStatus {
  ready,
  running,
  paused,
  targetReached,
  generationLimit,
  cancelled,
}

/// Application copy only: changing language never changes evolution state.
enum LabText {
  title(
    'Genetic Engine · Evolution Lab',
    'Genetic Engine · Laboratório de evolução',
  ),
  language('Language / Idioma', 'Idioma / Language'),
  brand(
    'GENETIC ENGINE / INTERACTIVE LAB',
    'GENETIC ENGINE / LABORATÓRIO INTERATIVO',
  ),
  heading(
    'Small changes.\nBetter generations.',
    'Pequenas mudanças.\nGerações melhores.',
  ),
  introduction(
    'Explore selection, crossover and mutation — one generation at a time.',
    'Explore seleção, cruzamento e mutação — uma geração de cada vez.',
  ),
  experiment('01 / EXPERIMENT', '01 / EXPERIMENTO'),
  scenario('Scenario', 'Cenário'),
  population('Population', 'População'),
  individuals('individuals', 'indivíduos'),
  parentSelection('Parent selection', 'Seleção de pais'),
  tournament('Tournament', 'Torneio'),
  rank('Rank', 'Classificação'),
  sus('SUS · inverse cost', 'SUS · custo inverso'),
  operators('Operator pair', 'Par de operadores'),
  uniformBits('Uniform + bit flip', 'Uniforme + inversão de bit'),
  singleBits('Single point + bit flip', 'Um ponto + inversão de bit'),
  orderReverse('Order + reverse', 'Ordem + reversão'),
  pmxSwap('PMX + swap', 'PMX + troca'),
  crossover('Crossover probability', 'Probabilidade de cruzamento'),
  mutation('Mutation probability', 'Probabilidade de mutação'),
  percent('percent', 'por cento'),
  seed('Random seed', 'Semente aleatória'),
  seedHelp(
    'Applied by Restart. Same seed, same experiment.',
    'Aplicada ao reiniciar. Mesma semente, mesmo experimento.',
  ),
  seedError(
    'Enter an integer from 0 to 2147483647.',
    'Digite um inteiro de 0 a 2147483647.',
  ),
  limits(
    '1 elite survives unchanged. Maximum 300 generations. Lower fitness is better in all three scenarios.',
    '1 indivíduo de elite é preservado. Máximo de 300 gerações. Aptidão menor é melhor nos três cenários.',
  ),
  live('02 / LIVE EVOLUTION', '02 / EVOLUÇÃO AO VIVO'),
  generation('Generation', 'Geração'),
  bestFitness('Best fitness', 'Melhor aptidão'),
  meanFitness('Mean fitness', 'Aptidão média'),
  pause('Pause', 'Pausar'),
  resume('Resume', 'Retomar'),
  run('Run', 'Executar'),
  step('Step', 'Avançar'),
  restart('Restart', 'Reiniciar'),
  cancel('Cancel', 'Cancelar'),
  lifecycle(
    'Pause retains the population. Restart replays the seed. Cancel ends this run.',
    'Pausar conserva a população. Reiniciar repete a semente. Cancelar encerra esta execução.',
  ),
  bestIndividual('Best individual', 'Melhor indivíduo'),
  bestGenome('best genome', 'melhor genoma'),
  fitness('fitness', 'aptidão'),
  genome('Genome', 'Genoma'),
  route(
    'The route closes back to its first city. Distances use normalized coordinates.',
    'A rota retorna à primeira cidade. As distâncias usam coordenadas normalizadas.',
  ),
  history('Fitness history', 'Histórico de aptidão'),
  legend(
    'Best (solid teal) / population mean (dashed amber) · lower is better',
    'Melhor (verde contínuo) / média da população (âmbar tracejado) · menor é melhor',
  ),
  ranked('Ranked population', 'População ordenada'),
  topEight(
    'Top eight fitness values shown; all individuals contribute to the mean.',
    'Exibindo as oito melhores aptidões; todos os indivíduos contribuem para a média.',
  ),
  inspect('Inspect population', 'Inspecionar população'),
  footer(
    'Pure Dart core · Flutter interface · MIT licensed\nA teaching tool: stochastic search does not guarantee an optimum.',
    'Núcleo Dart puro · Interface Flutter · Licença MIT\nFerramenta educativa: a busca estocástica não garante uma solução ótima.',
  );

  const LabText(this.en, this.pt);
  final String en, pt;
}

class LabCopy {
  const LabCopy(this.language);
  final LabLanguage language;
  String text(LabText value) =>
      language == LabLanguage.english ? value.en : value.pt;
  String problemName(Problem value) => language == LabLanguage.english
      ? value.label
      : switch (value) {
          Problem.oneMax => 'OneMax',
          Problem.queens => 'Oito rainhas',
          Problem.salesman => 'Caixeiro viajante',
        };
  String problemDescription(Problem value) => language == LabLanguage.english
      ? value.description
      : switch (value) {
          Problem.oneMax =>
            'Ative os 32 genes. A aptidão conta os bits que faltam.',
          Problem.queens =>
            'Posicione oito rainhas sem conflitos nas diagonais.',
          Problem.salesman =>
            'Visite oito cidades e retorne ao ponto de partida.',
        };
  String status(RunStatus value) => switch (value) {
    RunStatus.ready => language == LabLanguage.english ? 'Ready' : 'Pronto',
    RunStatus.running =>
      language == LabLanguage.english ? 'Running' : 'Executando',
    RunStatus.paused => language == LabLanguage.english ? 'Paused' : 'Pausado',
    RunStatus.targetReached =>
      language == LabLanguage.english ? 'Target reached' : 'Meta atingida',
    RunStatus.generationLimit =>
      language == LabLanguage.english
          ? 'Generation limit'
          : 'Limite de gerações',
    RunStatus.cancelled =>
      language == LabLanguage.english ? 'Cancelled' : 'Cancelado',
  };
  String historySummary(int count, double best, double mean) =>
      language == LabLanguage.english
      ? 'Fitness history across $count observations. Current best ${best.toStringAsFixed(3)}, mean ${mean.toStringAsFixed(3)}.'
      : 'Histórico de aptidão com $count observações. Melhor atual ${best.toStringAsFixed(3)}, média ${mean.toStringAsFixed(3)}.';
}
