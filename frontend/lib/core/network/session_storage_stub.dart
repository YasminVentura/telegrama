final Map<String, String> _memoryStore = {};

String? readStorageKey(String key) => _memoryStore[key];

void writeStorageKey(String key, String value) {
  _memoryStore[key] = value;
}

void removeStorageKey(String key) {
  _memoryStore.remove(key);
}

