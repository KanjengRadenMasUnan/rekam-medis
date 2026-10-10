import 'package:intl/intl.dart';

String formatDate(DateTime? date, {String pattern = 'dd MMM yyyy'}) {
  if (date == null) return '-';
  return DateFormat(pattern).format(date);
}
