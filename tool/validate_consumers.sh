#!/usr/bin/env bash
set -euo pipefail
mode="${1:-dart}"
version="${GENETIC_ENGINE_VERSION:-0.3.1}"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo 'Expected an exact stable package version' >&2
  exit 1
fi
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
work="$(mktemp -d "${TMPDIR:-/tmp}/genetic-consumer.XXXXXX")"
trap 'rm -rf -- "$work"' EXIT
report_dir="${CONSUMER_REPORT_DIR:-$script_dir/../.consumer-reports}"
mkdir -p "$report_dir"
report_dir="$(cd "$report_dir" && pwd)"
export CI=true
case "$mode" in
  dart)
    mkdir -p "$work/bin"
    cat > "$work/pubspec.yaml" <<YAML
name: genetic_engine_dart_consumer
environment:
  sdk: '>=3.3.0 <4.0.0'
dependencies:
  genetic_engine: $version
YAML
    cp "$script_dir/consumer_fixtures/dart/main.dart.template" "$work/bin/main.dart"
    cp "$script_dir/benchmarks/evolution_benchmark.dart" "$work/bin/benchmark.dart"
    cd "$work"
    dart pub get
    dart "$script_dir/verify_hosted.dart" "$version"
    dart analyze --fatal-infos
    dart run bin/main.dart
    dart run bin/benchmark.dart "$report_dir" "pub.dev:$version"
    cp pubspec.lock "$report_dir/dart-pubspec.lock"
    ;;
  flutter)
    cd "$work"
    flutter create --empty --platforms=web --project-name=genetic_engine_flutter_consumer --no-pub .
    cat > pubspec.yaml <<YAML
name: genetic_engine_flutter_consumer
environment:
  sdk: '>=3.3.0 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
  genetic_engine: $version
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
YAML
    printf 'linter:\n  rules:\n    curly_braces_in_flow_control_structures: true\n' > analysis_options.yaml
    rm -rf -- "$work/test"
    mkdir -p test
    cp "$script_dir/consumer_fixtures/flutter/main.dart.template" lib/main.dart
    cp "$script_dir/consumer_fixtures/flutter/consumer_test.dart.template" test/consumer_test.dart
    flutter pub get
    dart "$script_dir/verify_hosted.dart" "$version"
    flutter analyze --fatal-infos
    flutter test
    flutter build web --release
    cp pubspec.lock "$report_dir/flutter-pubspec.lock"
    ;;
  *) echo 'Usage: bash tool/validate_consumers.sh dart|flutter' >&2; exit 1 ;;
esac
printf 'PASS: %s consumer for genetic_engine %s\n' "$mode" "$version"
