import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/main/kiosk/admin/admin_nfc_cubit.dart';
import 'package:staffmonitor/bloc/main/kiosk/admin/admin_terminals_cubit.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/admin/kiosk/nfc/admin_accesscard_widget.dart';
import 'package:staffmonitor/page/main/admin/kiosk/nfc/admin_checkpoint_widget.dart';
import 'package:staffmonitor/page/settings/settings.i18n.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

import '../../../../../dijkstra.dart';

class NfcWidget extends StatefulWidget {
  @override
  _NfcWidgetState createState() => _NfcWidgetState();
}

class _NfcWidgetState extends State<NfcWidget> with TickerProviderStateMixin {
  late TabController _nestedTabController;

  @override
  void initState() {
    super.initState();
    _nestedTabController = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenHeight = MediaQuery.of(context).size.height;

    return BlocProvider<AdminNfcCubit>.value(
      value: BlocProvider.of<AdminNfcCubit>(context),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            if (_nestedTabController.index == 0) {
              Dijkstra.createAdminNfc('checkpoint', onChanged: () {
                BlocProvider.of<AdminNfcCubit>(context).refresh();
              });
            } else {
              Dijkstra.createAdminNfc('access_card', onChanged: () {
                BlocProvider.of<AdminNfcCubit>(context).refresh();
              });
            }
          },
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TabBar(
              controller: _nestedTabController,
              indicatorColor: AppColors.secondary,
              labelColor: AppColors.secondary,
              unselectedLabelColor: Colors.black54,
              isScrollable: true,
              tabs: <Widget>[
                Tab(
                  text: "Checkpoints".i18n,
                ),
                Tab(
                  text: "Access cards".i18n,
                ),
              ],
            ),
            Container(
              height: screenHeight * 0.70,
              margin: EdgeInsets.only(left: 12.0, right: 12.0),
              child: TabBarView(
                controller: _nestedTabController,
                children: <Widget>[AdminCheckpointWidget(), AdminAccessCardWidget()],
              ),
            )
          ],
        ),
      ),
    );
  }
}