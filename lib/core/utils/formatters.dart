import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String formatDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat('dd/MM/yyyy', locale).format(date);
}

String formatFcfa(BuildContext context, int amount) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final f = NumberFormat.currency(
    locale: locale,
    name: 'XOF',
    symbol: 'FCFA',
    decimalDigits: 0,
  );
  return f.format(amount);
}

