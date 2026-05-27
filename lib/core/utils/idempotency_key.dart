import 'package:uuid/uuid.dart';

class IdempotencyKey {
  static const _uuid = Uuid();

  static String generate() {
    return _uuid.v4();
  }

  static bool isValid(String key) {
    try {
      Uuid.parse(key);
      return true;
    } catch (_) {
      return false;
    }
  }
}
