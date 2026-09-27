import 'package:flutter/foundation.dart';
import '../../core/config/supabase_config.dart';
import '../../core/utils/geo_utils.dart';
import '../models/municipality.dart';
import 'mock_municipality_repository.dart';
import 'municipality_repository.dart';

class SupabaseMunicipalityRepository implements MunicipalityRepository {
  final MockMunicipalityRepository _fallbackRepo = MockMunicipalityRepository();

  @override
  Future<List<Municipality>> getMunicipalities() async {
    final client = SupabaseConfig.client;
    if (client == null) {
      return _fallbackRepo.getMunicipalities();
    }

    try {
      final response = await client
          .from('municipalities')
          .select()
          .order('transparency_score', ascending: false);

      final list = (response as List<dynamic>)
          .map((e) => Municipality.fromJson(e as Map<String, dynamic>))
          .toList();

      if (list.isNotEmpty) {
        GeoUtils.setMunicipalities(list);
        return list;
      }
    } catch (e) {
      debugPrint('⚠️ Supabase getMunicipalities hatası: $e. Mock veriye geçiliyor.');
    }

    return _fallbackRepo.getMunicipalities();
  }

  @override
  Future<Municipality?> getMunicipalityById(String id) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      return _fallbackRepo.getMunicipalityById(id);
    }

    try {
      final response = await client
          .from('municipalities')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        return Municipality.fromJson(response);
      }
    } catch (e) {
      debugPrint('⚠️ Supabase getMunicipalityById hatası: $e');
    }

    return _fallbackRepo.getMunicipalityById(id);
  }

  @override
  Future<List<Municipality>> getLeaderboard({String? province}) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      return _fallbackRepo.getLeaderboard(province: province);
    }

    try {
      var query = client.from('municipalities').select();
      if (province != null && province.isNotEmpty && province != 'Tümü') {
        query = query.eq('province', province);
      }
      final response = await query.order('transparency_score', ascending: false);
      final list = (response as List<dynamic>)
          .map((e) => Municipality.fromJson(e as Map<String, dynamic>))
          .toList();

      if (list.isNotEmpty) {
        return list;
      }
    } catch (e) {
      debugPrint('⚠️ Supabase getLeaderboard hatası: $e');
    }

    return _fallbackRepo.getLeaderboard(province: province);
  }

  @override
  Future<List<String>> getProvinces() async {
    return _fallbackRepo.getProvinces();
  }
}
