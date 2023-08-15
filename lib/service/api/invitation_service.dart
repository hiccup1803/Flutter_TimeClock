import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/invitation.dart';

part 'invitation_service.chopper.dart';

@ChopperApi(baseUrl: 'admin-invites')
abstract class InvitationService extends ChopperService {
  static InvitationService create([ChopperClient? client]) =>
      _$InvitationService(client);

  @Delete(path: '{id}')
  Future<Response> deleteInvitation(@Path('id') int? id);

  @Get(path: '{id}')
  Future<Response<Invitation>> getInvitation(@Path('id') int id);

  @Get()
  Future<Response<List<Invitation>>> getInvitations();

  @Post()
  Future<Response<Invitation>> postInvitation(@Body() body);

  Future<Response<Invitation>> createInvitation(String? note) =>
      postInvitation({'note': note});
}
