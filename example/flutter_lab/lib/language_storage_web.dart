import 'dart:js_interop';

const _key = 'genetic_engine_lab.language';

@JS('localStorage.getItem')
external String? _getItem(String key);

@JS('localStorage.setItem')
external void _setItem(String key, String value);

String? readLanguage() => _getItem(_key);
void writeLanguage(String code) => _setItem(_key, code);
