import 'package:drift/drift.dart';

import '../../core/models/planned_event.dart';
import '../../data/local_db/app_database.dart';
import '../../core/utils/idempotency_key.dart';

class PlannedEventsService {
  final AppDatabase db;

  PlannedEventsService({required this.db});

  Future<List<PlannedEventModel>> listRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    final rows = await (db.select(db.plannedEvents)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.date.isBetweenValues(start, end),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc)]))
        .get();

    return rows
        .map(
          (r) => PlannedEventModel(
            id: r.id,
            userId: r.userId,
            type: PlannedEventType.fromDbValue(r.type),
            targetId: r.targetId,
            date: r.date,
            note: r.note,
            createdAt: r.createdAt,
          ),
        )
        .toList();
  }

  Future<PlannedEventModel> create({
    required String userId,
    required PlannedEventType type,
    required DateTime date,
    String? targetId,
    String? note,
  }) async {
    final now = DateTime.now();
    final id = IdempotencyKey.generate();

    final model = PlannedEventModel(
      id: id,
      userId: userId,
      type: type,
      targetId: targetId,
      date: date,
      note: note,
      createdAt: now,
    );

    await db.into(db.plannedEvents).insert(
          PlannedEventsCompanion.insert(
            id: id,
            userId: userId,
            type: type.dbValue,
            targetId: Value(targetId),
            date: date,
            note: Value(note),
            createdAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );

    return model;
  }

  Future<void> delete({required String id}) async {
    await (db.delete(db.plannedEvents)..where((t) => t.id.equals(id))).go();
  }
}
