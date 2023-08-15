part of 'admin_off_times_widget.dart';

class _AdminOffTimesSummary extends StatelessWidget {
  _AdminOffTimesSummary({
    required this.filter,
  });

  final List<AdminOffTime> Function(List<AdminOffTime> list) filter;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminOffTimesCubit, AdminOffTimesState>(
      builder: (context, state) {
        List<AdminOffTime> list = [];
        List<Profile> users = [];
        String error = '';
        bool inProgress = true;
        if (state is AdminOffTimesReady) {
          list = filter.call(state.offTimes.value ?? []);
          error = state.offTimes.error?.formatted() ?? '';
          users = state.users.value ?? [];
          inProgress = state.offTimes.inProgress || state.users.inProgress;
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
            final whereUser = users.where((element) => element.id == offTime.userId);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Card(
                elevation: 0,
                child: AdminOffTimeRowWidget(
                  offTime,
                  whereUser.isNotEmpty ? whereUser.first : null,
                  onTap: inProgress
                      ? null
                      : () {
                          AdminOffTimeBottomSheet.show(
                            context,
                            offTime: offTime,
                            profile: whereUser.first,
                            onDelete: () =>
                                BlocProvider.of<AdminOffTimesCubit>(context).deleteOffTime(offTime),
                            onDeny: () =>
                                BlocProvider.of<AdminOffTimesCubit>(context).denyOffTime(offTime),
                            onAccept: () =>
                                BlocProvider.of<AdminOffTimesCubit>(context).acceptOffTime(offTime),
                            onChanged: (offTime) => BlocProvider.of<AdminOffTimesCubit>(context)
                                .onOffTimeChanged(offTime),
                          );
                        },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
