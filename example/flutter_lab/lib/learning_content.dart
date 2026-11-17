import 'lab_copy.dart';
import 'lab_model.dart';

class LocalText {
  const LocalText(this.en, this.pt);
  final String en, pt;
  String inLanguage(LabCopy copy) =>
      copy.language == LabLanguage.english ? en : pt;
}

enum LabSection { laboratory, learn, examples }

enum NavText {
  laboratory('Laboratory', 'Laboratório'),
  learn('Learn', 'Aprender'),
  examples('Examples', 'Exemplos'),
  documentation('Documentation', 'Documentação'),
  github('GitHub', 'GitHub'),
  navigation('Navigation', 'Navegação'),
  menu('Open navigation', 'Abrir navegação'),
  logo(
    'Genetic Engine logo: crossing genomes and a new gold gene',
    'Logotipo Genetic Engine: genomas cruzados e um novo gene dourado',
  ),
  learnTitle('Understand the search', 'Entenda a busca'),
  learnIntro(
    'From immutable genomes to a measured experiment. These lessons explain the actual implementation in this repository.',
    'Dos genomas imutáveis a um experimento medido. Estas lições explicam a implementação real deste repositório.',
  ),
  version(
    'Core 0.4.0 · this lab uses the checkout’s unreleased incremental API.',
    'Núcleo 0.4.0 · este laboratório usa a API incremental ainda não publicada do checkout.',
  ),
  load('Load in laboratory', 'Carregar no laboratório'),
  loaded('Preset loaded', 'Configuração carregada'),
  exampleTitle(
    'Start with a concrete problem',
    'Comece com um problema concreto',
  ),
  exampleIntro(
    'Loading a preset starts a new seeded experiment. Ordinary navigation and language changes preserve your current run.',
    'Carregar uma configuração inicia um novo experimento com semente. A navegação comum e a troca de idioma preservam a execução atual.',
  ),
  references('Sources and further reading', 'Fontes e leitura complementar'),
  sources(
    'Based on this project’s getting-started, selection, operators, examples and integration guides. The linked source documents are in English. All teaching content here is available in both languages.',
    'Baseado nos guias deste projeto: primeiros passos, seleção, operadores, exemplos e integração. Os documentos de origem estão em inglês. Todo o conteúdo educativo aqui está disponível nos dois idiomas.',
  ),
  exercises('Five practical exercises', 'Cinco exercícios práticos'),
  external(
    'Opens an external page in a new tab',
    'Abre uma página externa em nova aba',
  ),
  address('Link address', 'Endereço do link'),
  close('Close', 'Fechar');

  const NavText(this.en, this.pt);
  final String en, pt;
  String inLanguage(LabCopy copy) =>
      copy.language == LabLanguage.english ? en : pt;
}

NavText sectionLabel(LabSection section) => switch (section) {
  LabSection.laboratory => NavText.laboratory,
  LabSection.learn => NavText.learn,
  LabSection.examples => NavText.examples,
};

enum LabResource {
  gettingStarted(
    'doc/getting_started.md',
    LocalText('Getting started', 'Primeiros passos'),
  ),
  selection(
    'doc/selection.md',
    LocalText('Selection semantics', 'Semântica da seleção'),
  ),
  operators(
    'doc/operators.md',
    LocalText('Operator catalogue', 'Catálogo de operadores'),
  ),
  examples(
    'doc/examples.md',
    LocalText('CLI example walkthroughs', 'Exemplos de linha de comando'),
  ),
  integration(
    'doc/integration.md',
    LocalText(
      'Runtime and integration limits',
      'Limites de execução e integração',
    ),
  ),
  labGuide(
    'doc/lab/guide.md',
    LocalText('Lab scenario guide', 'Guia dos cenários do laboratório'),
  ),
  references(
    'doc/references.md',
    LocalText(
      'Research and variant references',
      'Referências de pesquisa e variantes',
    ),
  ),
  github('', LocalText('GitHub repository', 'Repositório no GitHub'));

  const LabResource(this.path, this.label);
  final String path;
  final LocalText label;
  String get url => path.isEmpty
      ? 'https://github.com/kleberandrade/genetic-engine'
      : 'https://github.com/kleberandrade/genetic-engine/blob/main/$path';
}

