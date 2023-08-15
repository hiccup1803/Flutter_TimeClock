part of 'my_projects_widget.dart';

class MyProjectsListWidget extends StatelessWidget {
  MyProjectsListWidget(this.preferredProjects, this.allowWageView);

  final List<int> preferredProjects;
  final bool allowWageView;
  final log = Logger('ProjectsListWidget');

  @override
  Widget build(BuildContext context) {
    List<int> preferredProjects = this.preferredProjects;
    return BlocBuilder<MyProjectsCubit, MyProjectsState>(
      builder: (context, state) {
        log.fine('message: $state');

        List<Project>? list = List.empty();
        Map<int?, SessionsSummary> summaries = Map();
        if (state is ProjectsReady) {
          list = state.projects;
          summaries = state.summaries;
        }

        if (list!.isEmpty) {
          if (state is ProjectsInitial || state is ProjectsLoading) {
            return Center(
              child: Text('Downloading projects'.i18n),
            );
          }
          return Center(
            child: Text('No projects'.i18n),
          );
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final project = list![index];
            return ProjectWidget(
              project,
              summaries[project.id],
              allowWageView: allowWageView,
              preferred: preferredProjects.contains(project.id),
            );
          },
        );
      },
    );
  }
}

class ProjectWidget extends StatefulWidget {
  ProjectWidget(
    this.project,
    this.summary, {
    this.preferred = false,
    this.allowWageView = false,
    this.changePreference,
  });

  final Project project;
  final SessionsSummary? summary;
  final bool preferred;
  final bool allowWageView;
  final Function(bool prefer)? changePreference;

  @override
  _ProjectWidgetState createState() => _ProjectWidgetState();
}

class _ProjectWidgetState extends State<ProjectWidget> {
  bool loading = false;
  final log = Logger('ProjectWidget');

  void changePreference() {
    setState(() {
      loading = true;
    });
    if (widget.preferred) {
      BlocProvider.of<AuthCubit>(context).removeProjectFromPreferred(widget.project.id).then((_) {
        setState(() {
          loading = false;
        });
      }, onError: (e) {
        setState(() {
          loading = false;
        });
      });
    } else {
      BlocProvider.of<AuthCubit>(context).addProjectToPreferred(widget.project.id).then((_) {
        setState(() {
          loading = false;
        });
      }, onError: (e) {
        setState(() {
          loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      child: Container(
        decoration: projectDecoration(widget.project.color),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.project.name,
                      style: theme.textTheme.headline6,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      widget.preferred ? Icons.star : Icons.star_border,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: loading ? null : changePreference,
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Divider(),
                  if (loading) LinearProgressIndicator(),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sessions'.i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.subtitle1,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Time'.i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.subtitle1,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Earnings'.i18n,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.subtitle1,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DecoratedValueWidget(
                        '${widget.summary?.sessionsCount ?? '-'}',
                        type: DecoratedValue.SESSIONS,
                      ),
                    ),
                    Expanded(
                      child: DecoratedValueWidget(
                        '${widget.summary?.duration.formatHmLong ?? '-'}',
                      ),
                    ),
                    Expanded(
                      child: DecoratedValueWidget(
                        (widget.allowWageView == true && widget.summary?.wages.isNotEmpty == true)
                            ? '${widget.summary?.wages.first.wage} ${widget.summary?.wages.first.currency}'
                            : '-',
                        type: DecoratedValue.MONEY,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
