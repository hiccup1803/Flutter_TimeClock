// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$InvitationService extends InvitationService {
  _$InvitationService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = InvitationService;

  @override
  Future<Response<dynamic>> deleteInvitation(int? id) {
    final Uri $url = Uri.parse('admin-invites/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Invitation>> getInvitation(int id) {
    final Uri $url = Uri.parse('admin-invites/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Invitation, Invitation>($request);
  }

  @override
  Future<Response<List<Invitation>>> getInvitations() {
    final Uri $url = Uri.parse('admin-invites');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<Invitation>, Invitation>($request);
  }

  @override
  Future<Response<Invitation>> postInvitation(dynamic body) {
    final Uri $url = Uri.parse('admin-invites');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Invitation, Invitation>($request);
  }
}
