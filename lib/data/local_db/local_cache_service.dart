import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';
import '../../core/models/lapin.dart';
import '../../core/models/lapereau.dart';
import '../../core/models/pesel.dart';
import '../../core/models/portee.dart';
import '../../core/models/race.dart';

class LocalCacheService {
  final AppDatabase db;

  LocalCacheService({required this.db});

  static const String _racesRefId = 'all';

  Future<Lapin?> getLapinById({
    required String userId,
    required String lapinId,
  }) async {
    final row = await (db.select(db.lapinsLocal)
          ..where(
            (t) =>
                t.id.equals(lapinId) &
                t.userId.equals(userId) &
                t.isDeleted.equals(false),
          ))
        .getSingleOrNull();
    if (row == null) return null;
    return Lapin.fromJson(jsonDecode(row.data) as Map<String, dynamic>);
  }

  Future<List<Lapin>> getLapins({required String userId}) async {
    final rows = await (db.select(db.lapinsLocal)
          ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();
    return rows
        .map((r) => Lapin.fromJson(jsonDecode(r.data) as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertLapin(Lapin lapin) async {
    await db.into(db.lapinsLocal).insert(
          LapinsLocalCompanion.insert(
            id: lapin.id,
            userId: lapin.userId,
            data: jsonEncode(lapin.toJson()),
            updatedAt: lapin.updatedAt,
            isDeleted: const Value(false),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> markLapinDeleted({
    required String id,
    required String userId,
  }) async {
    final now = DateTime.now();
    await (db.update(db.lapinsLocal)..where((t) => t.id.equals(id))).write(
      LapinsLocalCompanion(
        userId: Value(userId),
        updatedAt: Value(now),
        isDeleted: const Value(true),
      ),
    );

    await (db.update(db.peseesLocal)..where((t) => t.lapinId.equals(id))).write(
      PeseesLocalCompanion(
        userId: Value(userId),
        updatedAt: Value(now),
        isDeleted: const Value(true),
      ),
    );
    await (db.update(db.santeLocal)..where((t) => t.lapinId.equals(id))).write(
      SanteLocalCompanion(
        userId: Value(userId),
        updatedAt: Value(now),
        isDeleted: const Value(true),
      ),
    );
  }

  Future<void> cacheLapins({
    required String userId,
    required List<Lapin> lapins,
  }) async {
    await db.batch((batch) {
      batch.insertAll(
        db.lapinsLocal,
        lapins
            .map(
              (l) => LapinsLocalCompanion.insert(
                id: l.id,
                userId: userId,
                data: jsonEncode(l.toJson()),
                updatedAt: l.updatedAt,
                isDeleted: const Value(false),
              ),
            )
            .toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<Pesee>> getPeseesByLapin({
    required String userId,
    required String lapinId,
  }) async {
    final rows = await (db.select(db.peseesLocal)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.lapinId.equals(lapinId) &
                t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();
    return rows
        .map((r) => Pesee.fromJson(jsonDecode(r.data) as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertPesee(Pesee pesee) async {
    final updatedAt = DateTime(pesee.date.year, pesee.date.month, pesee.date.day);
    await db.into(db.peseesLocal).insert(
          PeseesLocalCompanion.insert(
            id: pesee.id,
            lapinId: pesee.lapinId,
            userId: pesee.userId,
            data: jsonEncode(pesee.toJson()),
            updatedAt: updatedAt,
            isDeleted: const Value(false),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> markPeseeDeleted({
    required String id,
    required String userId,
  }) async {
    final now = DateTime.now();
    await (db.update(db.peseesLocal)..where((t) => t.id.equals(id))).write(
      PeseesLocalCompanion(
        userId: Value(userId),
        updatedAt: Value(now),
        isDeleted: const Value(true),
      ),
    );
  }

  Future<void> cachePesees({
    required String userId,
    required String lapinId,
    required List<Pesee> pesees,
  }) async {
    await db.batch((batch) {
      batch.insertAll(
        db.peseesLocal,
        pesees
            .map(
              (p) => PeseesLocalCompanion.insert(
                id: p.id,
                lapinId: lapinId,
                userId: userId,
                data: jsonEncode(p.toJson()),
                updatedAt: DateTime(p.date.year, p.date.month, p.date.day),
                isDeleted: const Value(false),
              ),
            )
            .toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<Portee>> getPortees({required String userId}) async {
    final rows = await (db.select(db.porteesLocal)
          ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();
    return rows
        .map((r) => Portee.fromJson(jsonDecode(r.data) as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertPortee(Portee portee) async {
    await db.into(db.porteesLocal).insert(
          PorteesLocalCompanion.insert(
            id: portee.id,
            userId: portee.userId,
            data: jsonEncode(portee.toJson()),
            updatedAt: portee.updatedAt,
            isDeleted: const Value(false),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> markPorteeDeleted({
    required String id,
    required String userId,
  }) async {
    final now = DateTime.now();
    await (db.update(db.porteesLocal)..where((t) => t.id.equals(id))).write(
      PorteesLocalCompanion(
        userId: Value(userId),
        updatedAt: Value(now),
        isDeleted: const Value(true),
      ),
    );
  }

  Future<void> cachePortees({
    required String userId,
    required List<Portee> portees,
  }) async {
    await db.batch((batch) {
      batch.insertAll(
        db.porteesLocal,
        portees
            .map(
              (p) => PorteesLocalCompanion.insert(
                id: p.id,
                userId: userId,
                data: jsonEncode(p.toJson()),
                updatedAt: p.updatedAt,
                isDeleted: const Value(false),
              ),
            )
            .toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<Lapereau>> getLapereaux({
    required String userId,
    required String porteeId,
  }) async {
    final rows = await (db.select(db.lapereauxLocal)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.porteeId.equals(porteeId) &
                t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.asc)]))
        .get();
    return rows
        .map((r) => Lapereau.fromJson(jsonDecode(r.data) as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertLapereau(Lapereau lapereau) async {
    final now = DateTime.now();
    await db.into(db.lapereauxLocal).insert(
          LapereauxLocalCompanion.insert(
            id: lapereau.id,
            porteeId: lapereau.porteeId,
            userId: lapereau.userId,
            data: jsonEncode(lapereau.toJson()),
            updatedAt: now,
            isDeleted: const Value(false),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> cacheLapereaux({
    required String userId,
    required String porteeId,
    required List<Lapereau> lapereaux,
  }) async {
    final now = DateTime.now();
    await db.batch((batch) {
      batch.insertAll(
        db.lapereauxLocal,
        lapereaux
            .map(
              (l) => LapereauxLocalCompanion.insert(
                id: l.id,
                porteeId: porteeId,
                userId: userId,
                data: jsonEncode(l.toJson()),
                updatedAt: now,
                isDeleted: const Value(false),
              ),
            )
            .toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<({List<Race> races, DateTime cachedAt})?> getRacesRef() async {
    final row = await (db.select(db.racesRef)
          ..where((t) => t.id.equals(_racesRefId)))
        .getSingleOrNull();
    if (row == null) return null;
    final decoded = jsonDecode(row.data);
    if (decoded is! List) return null;
    final races = decoded
        .map((e) => Race.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return (races: races, cachedAt: row.cachedAt);
  }

  Future<void> setRacesRef(List<Race> races) async {
    await db.into(db.racesRef).insert(
          RacesRefCompanion.insert(
            id: _racesRefId,
            data: jsonEncode(races.map((r) => r.toJson()).toList()),
            cachedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }
}
