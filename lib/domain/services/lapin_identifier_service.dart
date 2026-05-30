import 'package:shared_preferences/shared_preferences.dart';

class LapinIdentifierService {
  static const _kPrefix = 'lapin_numero';

  Future<String> generateNumeroIdentification({
    required String? country,
    required int year,
    required String? raceCode,
  }) async {
    final countryCode = _countryToCode(country);
    final rCode = _normalizeRaceCode(raceCode);

    final prefs = await SharedPreferences.getInstance();
    final key = '$_kPrefix:$countryCode:$year:$rCode';
    final current = prefs.getInt(key) ?? 0;
    final next = current + 1;
    await prefs.setInt(key, next);

    final number = next.toString().padLeft(4, '0');
    return '$countryCode-$year-$rCode-$number';
  }

  static String _countryToCode(String? country) {
    final raw = (country ?? '').trim();
    if (raw.isEmpty) return 'XX';
    final normalized = raw.toLowerCase();

    if (normalized.contains('sénégal') || normalized.contains('senegal')) return 'SN';
    if (normalized.contains('mali')) return 'ML';
    if (normalized.contains("côte d'ivoire") ||
        normalized.contains('cote d') ||
        normalized.contains('ivoire')) {
      return 'CI';
    }

    final letters = raw.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.length >= 2) return letters.substring(0, 2).toUpperCase();
    return raw.substring(0, 1).toUpperCase().padRight(2, 'X');
  }

  static String _normalizeRaceCode(String? raceCode) {
    final raw = (raceCode ?? '').trim();
    if (raw.isEmpty) return 'UNK';

    final normalized = raw.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (normalized.isEmpty) return 'UNK';

    if (normalized.length <= 4) return normalized;
    return normalized.substring(0, 3);
  }
}