class LabPreset {
  const LabPreset(this.title, this.description, this.config);
  final LocalText title, description;
  final LabConfig config;
}

const labPresets = [
  LabPreset(
    LocalText('OneMax · first generations', 'OneMax · primeiras gerações'),
    LocalText(
      '32 binary genes; tournament selection, single-point crossover and one-bit mutation. Minimize missing bits to zero. Seed 42, population 100, mutation 30%, crossover 80%.',
      '32 genes binários; seleção por torneio, cruzamento de um ponto e mutação de um bit. Minimize os bits faltantes até zero. Semente 42, população 100, mutação 30%, cruzamento 80%.',
    ),
    LabConfig(),
  ),
  LabPreset(
    LocalText(
      'Eight queens · SUS allocation',
      'Oito rainhas · distribuição por SUS',
    ),
    LocalText(
      'One row per column, all rows unique. PMX + swap preserve the permutation. Compare diagonal conflicts with inverse-cost SUS weights. Seed 42, population 100, mutation 50%, crossover 80%.',
      'Uma linha por coluna, sem linhas repetidas. PMX + troca preservam a permutação. Compare conflitos diagonais usando pesos de custo inverso no SUS. Semente 42, população 100, mutação 50%, cruzamento 80%.',
    ),
    LabConfig(
      problem: Problem.queens,
      selection: ParentSelection.sus,
      mutationRate: .5,
    ),
  ),
  LabPreset(
    LocalText(
      'Travelling salesman · rank and order',
      'Caixeiro viajante · classificação e ordem',
    ),
    LocalText(
      'Eight fixed cities and a closed tour. Rank selection with order crossover and segment reversal. Seed 42, population 200, mutation 40%, crossover 80%. Stops at generation 300; no optimality guarantee.',
      'Oito cidades fixas e uma rota fechada. Seleção por classificação com cruzamento de ordem e reversão de segmento. Semente 42, população 200, mutação 40%, cruzamento 80%. Para na geração 300; não garante a solução ótima.',
    ),
    LabConfig(
      problem: Problem.salesman,
      selection: ParentSelection.rank,
      alternative: true,
      population: 200,
      mutationRate: .4,
    ),
  ),
];

class LearningTopic {
  const LearningTopic(this.title, this.body, {this.formula, this.preset});
  final LocalText title, body;
  final String? formula;
  final int? preset;
}

