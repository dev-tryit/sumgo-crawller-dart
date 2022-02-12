import '../Setting.dart';

class DateTimeUtil {
  static DateTime now(){
    var nowValue = DateTime.now();
    return nowValue.add(Duration(hours: 0-nowValue.timeZoneOffset.inHours+Setting.timeZoneOffset));
  }
}