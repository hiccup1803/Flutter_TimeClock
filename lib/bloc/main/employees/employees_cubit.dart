import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:staffmonitor/model/invitation.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/repository/invitation_repository.dart';
import 'package:staffmonitor/repository/users_repository.dart';

part 'employees_state.dart';

class EmployeesCubit extends Cubit<EmployeesState> {
  EmployeesCubit(
    this.invitationRepository,
    this.usersRepository,
  ) : super(EmployeesInitial());

  final InvitationRepository invitationRepository;
  final UsersRepository usersRepository;

  Loadable<List<Invitation>?> invitationsLoadable = Loadable.inProgress();
  Loadable<Paginated<Profile>> usersLoadable = Loadable.inProgress();

  void refresh({bool invitations = true, bool users = true}) {
    updateState(
      invitations: invitations ? Loadable.inProgress(invitationsLoadable.value) : null,
      users: users ? Loadable.inProgress(usersLoadable.value) : null,
    );

    if (invitations) {
      invitationRepository.getAllInvitations().then(
        (value) {
          updateState(invitations: Loadable.ready(value));
        },
        onError: (e) {
          updateState(invitations: Loadable.error(e, invitationsLoadable.value));
        },
      );
    }
    if (users) {
      usersRepository.getUsers(page: 1).then(
        (value) {
          if (value.hasMore) {
            updateState(users: Loadable.inProgress(value));
            getUsersNextPage(value);
          } else {
            updateState(users: Loadable.ready(value));
          }
        },
        onError: (e, stack) {
          updateState(users: Loadable.error(e, usersLoadable.value));
        },
      );
    }
  }

  void getUsersNextPage(Paginated<Profile> paginated) {
    usersRepository.getUsers(page: paginated.page + 1).then(
      (value) {
        value = paginated += value;
        if (value.hasMore) {
          updateState(users: Loadable.inProgress(value));
          getUsersNextPage(value);
        } else {
          updateState(users: Loadable.ready(value));
        }
      },
      onError: (e, stack) {
        updateState(users: Loadable.error(e, usersLoadable.value));
      },
    );
  }

  void updateState({
    Loadable<List<Invitation>?>? invitations,
    Loadable<Paginated<Profile>>? users,
  }) {
    if (invitations != null) this.invitationsLoadable = invitations;
    if (users != null) this.usersLoadable = users;

    emit(EmployeesReady(invitationsLoadable, usersLoadable));
  }

  void onInviteCreated(Invitation invite) {
    refresh(users: false);
  }

  void deleteInvitation(Invitation invitation) {
    //todo emit some loading maybe?
    invitationRepository.delete(invitation.id).then(
      (result) {
        if (result == true) refresh(users: false);
      },
      onError: (e) {
        //todo
      },
    );
  }

  void onUserChanged(Profile? user) {
    refresh(invitations: false);
  }
}
