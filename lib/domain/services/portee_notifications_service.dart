import 'local_notification_service.dart';

class PorteeNotificationsService {
  final LocalNotificationService notifications;

  PorteeNotificationsService({required this.notifications});

  int _baseId(String porteeId) {
    final hex = porteeId.replaceAll('-', '');
    final head = hex.length >= 8 ? hex.substring(0, 8) : hex.padRight(8, '0');
    return int.parse(head, radix: 16) & 0x7fffffff;
  }

  Future<void> scheduleGestationReminders({
    required String porteeId,
    required String mereName,
    required DateTime dateMiseBasPrevue,
  }) async {
    final base = _baseId(porteeId);
    final idJ3 = base;
    final idJ1 = (base + 1) & 0x7fffffff;
    final now = DateTime.now();

    final d3 = DateTime(
      dateMiseBasPrevue.year,
      dateMiseBasPrevue.month,
      dateMiseBasPrevue.day,
      9,
    ).subtract(const Duration(days: 3));
    final d1 = DateTime(
      dateMiseBasPrevue.year,
      dateMiseBasPrevue.month,
      dateMiseBasPrevue.day,
      9,
    ).subtract(const Duration(days: 1));

    if (d3.isAfter(now)) {
      await notifications.schedule(
        id: idJ3,
        title: 'Mise bas bientôt',
        body: '$mereName : mise bas prévue dans 3 jours.',
        dateTimeLocal: d3,
        payload: 'portee:$porteeId',
      );
    }
    if (d1.isAfter(now)) {
      await notifications.schedule(
        id: idJ1,
        title: 'Mise bas demain',
        body: '$mereName : mise bas prévue demain.',
        dateTimeLocal: d1,
        payload: 'portee:$porteeId',
      );
    }
  }

  Future<void> cancelGestationReminders({required String porteeId}) async {
    final base = _baseId(porteeId);
    await notifications.cancel(base);
    await notifications.cancel((base + 1) & 0x7fffffff);
  }
}
