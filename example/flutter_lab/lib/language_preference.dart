import 'lab_copy.dart';
import 'language_storage_stub.dart'
    if (dart.library.js_interop) 'language_storage_web.dart'
    as storage;

/// Browser persistence belongs to the lab, never the optimization package.
class LanguagePreference {
  LanguagePreference({String? Function()? read, void Function(String)? write})
    : _read = read ?? storage.readLanguage,
      _write = write ?? storage.writeLanguage;

  final String? Function() _read;
  final void Function(String) _write;

  LabLanguage initialLanguage(Iterable<String> preferredLanguages) {
    String? saved;
    try {
      saved = _read();
    } catch (_) {
      // Browser settings may deny access to localStorage.
    }
    for (final language in LabLanguage.values) {
      if (saved == language.code) {
        return language;
      }
    }
    for (final tag in preferredLanguages) {
      final code = tag.toLowerCase().split(RegExp('[-_]')).first;
      for (final language in LabLanguage.values) {
        if (code == language.code) {
          return language;
        }
      }
    }
    return LabLanguage.english;
  }

  void remember(LabLanguage language) {
    try {
      _write(language.code);
    } catch (_) {
      // Persistence is optional; an explicit choice still applies this session.
    }
  }
}
