part of 'admin_projects_cubit.dart';

abstract class AdminProjectsState extends Equatable {
  const AdminProjectsState();
}

class AdminProjectsInitial extends AdminProjectsState {
  @override
  List<Object> get props => [];
}

class AdminProjectsReady extends AdminProjectsState {
  final Loadable<List<Profile>> users;
  final Loadable<List<AdminProject>> activeProjects;
  final Loadable<List<AdminProject>> archivedProjects;

  const AdminProjectsReady(this.users, this.activeProjects, this.archivedProjects);

  @override
  List<Object?> get props => [this.activeProjects, this.archivedProjects, this.users];
}
