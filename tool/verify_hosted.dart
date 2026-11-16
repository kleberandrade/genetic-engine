import 'dart:convert';
import 'dart:io';

/// Verifies that consumer checks resolved a hosted version, not a path override.
void main(List<String> args) {
  final expected = args.single;
  final lock = File('pubspec.lock').readAsStringSync();
  final block = RegExp(
    r'\n  genetic_engine:\n([\s\S]*?)(?=\n  [a-zA-Z_][a-zA-Z_0-9]*:|\nsdks:)',
  ).firstMatch(lock)?.group(1);
  if (block == null ||
      !block.contains('source: hosted') ||
      !block.contains('https://pub.dev') ||
      !block.contains('version: "$expected"')) {
    throw StateError(
        'Consumer did not resolve hosted genetic_engine $expected');
  }
  final config =
      jsonDecode(File('.dart_tool/package_config.json').readAsStringSync())
          as Map<String, dynamic>;
  final packages = config['packages'] as List<dynamic>;
  final package = packages
      .cast<Map<String, dynamic>>()
      .singleWhere((entry) => entry['name'] == 'genetic_engine');
  final uri = Uri.parse(package['rootUri'] as String);
  if (!uri.path.contains('/hosted/pub.dev/genetic_engine-$expected')) {
    throw StateError('Resolved package is not in the pub.dev hosted cache');
  }
  if (File('pubspec_overrides.yaml').existsSync()) {
    throw StateError('Consumer checks must not use dependency overrides');
  }
  print('Verified hosted dependency: genetic_engine $expected from pub.dev');
}
