part of 'my_off_times_widget.dart';

class _MyOffTimesSummary extends StatelessWidget {
  _MyOffTimesSummary({
    required this.filter,
  });

  final List<OffTime> Function(List<OffTime> list) filter;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyOffTimesCubit, MyOffTimesState>(
      builder: (context, state) {
        List<OffTime> list = [];
        String error = '';
        bool inProgress = true;
        if (state is MyOffTimesReady) {
          list = filter.call(state.offTimes.value ?? []);
          error = state.offTimes.error?.formatted() ?? '';
          inProgress = state.offTimes.inProgress;
        }
        if (list.isEmpty) {
          return SizedBox();
        }

        if (error.isNotEmpty) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  error,
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
              ),
            ],
          );
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final offTime = list[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Card(
                elevation: 0,
                child: MyOffTimeRowWidget(
                  offTime,
                  onTap: inProgress
                      ? null
                      : () {
                    MyOffTimeBottomSheet.show(
                      context,
                      offTime: offTime,

                      // onDelete: () =>
                      //     BlocProvider.of<AdminOffTimesCubit>(context).deleteOffTime(offTime),
                      // onDeny: () =>
                      //     BlocProvider.of<AdminOffTimesCubit>(context).denyOffTime(offTime),
                      // onAccept: () =>
                      //     BlocProvider.of<AdminOffTimesCubit>(context).acceptOffTime(offTime),
                      // onChanged: (offTime) => BlocProvider.of<AdminOffTimesCubit>(context)
                      //     .onOffTimeChanged(offTime),
                    );
                  },
                ),
              ),
            );
          },
        );
        // return ExpansionTile(
        //   title: Row(
        //     children: [
        //       Icon(icon),
        //       Container(width: 8),
        //       Text('$title (${list.length})'),
        //     ],
        //   ),
        //   initiallyExpanded: initiallyExpanded,
        //   key: ValueKey('${title}_${list.length}'),
        //   tilePadding: const EdgeInsets.symmetric(horizontal: 8.0),
        //   childrenPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        //   children: [
        //     if (error.isNotEmpty) Text(error),
        //     if (inProgress) LinearProgressIndicator(),
        //   ]..addAll(list.map(
        //       (offTime) {
        //         return MyOffTimeRowWidget(
        //           offTime,
        //           onTap: inProgress
        //               ? null
        //               : () {
        //                   MyOffTimeBottomSheet.show(
        //                     context,
        //                     offTime: offTime,
        //                   );
        //                 },
        //         );
        //       },
        //     )),
        // );
      },
    );
  }
}
