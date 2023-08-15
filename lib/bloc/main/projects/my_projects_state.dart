part of 'my_projects_cubit.dart';

abstract class MyProjectsState extends Equatable {
  const MyProjectsState();
}

class ProjectsInitial extends MyProjectsState {
  @override
  List<Object> get props => [];
}

class ProjectsReady extends MyProjectsState {
  ProjectsReady(this.month, this.projects, this.summaries);

  final DateTime? month;
  final List<Project>? projects;
  final Map<int?, SessionsSummary> summaries;

  @override
  List<Object?> get props => [this.month, this.projects, this.summaries];

  @override
  String toString() {
    return 'ProjectsReady{month: $month}';
  }
}

class ProjectsLoading extends ProjectsReady {
  ProjectsLoading(DateTime? month, List<Project>? projects, Map<int?, SessionsSummary> summaries)
      : super(month, projects, summaries);

  @override
  String toString() {
    return 'ProjectsReady{month: $month}';
  }
}
