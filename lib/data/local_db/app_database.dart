import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class LapinsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get data => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class PorteesLocal extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get data => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class LapereauxLocal extends Table {
  TextColumn get id => text()();
  TextColumn get porteeId => text()();
  TextColumn get userId => text()();
  TextColumn get data => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class PeseesLocal extends Table {
  TextColumn get id => text()();
  TextColumn get lapinId => text()();
  TextColumn get userId => text()();
  TextColumn get data => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class SanteLocal extends Table {
  TextColumn get id => text()();
  TextColumn get lapinId => text()();
  TextColumn get userId => text()();
  TextColumn get data => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class StocksLocal extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get data => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class FinancesLocal extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get data => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class AlertesLocal extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get data => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class RacesRef extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class MedicamentsRef extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class AlimentsLocauxRef extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class DailyAdviceCache extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get content => text()();
  DateTimeColumn get cachedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class PlannedEvents extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()();
  TextColumn get targetId => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class PreMiseBasChecklistLocal extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get porteeId => text()();
  TextColumn get itemKey => text()();
  BoolColumn get checked => boolean()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get targetTable => text().named('table_name')();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get idempotencyKey => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    LapinsLocal,
    PorteesLocal,
    LapereauxLocal,
    PeseesLocal,
    SanteLocal,
    StocksLocal,
    FinancesLocal,
    AlertesLocal,
    RacesRef,
    MedicamentsRef,
    AlimentsLocauxRef,
    DailyAdviceCache,
    PlannedEvents,
    PreMiseBasChecklistLocal,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.open() {
    final executor = LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}lapinia_local.sqlite');
      return NativeDatabase.createInBackground(file);
    });
    return AppDatabase(executor);
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(dailyAdviceCache);
            await m.createTable(plannedEvents);
          }
          if (from < 3) {
            await m.createTable(lapereauxLocal);
            await m.createTable(preMiseBasChecklistLocal);
          }
        },
      );
}
