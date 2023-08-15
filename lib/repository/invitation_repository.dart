import 'package:staffmonitor/model/invitation.dart';
import 'package:staffmonitor/service/api/invitation_service.dart';

class InvitationRepository {
  InvitationRepository(this.apiService);

  final InvitationService apiService;

  Future<List<Invitation>?> getAllInvitations() async {
    final response = await apiService.getInvitations();
    if (response.isSuccessful) {
      return response.body;
    } else {
      throw response.error!;
    }
  }

  Future<Invitation?> create(String? note) async {
    final response = await apiService.createInvitation(note);
    if (response.isSuccessful) {
      return response.body;
    } else {
      throw response.error!;
    }
  }

  Future<bool> delete(int? id) async {
    final response = await apiService.deleteInvitation(id);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }
}
