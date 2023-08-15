import 'dart:io';

class NetworkStatusService {
  const NetworkStatusService(this._baseDomain);

  final String _baseDomain;

  Future<bool> isNetworkAvailable() async {
    var netResult;
    try {
      netResult = await InternetAddress.lookup(_baseDomain);
    } on SocketException catch (_) {}
    return netResult != null ? true : false;
  }
}
