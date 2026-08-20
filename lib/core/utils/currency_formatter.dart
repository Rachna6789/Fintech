import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter({String locale = 'en_US', String symbol = r'$'})
      : _formatter = NumberFormat.currency(locale: locale, symbol: symbol);

  final NumberFormat _formatter;

  String format(num value) => _formatter.format(value);
}
