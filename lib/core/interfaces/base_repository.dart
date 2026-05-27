abstract class BaseRepository<T> {
  Future<T?> findById(String id);
  Future<List<T>> findAll({int? limit, String? cursor});
  Future<T> save(T entity);
  Future<void> delete(String id);
  Future<List<T>> findByField(String field, dynamic value);
}

abstract class LapinRepository implements BaseRepository<dynamic> {
  Future<List<dynamic>> findByStatut(String statut);
  Future<List<dynamic>> findByRace(String raceId);
  Future<List<dynamic>> findBySexe(String sexe);
  Future<List<dynamic>> findDisponiblesSaillie();
}

abstract class PorteeRepository implements BaseRepository<dynamic> {
  Future<List<dynamic>> findEnGest();
  Future<List<dynamic>> findByMere(String mereId);
  Future<List<dynamic>> findRecentes({int limit});
}

abstract class SanteRepository implements BaseRepository<dynamic> {
  Future<List<dynamic>> findByLapin(String lapinId);
  Future<List<dynamic>> findActifs();
  Future<List<dynamic>> findVaccins();
  Future<int> countSimilarSymptomes(String userId, int heures);
}

abstract class StockRepository implements BaseRepository<dynamic> {
  Future<List<dynamic>> findCritiques();
  Future<void> updateQuantite(String id, double nouvelleQuantite);
  Future<List<dynamic>> historique(String id);
}

abstract class FinanceRepository implements BaseRepository<dynamic> {
  Future<List<dynamic>> findByPeriode(DateTime debut, DateTime fin);
  Future<Map<String, int>> getResumeMensuel(int annee, int mois);
  Future<int> getBeneficeNet(int annee, int mois);
}
