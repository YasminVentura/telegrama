abstract class SearchRepository {
  Future<List<Map<String, dynamic>>> globalSearch(String query);
}

class SearchRepositoryImpl implements SearchRepository {
  @override
  Future<List<Map<String, dynamic>>> globalSearch(String query) async {
    // Stub: Simula uma busca global cruzada (Posts, Zonas, Usuários)
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': 'u1',
        'title': 'Saskia Vance',
        'subtitle': '@sas_vance',
        'category': 'users',
      },
      {
        'id': 'p1',
        'title': 'New grid study: warm modules moving',
        'subtitle': '@lumina_dream',
        'category': 'posts',
      },
    ];
  }
}
