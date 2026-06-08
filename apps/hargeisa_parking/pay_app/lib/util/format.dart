import 'package:intl/intl.dart';

final _money = NumberFormat.decimalPattern('en');

/// Format an amount as Somaliland shillings, e.g. `SLSH 250,000`.
String slsh(int amount) => 'SLSH ${_money.format(amount)}';
