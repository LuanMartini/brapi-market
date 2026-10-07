import 'package:intl/intl.dart';

abstract final class AppFormatters {
  static final _currency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final _number = NumberFormat.decimalPattern('pt_BR');

  static String currency(num? value, {String symbol = 'R\$'}) {
    if (value == null) return '—';
    if (symbol == 'R\$') return _currency.format(value);
    return '$symbol ${NumberFormat('#,##0.00', 'pt_BR').format(value)}';
  }

  static String percent(num? value) {
    if (value == null) return '—';
    final prefix = value > 0 ? '+' : '';
    return '$prefix${NumberFormat('0.00', 'pt_BR').format(value)}%';
  }

  static String compact(num? value, {String prefix = ''}) {
    if (value == null) return '—';
    final absolute = value.abs();
    final sign = value < 0 ? '-' : '';
    if (absolute >= 1e12) return '$sign$prefix${_short(absolute / 1e12)} tri';
    if (absolute >= 1e9) return '$sign$prefix${_short(absolute / 1e9)} bi';
    if (absolute >= 1e6) return '$sign$prefix${_short(absolute / 1e6)} mi';
    if (absolute >= 1e3) return '$sign$prefix${_short(absolute / 1e3)} mil';
    return '$prefix${_number.format(value)}';
  }

  static String date(DateTime? value) {
    if (value == null) return '—';
    final local = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year}';
  }

  static String _short(num value) => NumberFormat('0.#', 'pt_BR').format(value);
}

DateTime? parseFlexibleDate(Object? value) {
  if (value == null) return null;
  if (value is num) {
    final milliseconds =
        value.abs() < 100000000000 ? value.toInt() * 1000 : value.toInt();
    return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
  }
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  final numeric = int.tryParse(text);
  if (numeric != null) return parseFlexibleDate(numeric);
  return DateTime.tryParse(text);
}

double? asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '.'));
  return null;
}

int? asInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
