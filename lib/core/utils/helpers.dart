import 'package:intl/intl.dart';

class DateUtils {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String toIso(DateTime date) => _isoFormat.format(date);

  static DateTime? parseIso(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  static int joursEntre(DateTime debut, DateTime fin) {
    return fin.difference(debut).inDays;
  }

  static int ageEnJours(DateTime dateNaissance) {
    return DateTime.now().difference(dateNaissance).inDays;
  }

  static String ageFormate(DateTime dateNaissance) {
    final jours = ageEnJours(dateNaissance);
    if (jours < 30) return '$jours jours';
    if (jours < 365) return '${(jours / 30).floor()} mois';
    final ans = (jours / 365).floor();
    final moisRestants = ((jours % 365) / 30).floor();
    if (moisRestants == 0) return '$ans an(s)';
    return '$ans an(s) $moisRestants mois';
  }

  static bool estAujourdhui(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  static bool estDansLesJours(DateTime date, int jours) {
    final maintenant = DateTime.now();
    final difference = date.difference(maintenant).inDays;
    return difference >= 0 && difference <= jours;
  }

  static DateTime dateSevrage(DateTime dateMiseBas, {int jours = 28}) {
    return dateMiseBas.add(Duration(days: jours));
  }

  static DateTime dateMiseBasPrevue(DateTime dateSaillie, {int jours = 31}) {
    return dateSaillie.add(Duration(days: jours));
  }

  static List<DateTime> getJoursProchains(int nombreJours) {
    final maintenant = DateTime.now();
    return List.generate(
      nombreJours,
      (i) => DateTime(maintenant.year, maintenant.month, maintenant.day + i),
    );
  }
}

class CurrencyUtils {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0', 'fr_FR');

  static String formatFcfa(int montant) {
    return '${_currencyFormat.format(montant)} FCFA';
  }

  static String formatFcfaCompact(int montant) {
    if (montant >= 1000000) {
      return '${(montant / 1000000).toStringAsFixed(1)}M FCFA';
    }
    if (montant >= 1000) {
      return '${(montant / 1000).toStringAsFixed(0)}K FCFA';
    }
    return formatFcfa(montant);
  }
}

class WeightUtils {
  static String formatGrammes(int grammes) {
    if (grammes >= 1000) {
      final kg = grammes / 1000;
      return '${kg.toStringAsFixed(2)} kg';
    }
    return '$grammes g';
  }

  static String formatGmQ(double gmQ) {
    return '${gmQ.toStringAsFixed(1)} g/j';
  }
}
