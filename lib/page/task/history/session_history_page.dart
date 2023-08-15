import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/bloc/history/history_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/widget/history/history_widget.dart';
import 'package:staffmonitor/widget/session/session_row.dart';

import '../task.i18n.dart';

class SessionHistoryPage extends BasePageWidget {
  final log = Logger('SessionHistoryPage');

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    final theme = Theme.of(context);
    final locale = BlocProvider.of<AuthCubit>(context).state.locale;

    return BlocProvider<HistoryCubit>(
      create: (context) =>
          HistoryCubit(injector.sessionsRepository, injector.networkStatusService, _mapListToDates)
            ..init(DateTime.now()),
      child: Scaffold(
        floatingActionButton: SessionFab(),
        appBar: AppBar(
          titleSpacing: 0,
          title: Text(
            'Sessions history'.i18n,
            style: theme.textTheme.headline4,
          ),
        ),
        body: SafeArea(
          child: HistoryWidget(
            locale: locale,
            buildItemRow: (ctx, item) => buildRow(ctx, item, profile!.allowWageView),
            buildEmpty: buildEmpty,
            eventsToString: eventsToString,
            style: HistoryCalendarStyle(
              square: true,
              // borderSelection: true,
              hasEvents: Colors.indigoAccent,
              events: Colors.amber,
              today: Colors.amberAccent.withAlpha(40),
              selected: Colors.amberAccent,
              selectedEvents: Colors.cyanAccent,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(context, item, bool allowWageView) {
    return SessionRow(
      item,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      onDeleted: ([session]) {
        BlocProvider.of<HistoryCubit>(context).onItemDeleted(session);
      },
      onChanged: ([session]) {
        BlocProvider.of<HistoryCubit>(context).onItemChanged(session, month: session?.clockIn);
      },
      allowWageView: allowWageView,
    );
  }

  Widget buildEmpty(context, DateTime day) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'No session registered'.i18n,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );
  }

  String eventsToString(List events) {
    return (events.length).toString();
  }

  Map<DateTime, List> _mapListToDates(Paginated? paginated) {
    log.fine('_mapListToDates($paginated)');

    if (paginated == null || paginated.totalCount == 0) return Map();
    final Map<DateTime, List<Session>> result = Map();
    paginated.list!.forEach((element) {
      log.finest('item: ${element.runtimeType}, $element');
      Session session = element as Session;
      final day = session.clockIn!.noon;
      final List<Session> list = List.from(result[day] ?? List.empty());
      list.add(session);
      result[day] = list;
    });
    log.finest('_mapListToDates => result $result');
    return result;
  }
}

class SessionFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      icon: Icon(Icons.add),
      label: Text('Add session'.i18n),
      onPressed: () {
        Dijkstra.createSession(
          onChanged: ([session]) {
            BlocProvider.of<HistoryCubit>(context).onItemChanged(session, month: session.clockIn);
          },
        );
      },
    );
  }
}
