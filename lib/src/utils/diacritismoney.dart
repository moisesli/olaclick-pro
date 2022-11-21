import 'package:diacritic/diacritic.dart';
import 'package:intl/intl.dart';
import 'package:money2/money2.dart';

class AppUtils {
  AppUtils._internal();
  static final AppUtils _instance = AppUtils._internal();
  static AppUtils get instance => _instance;

  String trimCharacter(String value) {
    value = removeDiacritics(value);
    value.replaceAll(RegExp('\$'), 'USD');
    // Currency euro = Currency.create('EUR', 2, symbol: 'EUR', invertSeparators: true, pattern: 'S0.000,00');
    // Currency jpy = Currency.create('JPY', 0, symbol: '¥', pattern: 'S0');
    // Currency gbp = Currency.create('GBP', 2, symbol: '£');

    // value.replaceAll(RegExp('£'), 'GBP');
    // value.replaceAll(RegExp('¥'), 'YEN');
    //value.replaceAll(RegExp('€'), 'EUR');

    return value;
  }
}