const learningTopics = [
  LearningTopic(
    LocalText(
      'A candidate is a solution plus a score',
      'Um candidato é uma solução com pontuação',
    ),
    LocalText(
      'A gene is one component; a genome is a complete immutable solution. A candidate pairs it with finite fitness. A population is ranked best first. The library maximizes by default; this lab deliberately minimizes costs in every scenario. NaN and infinity are invalid fitness values.',
      'Um gene é um componente; um genoma é uma solução completa e imutável. Um candidato associa o genoma a uma aptidão finita. A população é ordenada do melhor para o pior. A biblioteca maximiza por padrão; este laboratório minimiza custos em todos os cenários. NaN e infinito são aptidões inválidas.',
    ),
  ),
  LearningTopic(
    LocalText('One generation, one observation', 'Uma geração, uma observação'),
    LocalText(
      'Generation zero evaluates the initial population. A step keeps elites, selects parents, optionally crosses and mutates children, then evaluates and ranks the next population. Best fitness is the first ranked candidate; mean fitness averages every candidate. With one elite, the lab retains the best score so far.',
      'A geração zero avalia a população inicial. Um passo preserva a elite, seleciona pais, aplica cruzamento e mutação opcionais e então avalia e ordena a próxima população. A melhor aptidão é a do primeiro candidato; a média considera todos. Com um indivíduo de elite, o laboratório conserva a melhor pontuação já encontrada.',
    ),
    formula: 'mean = sum(fitness[i], i = 0..N-1) / N',
  ),
  LearningTopic(
    LocalText(
      'OneMax: turn a score into a cost',
      'OneMax: transforme pontuação em custo',
    ),
    LocalText(
      'Each g[i] is 0 or 1. The usual OneMax score counts ones; the lab subtracts that count from 32. Zero means every bit is on. A four-bit illustration, 1101, has one missing bit. The actual lab uses 32 bits, not four. Single-point and uniform crossover are compatible with this fixed binary representation.',
      'Cada g[i] vale 0 ou 1. A pontuação usual do OneMax conta os uns; o laboratório subtrai essa contagem de 32. Zero significa que todos os bits estão ativos. Na ilustração de quatro bits 1101, falta um bit. O laboratório usa 32 bits, não quatro. Cruzamentos de um ponto e uniforme são compatíveis com essa representação binária fixa.',
    ),
    formula: 'f(g) = 32 - sum(g[i], i = 0..31)',
    preset: 0,
  ),
  LearningTopic(
    LocalText(
      'Eight queens: encode validity first',
      'Oito rainhas: represente a validade primeiro',
    ),
    LocalText(
      'r[a] is the row of the queen in column a. A permutation guarantees unique rows and columns, leaving only diagonal attacks. Count each attacking pair once. PMX/order crossover and swap/reverse mutation retain the permutation; ordinary binary crossover would not. Fitness zero is a valid solution.',
      'r[a] é a linha da rainha na coluna a. Uma permutação garante linhas e colunas únicas, restando apenas ataques diagonais. Conte cada par atacante uma vez. Cruzamentos PMX/ordem e mutações troca/reversão mantêm a permutação; um cruzamento binário comum não garantiria isso. Aptidão zero é uma solução válida.',
    ),
    formula: 'f(r) = count(a < b where abs(r[a] - r[b]) == b - a)',
    preset: 1,
  ),
  LearningTopic(
    LocalText(
      'Travelling salesman: close the route',
      'Caixeiro viajante: feche a rota',
    ),
    LocalText(
      'The genome orders eight distinct city indices. p[c] is the fixed coordinate of city c. Euclidean edge lengths include the return from the last city to the first. Distances use normalized coordinates, not real geography. Rotations and reversal can represent the same tour; the lab has no configured optimum target for this problem.',
      'O genoma ordena oito índices de cidades distintas. p[c] é a coordenada fixa da cidade c. Os comprimentos euclidianos incluem o retorno da última cidade à primeira. As distâncias usam coordenadas normalizadas, não geografia real. Rotações e reversões podem representar a mesma rota; não há meta ótima configurada para esse problema.',
    ),
    formula: 'L(g) = sum(distance(p[g[i]], p[g[(i+1) % 8]]), i = 0..7)',
    preset: 2,
  ),
  LearningTopic(
    LocalText('Selection is not survival', 'Seleção não é sobrevivência'),
    LocalText(
      'Tournament samples three contestants with replacement and keeps the best rank. Rank selection assigns weights N, N-1, ..., 1 independently of raw fitness scale. SUS uses one random offset and equally spaced pointers to allocate a whole parent pool. Here its weights are 1/(1+cost), so lower nonnegative cost receives more expected copies. These are three implemented choices, not claims that one always wins.',
      'O torneio sorteia três competidores com reposição e escolhe a melhor posição. A seleção por classificação atribui pesos N, N-1, ..., 1 independentemente da escala da aptidão. O SUS usa um único deslocamento aleatório e ponteiros igualmente espaçados para distribuir o conjunto de pais. Aqui os pesos são 1/(1+custo), favorecendo custos não negativos menores. São três escolhas implementadas, sem afirmar que uma sempre vence.',
    ),
    formula: 'rank weight[i] = N-i; SUS weight[i] = 1/(1+f[i]); expected copies[i] = S*weight[i]/sum(weight)',
  ),
  LearningTopic(
    LocalText(
      'Independent operators and unchanged elites',
      'Operadores independentes e elite preservada',
    ),
    LocalText(
      'Crossover and mutation have independent probabilities per child. Mutation rate is not a per-gene probability: bit flip changes one position when selected. One elite bypasses these operators and is not re-evaluated. SUS samples S = 2*(N-1) parents, shuffles the pool and assigns pairs; a second parent can be unused when crossover is skipped. Sample quotas do not guarantee equal use in crossover.',
      'Cruzamento e mutação têm probabilidades independentes por filho. A taxa de mutação não é uma probabilidade por gene: a inversão altera uma posição quando escolhida. Um indivíduo de elite não passa pelos operadores e não é reavaliado. O SUS sorteia S = 2*(N-1) pais, embaralha o conjunto e forma pares; o segundo pai pode não ser usado quando não há cruzamento. As cotas sorteadas não garantem uso igual no cruzamento.',
    ),
    formula: 'P(both) = crossoverRate * mutationRate; S = 2*(N-E), E = 1',
  ),
  LearningTopic(
    LocalText(
      'A reproducible experiment has limits',
      'Um experimento reproduzível tem limites',
    ),
    LocalText(
      'The lab caps population at 200 and breeding at 300 generations. OneMax and queens also stop at zero cost. Seed replay applies on the same runtime with deterministic callbacks. Pause keeps the iterator; cancel discards it. Navigation and language changes do not stop a run. Each generation is synchronous work between timer ticks, not a worker. Multi-objective optimization, island models and parallel fitness are not implemented here.',
      'O laboratório limita a população a 200 e a reprodução a 300 gerações. OneMax e rainhas também param com custo zero. A repetição da semente vale no mesmo ambiente, com funções determinísticas. Pausar conserva o iterador; cancelar o descarta. Navegar e trocar o idioma não interrompem a execução. Cada geração é trabalho síncrono entre eventos do temporizador, não uma execução em worker. Otimização multiobjetivo, modelos de ilhas e aptidão paralela não estão implementados aqui.',
    ),
  ),
];

