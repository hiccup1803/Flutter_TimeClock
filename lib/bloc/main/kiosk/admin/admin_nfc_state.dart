part of 'admin_nfc_cubit.dart';

abstract class AdminNfcState extends Equatable {
  const AdminNfcState();
}

class AdminNfcInitial extends AdminNfcState {
  @override
  List<Object> get props => [];
}

class AdminNfcReady extends AdminNfcState {
  final Loadable<List<Profile>> users;
  final Loadable<List<AdminNfc>> nfcList;

  const AdminNfcReady(this.users, this.nfcList);

  @override
  List<Object?> get props => [this.nfcList, this.users];
}

class AdminNfcSaved extends AdminNfcState {
  AdminNfcSaved(this.nfcList, {this.closePage = true});

  final Loadable<List<AdminNfc>> nfcList;
  final bool closePage;

  @override
  List<Object?> get props => [this.nfcList, this.closePage];
}

class AdminNfcDeleted extends AdminNfcSaved {
  AdminNfcDeleted(Loadable<List<AdminNfc>> nfcList) : super(nfcList, closePage: true);
}
