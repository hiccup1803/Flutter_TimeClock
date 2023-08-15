import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/session/edit/edit_session_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/session/edit/session_form.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

import '../sessions.i18n.dart';

class EditSessionPage extends BasePageWidget {
  static const String CHANGE_TYPE_KEY = 'change_type';
  static const String SESSION_KEY = 'session';
  static const String DATE_KEY = 'date';
  static const String ADMIN_KEY = 'admin';
  static const int SESSION_DELETED = 100;
  static const int SESSION_CHANGED = 101;

  static Map<String, dynamic> buildArgs(Session? session, {DateTime? date, bool admin = false}) => {
        SESSION_KEY: session,
        DATE_KEY: date,
        ADMIN_KEY: admin,
      };

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    final args = readArgs(context)!;
    Session? paramSession = args[SESSION_KEY];
    DateTime? paramDate = args[DATE_KEY];
    bool admin = args[ADMIN_KEY] ?? false;

    return BlocProvider(
      create: (context) {
        return EditSessionCubit(
            injector.sessionsRepository, profile?.allowNewRate, profile?.rateCurrency, admin)
          ..init(
            paramSession,
            date: paramDate,
          );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackIcon(),
          elevation: 0,
          centerTitle: true,
          title: Text(
            paramSession == null ? 'New Session'.i18n : 'Session Details'.i18n,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.color1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: SessionForm(
                paramSession?.note,
                paramSession?.hourRate ?? profile?.hourRate,
                profile,
                admin,
                paramSession?.bonus,
                paramSession?.bonusProposed,
                paramSession?.rateCurrency,
                isNew: paramSession == null),
          ),
        ),
      ),
    );
  }
}

class BackIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditSessionCubit, EditSessionState>(
      builder: (context, state) {
        bool changed = false;
        if (state is EditSessionReady) {
          changed = state.changed;
        }
        return IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Dijkstra.goBack(changed ? EditSessionPage.SESSION_CHANGED : null),
        );
      },
    );
  }
}
