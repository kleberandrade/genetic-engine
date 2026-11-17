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

## Português

Explore OneMax, oito rainhas e caixeiro viajante. **Run** executa; **Pause** pausa;
**Resume** retoma; **Step** avança uma geração; **Restart** reproduz a seed;
**Cancel** encerra a execução e conserva os resultados. Para alterar um experimento
ativo, use Restart antes de ajustar os parâmetros. Fitness menor é melhor: no
OneMax, ela conta quantos bits ainda faltam. A busca pode atingir o limite sem
chegar à solução ótima.
