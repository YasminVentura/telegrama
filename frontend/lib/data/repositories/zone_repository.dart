abstract class ZoneRepository {
  Future<List<Map<String, dynamic>>> getExploreZones({String? category, String? searchQuery});
  Future<Map<String, dynamic>> getZoneDetails(String zoneId);
  Future<void> joinZone(String zoneId);
  Future<List<Map<String, dynamic>>> getZonePosts(String zoneId);
}

class ZoneRepositoryImpl implements ZoneRepository {
  @override
  Future<List<Map<String, dynamic>>> getExploreZones({String? category, String? searchQuery}) async {
    // Stub: Simula busca de zonas para explorar
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      {
        'id': 'zone_1',
        'title': 'Vector Grids',
        'tag': 'DESIGN',
        'stats': '14.2K CONNECTED • 342 ACTIVE',
      },
      {
        'id': 'zone_2',
        'title': 'Analog Synthesis',
        'tag': 'AUDIO',
        'stats': '8.5K CONNECTED • 120 ACTIVE',
      }
    ];
  }

  @override
  Future<Map<String, dynamic>> getZoneDetails(String zoneId) async {
    // Stub: Retorna detalhes ricos de uma zona
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'id': zoneId,
      'title': 'Vector Grids',
      'tag': 'DESIGN',
      'description': 'A frequency for geometric experiments and modernist artifacts.',
      'stats': '14.2K CONNECTED • 342 ACTIVE',
      'isJoined': false,
    };
  }

  @override
  Future<void> joinZone(String zoneId) async {
    // Stub: Simula conectar-se a uma zona
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<List<Map<String, dynamic>>> getZonePosts(String zoneId) async {
    // Stub: Simula posts específicos de uma zona
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }
}
