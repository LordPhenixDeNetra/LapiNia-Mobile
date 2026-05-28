import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core_providers.dart';

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final checker = ref.watch(connectivityCheckerProvider);
  return (() async* {
    yield checker.isOnline;
    yield* checker.onConnectivityChanged;
  })();
});

final pendingMutationsProvider = FutureProvider<int>((ref) async {
  final syncManager = ref.read(syncManagerProvider);
  return syncManager.pendingMutations;
});
