import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/holiday.dart';

part 'holiday_service.chopper.dart';

@ChopperApi(baseUrl: 'holidays')
abstract class HolidayService extends ChopperService {
  @Get()
  Future<Response<List<Holiday>>> getHolidays();

  static HolidayService create([ChopperClient? client]) =>
      _$HolidayService(client);
}
