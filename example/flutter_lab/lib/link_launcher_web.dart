import 'dart:js_interop';

@JS('open')
external void _open(String url, String target, String features);

bool launchResource(String url) {
  _open(url, '_blank', 'noopener,noreferrer');
  return true;
}
