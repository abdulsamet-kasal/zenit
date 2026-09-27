import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/municipality.dart';
import 'municipality_repository.dart';

class MockMunicipalityRepository implements MunicipalityRepository {
  List<Municipality>? _cachedMunicipalities;

  Future<void> _ensureLoaded() async {
    if (_cachedMunicipalities != null) return;

    try {
      final jsonString =
          await rootBundle.loadString('assets/mock/municipalities.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cachedMunicipalities = jsonList
          .map((e) => Municipality.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _cachedMunicipalities = [];
    }
  }

  @override
  Future<List<Municipality>> getMunicipalities() async {
    await _ensureLoaded();
    return _cachedMunicipalities!;
  }

  @override
  Future<Municipality?> getMunicipalityById(String id) async {
    await _ensureLoaded();
    try {
      return _cachedMunicipalities!.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Municipality>> getLeaderboard({String? province}) async {
    await _ensureLoaded();
    Iterable<Municipality> list = _cachedMunicipalities!;
    if (province != null && province.isNotEmpty && province != 'Tümü') {
      list = list.where((m) => m.province == province);
    }
    final sorted = list.toList()
      ..sort((a, b) => b.transparencyScore.compareTo(a.transparencyScore));
    return sorted;
  }
}
