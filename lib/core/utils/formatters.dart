import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _decimalFormat = NumberFormat('#,##0.#', 'id_ID');
  static final _thousandsFormat = NumberFormat('#,###', 'id_ID');

  static String currency(double amount) => _currencyFormat.format(amount);

  static String decimal(double value) => _decimalFormat.format(value);

  /// "10.000" untuk integer di locale id_ID. Empty string jika 0/null.
  static String thousands(num value) =>
      value == 0 ? '' : _thousandsFormat.format(value);

  /// Parse string yang sudah ter-format (mis. "10.000") → 10000.0.
  /// Aman untuk input kosong (return 0).
  static double parseFormattedNumber(String text) {
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return 0;
    return double.parse(digits);
  }

  static String odometer(double km) => '${_decimalFormat.format(km)} km';

  static String liters(double l) => '${_decimalFormat.format(l)} L';

  static String consumption(double kmPerLiter) => '${_decimalFormat.format(kmPerLiter)} km/L';

  static String date(DateTime dt) => DateFormat('dd MMM yyyy', 'id_ID').format(dt);

  static String dateShort(DateTime dt) => DateFormat('dd MMM', 'id_ID').format(dt);

  static String monthYear(DateTime dt) => DateFormat('MMMM yyyy', 'id_ID').format(dt).toUpperCase();

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return date(dt);
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours}j lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m lalu';
    return 'Baru saja';
  }
}

/// Auto-format input integer dengan pemisah ribuan (id_ID → titik).
/// Contoh: user ketik "350000" → tampil "350.000".
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final _formatter = NumberFormat('#,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final number = int.tryParse(digits);
    if (number == null) return oldValue;
    final formatted = _formatter.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
