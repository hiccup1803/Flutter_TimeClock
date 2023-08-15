import 'package:staffmonitor/page/base_page.dart';

import 'dialogs.i18n.dart';

class SelectListDialog<Z> extends AlertDialog {
  SelectListDialog({
    required List<Z> options,
    required Widget Function(BuildContext context, Z item) itemBuilder,
    required List<Widget> actions,
    List<Z>? selected,
    Widget Function()? emptyBuilder,
    Function(Z item)? toggle,
    Function()? clear,
    Function()? selectAll,
  }) : super(
          actions: actions,
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected != null && toggle != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: selected.length > 0 ? clear : null,
                        child: Text('Clear'.i18n),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: selected.length != options.length ? selectAll : null,
                        child: Text('Select all'.i18n),
                      ),
                    ],
                  ),
                if (selected == null && toggle == null) Text('Select User'.i18n),
                Divider(),
                if (options.length == 0) emptyBuilder?.call() ?? Text(''),
                if (options.length > 0)
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final item = options[index];

                        if (selected != null && toggle != null) {
                          return Container(
                            color: selected.contains(item) ? Colors.blueGrey.shade300 : null,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  toggle.call(item);
                                },
                                child: itemBuilder.call(context, item),
                              ),
                            ),
                          );
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pop(item);
                          },
                          child: itemBuilder.call(context, item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );

  static Future<T?> showSelectOne<T>({
    required BuildContext context,
    List<T> options = const [],
    required Widget Function(BuildContext context, T item) itemBuilder,
    Widget Function()? emptyBuilder,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return SelectListDialog<T>(
          options: options,
          itemBuilder: itemBuilder,
          emptyBuilder: emptyBuilder,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.i18n),
            ),
          ],
        );
      },
    );
  }

  static Future<List<T>?> showSelectMany<T>({
    required BuildContext context,
    List<T> options = const [],
    required Widget Function(BuildContext context, T item) itemBuilder,
    Widget Function()? emptyBuilder,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        List<T> selected = [];
        return StatefulBuilder(
          builder: (context, setState) {
            return SelectListDialog<T>(
              options: options,
              itemBuilder: itemBuilder,
              emptyBuilder: emptyBuilder,
              selected: selected,
              toggle: (item) {
                setState(() {
                  if (selected.remove(item) != true) {
                    selected.add(item);
                  } else {
                    print('removed');
                  }
                });
              },
              clear: () {
                setState(() {
                  selected = [];
                });
              },
              selectAll: () {
                setState(() {
                  selected = List.from(options);
                });
              },
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'.i18n),
                ),
                TextButton(
                  onPressed: selected.isEmpty ? null : () => Navigator.pop(context, selected),
                  child: Text('Ok'.i18n),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
