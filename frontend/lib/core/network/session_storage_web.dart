
import 'dart:html' as html;

String? readStorageKey(String key) {
  try {
    return html.window.localStorage[key];
  } catch (_) {
    return null;
  }
}

void writeStorageKey(String key, String value) {
  try {
    html.window.localStorage[key] = value;
  } catch (_) {}
}

void removeStorageKey(String key) {
  try {
    html.window.localStorage.remove(key);
  } catch (_) {}
}
