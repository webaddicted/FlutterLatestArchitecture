import 'package:intl/intl.dart';

class DateUtils{
  static String getddMMMMyyyy(DateTime dateTime) {
    return DateFormat('dd-MMMM-yyyy').format(dateTime);
  }

  static String getddMMyyyy(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  static String getDateTimeFormat(String dateTime, String dateTimReqFormat) {
    return DateFormat(dateTimReqFormat).format(DateTime.parse(dateTime));
    // var dateFormate = DateFormat("dd-MMMM-yyyy").format(DateTime.parse('30-March-2021'));
    // print("object:  $dateTimeFormate $dateTime $dateFormate");
// return '';
  }

  static DateTime getDateTime(String? dateTime) {
    return DateFormat("dd-MM-yyyy").parse(dateTime??"");
  }

  static delay({int? durationSec, Function? click}) {
    int sec = (durationSec! * 1000);
    Future.delayed(Duration(milliseconds: sec), () {
      click!();
    });
  }
}