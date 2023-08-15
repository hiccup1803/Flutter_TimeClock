import 'package:logging/logging.dart';
import 'package:staffmonitor/model/admin_nfc.dart';
import 'package:staffmonitor/service/api/admin_nfc_service.dart';

import '../model/paginated_list.dart';

class NfcRepository {
  NfcRepository(this._adminNfcService);

  final log = Logger('NfcRepository');
  final AdminNfcService _adminNfcService;

  Future<List<AdminNfc>> getAdminNfcs() async {
    late Paginated<AdminNfc> paginated;

    final response = await _adminNfcService.getFilteredNfc('');
    if (response.isSuccessful) {
      paginated = Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }

    return paginated.list ?? [];
  }

  Future<AdminNfc> getAdminNfcById(int id) async {
    final response = await _adminNfcService.getNfcById(id);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<AdminNfc> createAdminNfc(AdminNfc editedTask, String type, {int? userId}) async {
    final response = await _adminNfcService.postNfc(ApiNfc.fromAdminNfc(editedTask, type, userId));
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteAdminNfc(int id) async {
    final response = await _adminNfcService.deleteNfc(id);
    if (response.isSuccessful) {
      return true;
    } else {
      throw false;
    }
  }
}
