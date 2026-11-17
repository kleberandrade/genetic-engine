# Evolution Lab

A Flutter application consuming `package:genetic_engine/genetic_engine.dart` from
this checkout. The root package remains pure Dart and dependency-free.

The lab uses the unreleased `generations()` API; it does not resolve hosted 0.4.0.
Use Flutter **3.50.0**, Dart **3.14.0** and the committed application lockfile.
Material widgets use `material_ui` **1.11.1**, as required by this toolchain.
SDK-pinned transitive dependencies are retained without overrides.

```sh
cd example/flutter_lab
flutter pub get
flutter analyze --fatal-infos
flutter test
flutter run -d chrome
flutter build web --release --base-href /genetic-engine/ --no-web-resources-cdn --no-wasm-dry-run
```

Read the [scenario and controls guide](../../doc/lab/guide.md) and
[validation record](../../doc/lab/validation.md). GitHub Actions validates the core,
lab and release build before Pages deployment. Pull requests only validate.

## Language

Use **Language / Idioma** at the top to select **English** or **Português**.
Controls, scenario explanations, status/error messages, chart labels and semantic
summaries switch immediately. Language changes preserve the current population,
history, configuration, seed and running/paused state. English is the
fallback when no supported browser language is available. On Web, an explicit
choice is saved in this browser's local storage and restored on later visits.
Without a valid saved choice, the first supported language in the browser's
preference list is used (`pt-BR`/`pt-PT` → Português; `en-*` → English). Clearing
site data removes the choice. If storage is blocked, switching still works for
the current session. Native preview builds use the platform locale without disk
persistence; browser persistence is the validated target.

## Português

Selecione **Português** em **Language / Idioma** para traduzir a interface.
A troca de idioma conserva a execução e os resultados, inclusive durante a pausa.
O navegador lembra a escolha; na primeira visita, o idioma segue as preferências
do navegador, com inglês como fallback.
Explore OneMax, oito rainhas e caixeiro viajante. **Executar** inicia; **Pausar** pausa;
**Retomar** continua; **Avançar** calcula uma geração; **Reiniciar** reproduz a
semente; **Cancelar** encerra a execução e conserva os resultados. Para alterar um experimento
ativo, use Reiniciar antes de ajustar os parâmetros. Fitness menor é melhor: no
OneMax, ela conta quantos bits ainda faltam. A busca pode atingir o limite sem
chegar à solução ótima.
