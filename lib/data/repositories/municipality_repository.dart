import '../models/municipality.dart';

abstract class MunicipalityRepository {
  Future<List<Municipality>> getMunicipalities();

  Future<Municipality?> getMunicipalityById(String id);

  Future<List<Municipality>> getLeaderboard({String? province});
}
