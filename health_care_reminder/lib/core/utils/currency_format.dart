import 'package:intl/intl.dart';

class CurrencyFormat {
  static String convertToIdr({required dynamic value, int decimalDigit = 0}) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(value);
  }

  static String convertToCurrency({
    required dynamic value,
    int decimalDigit = 0,
  }) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(value);
  }

  static String convertToDigit({required String value}) {
    return value.trim().replaceAll(RegExp(r'[^0-9]'), '');
  }
}
