import 'package:intl/intl.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:timezone/timezone.dart' as tz;

class DateTimeUtils {
  static String getTimeAmPm(DateTime date) => DateFormat.jm().format(date);
}

extension TimeUtils on DateTime {
  DateTime get startOfDay => DateTime(this.year, this.month, this.day);

  DateTime get endOfDay => DateTime(this.year, this.month, this.day, 23, 59, 59, 999, 999);

  DateTime get firstDayOfMonth => DateTime(this.year, this.month);

  DateTime get tenDaysBeforeOfMonth => DateTime(
        this.year,
        this.month,
      ).subtract(Duration(days: 10)).endOfDay;

  DateTime get tenDaysAfterOfMonth =>
      DateTime(this.year, this.month).add(Duration(days: 10)).endOfDay;

  DateTime get currentYear => DateTime(this.year);

  DateTime get nextYear => DateTime(this.year + 1);

  DateTime get lastDayOfMonth => DateTime(this.year, this.month + 1).endOfDay;

  DateTime get nextMonth => DateTime(this.year, this.month + 1, this.day, this.hour, this.minute,
      this.second, this.millisecond, this.microsecond);

  DateTime get noon => DateTime(this.year, this.month, this.day, 12);

  bool get isBeforeToday => this.isBefore(DateTime.now().startOfDay);

  bool get isAfterToday => this.isBefore(DateTime.now().endOfDay);

  bool get isToday {
    final now = DateTime.now();
    if (this.timeZoneOffset == now.timeZoneOffset) {
      return now.day == this.day && now.month == this.month && now.year == this.year;
    }
    return (this == now.endOfDay || this.isBefore(now.endOfDay)) &&
        (this == now.startOfDay || this.isAfter(now.startOfDay));
  }

  /// default format is: dd/MM/yyyy
  String format([String? format]) {
    if (format?.isEmpty ?? true) format = 'dd/MM/yyyy';

    var date = this;
    var location = AuthCubit.location;

    if (location != null) {
      date = tz.TZDateTime.from(this, location);
    }
    return DateFormat(format, AuthCubit.locale?.toLanguageTag() ?? 'en').format(date);
  }

  DateTime get toUserTimeZone {
    var location = AuthCubit.location;
    if (location != null) {
      return tz.TZDateTime.from(this, location);
    }
    return this;
  }

  DateTime copyWithDate(int year, int month, int day) {
    var dateTime = this.toUserTimeZone as tz.TZDateTime;
    return tz.TZDateTime(dateTime.location, year, month, day, dateTime.hour, dateTime.minute)
        .toLocal();
  }

  DateTime copyWithTime(int hour, int minutes) {
    var dateTime = this.toUserTimeZone as tz.TZDateTime;
    return tz.TZDateTime(
            dateTime.location, dateTime.year, dateTime.month, dateTime.day, hour, minutes)
        .toLocal();
  }
}

extension DurationUtils on Duration {
  String _twoDigits(int n) => n.toString().padLeft(2, "0");

  bool get _zeroMinutes => inMinutes.remainder(60) == 0;

  bool get _zeroHours => inHours == 0;

  String get _twoDigitMinutes => _twoDigits(inMinutes.remainder(60));

  String get _twoDigitSeconds => _twoDigits(inSeconds.remainder(60));

  String get formatHmShrink =>
      '${_zeroHours && !_zeroMinutes ? '' : '${inHours}h'}${_zeroMinutes ? '' : ' ${_twoDigitMinutes}m'}';

  String get formatHmLong => '${inHours}h ${_twoDigitMinutes}m';

  String get formatHMinLong => '${inHours}h ${_twoDigitMinutes}min';

  String get formatHoursMinutes => '${_twoDigits(inHours)}:$_twoDigitMinutes';

  String get formatHoursMinutesSeconds =>
      '${_twoDigits(inHours)}:$_twoDigitMinutes:$_twoDigitSeconds';

  String format([DurationFormat? format]) {
    if (format == DurationFormat.HM) return '${_twoDigits(inHours)}:$_twoDigitMinutes';
    if (format == DurationFormat.HMin) return this.formatHmLong;
    if (format == DurationFormat.MS) return '${_twoDigits(inMinutes)}:$_twoDigitSeconds';
    return this.formatHoursMinutesSeconds;
  }
}

enum DurationFormat { HMin, HM, HMS, MS }
