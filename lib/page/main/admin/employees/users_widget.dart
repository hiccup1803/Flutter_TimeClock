part of 'employees_widget.dart';

class UsersWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeesCubit, EmployeesState>(
      builder: (context, state) {
        bool loading = true;
        List<Profile> users = List.empty();
        AppError? error;
        if (state is EmployeesReady) {
          loading = state.users.inProgress == true;
          users = state.users.value?.list ?? List.empty();
          error = state.users.error;
        }

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 4,
              child: loading ? LinearProgressIndicator() : null,
            ),
            if (users.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final profile = users[index];
                    return UserItemWidget(
                      profile,
                      onTap: () {
                        Dijkstra.editUser(
                          profile,
                          onChanged: (user) {
                            BlocProvider.of<EmployeesCubit>(context).onUserChanged(user);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            if (users.isEmpty && loading) Expanded(child: Center(child: Text('Loading'.i18n))),
            if (users.isEmpty && !loading && error == null) Expanded(child: Center(child: Text('No users'.i18n))),
            if (users.isEmpty && !loading && error != null)
              Expanded(
                child: Center(
                  child: Text(
                    error.formatted() ?? 'Error'.i18n,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class UserItemWidget extends StatelessWidget {
  const UserItemWidget(this.profile, {this.onTap});

  final Profile profile;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                profile.name!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.color1,
                ),
              ),
              // SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0, right: 8.0),
                    child: Icon(
                      Icons.alternate_email,
                      size: 12,
                      color: AppColors.color3,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      profile.email!,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.color3,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outlined,
                    size: 12,
                    color: AppColors.color3,
                  ),
                  SizedBox(width: 4),
                  Text(
                    (profile.isSuperAdmin
                        ? 'Super Admin'.i18n
                        : profile.isSupervisor
                            ? 'Supervisor'.i18n
                            : profile.isAdmin
                                ? 'Admin'.i18n
                                : 'Employee'.i18n),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(
                    Icons.check_circle_outline,
                    size: 12,
                    color: AppColors.color3,
                  ),
                  SizedBox(width: 4),
                  Text(
                    profile.isActive
                        ? 'Active'.i18n
                        : profile.isDeleted
                            ? 'Deactivated'.i18n
                            : 'Registered'.i18n,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
