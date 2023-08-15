import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/main/projects/admin/admin_projects_cubit.dart';
import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

import 'admin_projects_widget.i18n.dart';

class AdminProjectsWidget extends StatelessWidget {
  const AdminProjectsWidget(this.tabController);

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: TabBarView(
        controller: tabController,
        children: [
          _ProjectsList(readProjects: (state) => state.activeProjects.value ?? []),
          _ProjectsList(readProjects: (state) => state.archivedProjects.value ?? []),
        ],
      ),
    );
  }
}

class _ProjectsList extends StatelessWidget {
  const _ProjectsList({Key? key, required this.readProjects}) : super(key: key);

  final List<AdminProject> Function(AdminProjectsReady state) readProjects;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminProjectsCubit, AdminProjectsState>(
      builder: (context, state) {
        List<dynamic> projects = [];
        List<Profile> users = [];
        bool loading = false;
        AppError? error;
        if (state is AdminProjectsReady) {
          users = state.users.value ?? [];
          projects = readProjects.call(state);
          loading = state.activeProjects.inProgress;
          error = state.activeProjects.error;
        }
        if (projects.isEmpty) {
          if (loading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (error != null) {
            return Text(error.formatted() ?? 'An error occurred'.i18n);
          }
        }
        return ListView.builder(
          itemCount: projects.length + 1,
          itemBuilder: (context, index) {
            if (index >= projects.length) {
              return SizedBox(height: kToolbarHeight);
            }
            if (projects[index] is Widget) {
              return projects[index];
            }
            return _AdminProjectRow(
              projects[index],
              users,
              onTap: users.isNotEmpty
                  ? () => BlocProvider.of<AdminProjectsCubit>(context)
                      .openAdminProject(context, projects[index])
                  : null,
            );
          },
        );
      },
    );
  }
}

class _AdminProjectRow extends StatelessWidget {
  const _AdminProjectRow(this.project, this.users, {this.onTap});

  final AdminProject project;
  final List<Profile> users;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Divider(height: 8),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: theme.textTheme.subtitle2,
                      ),
                    ),
                    Container(
                      decoration: projectDecoration(project.color, width: 60),
                      width: 60,
                      margin: EdgeInsets.only(right: 8),
                      height: 20,
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text('Assigned users'.i18n + ': ${project.assignees.length}'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
