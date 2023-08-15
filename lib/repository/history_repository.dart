import 'package:staffmonitor/model/paginated_list.dart';

abstract class HistoryRepository {
  Future<Paginated<dynamic>> getHistoryItems(DateTime from, DateTime to, int page);
}
