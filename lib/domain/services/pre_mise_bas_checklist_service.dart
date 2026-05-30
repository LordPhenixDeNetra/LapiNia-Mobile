import 'package:drift/drift.dart';

import '../../data/local_db/app_database.dart';

class PreMiseBasChecklistService {
  final AppDatabase db;

  PreMiseBasChecklistService({required this.db});

  static const defaultItemKeys = <String>[
    'cage_maternite',
    'nid',
    'temperature',
    'aliments',
    'isolement',
  ];

  Future<Map<String, bool>> getChecklist({
    required String userId,
    required String porteeId,
  }) async {
    for (final key in defaultItemKeys) {
      final id = '$porteeId:$key';
      await db.into(db.preMiseBasChecklistLocal).insert(
            PreMiseBasChecklistLocalCompanion.insert(
              id: id,
              userId: userId,
              porteeId: porteeId,
              itemKey: key,
              checked: false,
              updatedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }

    final rows = await (db.select(db.preMiseBasChecklistLocal)
          ..where((t) => t.userId.equals(userId) & t.porteeId.equals(porteeId)))
        .get();

    final map = <String, bool>{
      for (final k in defaultItemKeys) k: false,
    };
    for (final r in rows) {
      map[r.itemKey] = r.checked;
    }
    return map;
  }

  Future<void> setChecked({
    required String userId,
    required String porteeId,
    required String itemKey,
    required bool checked,
  }) async {
    final id = '$porteeId:$itemKey';
    await db.into(db.preMiseBasChecklistLocal).insert(
          PreMiseBasChecklistLocalCompanion.insert(
            id: id,
            userId: userId,
            porteeId: porteeId,
            itemKey: itemKey,
            checked: checked,
            updatedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }
}

