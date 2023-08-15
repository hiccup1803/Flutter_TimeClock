// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$TerminalService extends TerminalService {
  _$TerminalService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = TerminalService;

  @override
  Future<Response<UserHistory>> _getHistory(
    dynamic body,
    String terminalId,
  ) {
    final Uri $url = Uri.parse('terminal/history');
    final Map<String, String> $headers = {
      'X-Api-Key': terminalId,
    };
    final $body = body;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<UserHistory, UserHistory>($request);
  }

  @override
  Future<Response<TerminalAccess>> _putAccess(
    dynamic body,
    String terminalId,
  ) {
    final Uri $url = Uri.parse('terminal/access');
    final Map<String, String> $headers = {
      'X-Api-Key': terminalId,
    };
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<TerminalAccess, TerminalAccess>($request);
  }

  @override
  Future<Response<TerminalSession>> _putSession(
    dynamic body,
    String terminalId,
  ) {
    final Uri $url = Uri.parse('terminal/session');
    final Map<String, String> $headers = {
      'X-Api-Key': terminalId,
    };
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<TerminalSession, TerminalSession>($request);
  }

  @override
  Future<Response<TerminalSessionNfc>> _putSessionNfc(
    dynamic body,
    String terminalId,
  ) {
    final Uri $url = Uri.parse('terminal/session-nfc');
    final Map<String, String> $headers = {
      'X-Api-Key': terminalId,
    };
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<TerminalSessionNfc, TerminalSessionNfc>($request);
  }

  @override
  Future<Response<UserHistory>> _getHistoryNfc(
    dynamic body,
    String terminalId,
  ) {
    final Uri $url = Uri.parse('terminal/history-nfc');
    final Map<String, String> $headers = {
      'X-Api-Key': terminalId,
    };
    final $body = body;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<UserHistory, UserHistory>($request);
  }
}
