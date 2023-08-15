part of 'employees_widget.dart';

class InvitationsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeesCubit, EmployeesState>(
      builder: (context, state) {
        bool loading = true;
        List<Invitation> invitations = List.empty();
        AppError? error;
        if (state is EmployeesReady) {
          loading = state.invitations.inProgress == true;
          invitations = state.invitations.value ?? List.empty();
          error = state.invitations.error;
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 2),
              height: 4,
              child: loading ? LinearProgressIndicator() : null,
            ),
            if (invitations.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: invitations.length,
                  itemBuilder: (context, index) {
                    final invitation = invitations[index];
                    return InvitationItemWidget(
                      invitation,
                      enabled: loading != true,
                      onDelete: () {
                        ConfirmDialog.showDanger(
                          context: context,
                          title: Text(
                            'Delete invitation?'.i18n,
                            style: TextStyle(color: AppColors.danger),
                          ),
                          content: Text("This operation can't be undone".i18n),
                          confirmLabel: 'Delete'.i18n,
                          cancelLabel: 'Cancel'.i18n,
                        ).then((value) {
                          if (value == true) {
                            BlocProvider.of<EmployeesCubit>(context).deleteInvitation(invitation);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            if (invitations.isEmpty && loading)
              Expanded(child: Center(child: Text('Loading\ninvitations'.i18n))),
            if (invitations.isEmpty && !loading && error == null)
              Expanded(child: Center(child: Text('No existing invitations'.i18n))),
            if (invitations.isEmpty && !loading && error != null)
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

class InvitationItemWidget extends StatelessWidget {
  const InvitationItemWidget(this.invitation, {Key? key, this.onDelete, this.enabled})
      : super(key: key);

  final Invitation invitation;
  final Function()? onDelete;
  final bool? enabled;

  void copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: invitation.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        content: Row(
          children: [
            Text('Copied: %s'.i18n.fill([invitation.code ?? ''])),
          ],
        ),
      ),
    );
  }

  void shareInvitation() {
    // Share.
    Share.share(invitation.link!, subject: 'Registration link'.i18n);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Invitation code'.i18n,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.color3,
                ),
              ),
            ),
            InkWell(
              onTap: enabled == true ? () => copyCode(context) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      invitation.code!,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.copy),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              child: Text(
                'Note'.i18n,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.color3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                invitation.note?.isNotEmpty == true ? invitation.note! : 'no note'.i18n,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.color1,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(primary: AppColors.color7),
                    onPressed: enabled == true ? shareInvitation : null,
                    icon: Icon(Icons.share),
                    label: Text('Share'.i18n),
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: VerticalDivider(color: AppColors.color7),
                ),
                Expanded(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(primary: AppColors.danger),
                    onPressed: enabled == true ? onDelete : null,
                    icon: Icon(Icons.delete_outline),
                    label: Text('Delete'.i18n),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