const learningExercises = [
  LocalText(
    '1. Replay the seed. Objective: compare identical experiments. Load OneMax, Step ten times and record best/mean; reload the same preset and repeat. Complete when all 11 observations, including generation zero, match.',
    '1. Repita a semente. Objetivo: comparar experimentos idênticos. Carregue OneMax, avance dez vezes e registre melhor/média; recarregue a mesma configuração e repita. Conclua quando as 11 observações, incluindo a geração zero, coincidirem.',
  ),
  LocalText(
    '2. Compare operators. Objective: measure mutation effects. Try rates 0 and 0.8 on five seeds with other controls fixed. Complete with ten final fitness/generation records and a conclusion limited to those runs.',
    '2. Compare operadores. Objetivo: medir efeitos da mutação. Use taxas 0 e 0,8 em cinco sementes, mantendo os outros controles. Conclua com dez registros finais de aptidão/geração e uma conclusão limitada a essas execuções.',
  ),
  LocalText(
    '3. Verify a queen solution. Objective: validate the representation independently. Load queens, seek fitness zero and copy the row sequence. Complete when all eight rows are unique and no diagonal pair attacks, or honestly record the generation limit if the target is not reached.',
    '3. Verifique as rainhas. Objetivo: validar a representação de forma independente. Carregue rainhas, busque aptidão zero e copie a sequência de linhas. Conclua quando as oito linhas forem únicas e nenhum par diagonal atacar, ou registre o limite de gerações caso a meta não seja atingida.',
  ),
  LocalText(
    '4. Sum a closed tour. Objective: interpret distance fitness. Copy a TSP genome and use the coordinates in lab_model.dart to sum all eight edges, including the return edge. Complete when your result matches displayed fitness to three decimals.',
    '4. Some uma rota fechada. Objetivo: interpretar a aptidão de distância. Copie um genoma do caixeiro e use as coordenadas de lab_model.dart para somar as oito arestas, incluindo o retorno. Conclua quando o resultado coincidir com a aptidão exibida em três casas decimais.',
  ),
  LocalText(
    '5. Preserve an experiment. Objective: verify lifecycle and navigation. Pause after several steps, visit Learn and Examples, change language and return without loading a preset. Complete when generation, seed and best/mean remain unchanged; then Resume, Cancel and Restart to verify their distinct effects.',
    '5. Preserve o experimento. Objetivo: verificar ciclo de execução e navegação. Pause após alguns passos, visite Aprender e Exemplos, troque o idioma e volte sem carregar uma configuração. Conclua quando geração, semente e melhor/média permanecerem iguais; depois retome, cancele e reinicie para verificar seus efeitos distintos.',
  ),
];
