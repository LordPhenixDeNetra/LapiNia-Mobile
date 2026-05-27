import '../models/alerte.dart';

abstract class NotificationService {
  Future<void> initialize();
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  });
  Future<void> sendPushToUser(String userId, Alerte alerte);
  Future<void> sendPushToTopic(String topic, String title, String body);
  Stream<String> get onTokenRefresh;
  void setForegroundHandler(Function(Map<String, dynamic>) handler);
  void setBackgroundHandler(Function(Map<String, dynamic>) handler);
  void setTerminatedHandler(Function(Map<String, dynamic>) handler);
}
