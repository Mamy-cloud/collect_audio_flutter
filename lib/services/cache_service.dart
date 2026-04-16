import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/local_database.dart';

class CacheService {
  static final _sb = Supabase.instance.client;

  static Future<void> syncReferenceData() async {
    await Future.wait([_syncDepts(), _syncRegions()]);
  }

  static Future<void> _syncDepts() async {
    if (await LocalDatabase.isCacheValid('departements_cached_at')) return;
    try {
      final data = await _sb
          .from('departements')
          .select('id, name_departement')
          .order('name_departement');
      await LocalDatabase.cacheDepartements(
          List<Map<String, dynamic>>.from(data));
    } catch (_) {}
  }

  static Future<void> _syncRegions() async {
    if (await LocalDatabase.isCacheValid('regions_corse_cached_at')) return;
    try {
      final data = await _sb
          .from('regions_corse')
          .select('id, name_region, departement_id')
          .order('name_region');
      await LocalDatabase.cacheRegionsCorse(
          List<Map<String, dynamic>>.from(data));
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> getDepartements() async {
    final cached = await LocalDatabase.getDepartements();
    if (cached.isEmpty) {
      await _syncDepts();
      return await LocalDatabase.getDepartements();
    }
    return cached;
  }

  static Future<List<Map<String, dynamic>>> getRegionsCorse() async {
    final cached = await LocalDatabase.getRegionsCorse();
    if (cached.isEmpty) {
      await _syncRegions();
      return await LocalDatabase.getRegionsCorse();
    }
    return cached;
  }

  static Future<void> forceRefresh() async {
    await LocalDatabase.invalidateCache('departements_cached_at');
    await LocalDatabase.invalidateCache('regions_corse_cached_at');
    await syncReferenceData();
  }
}
