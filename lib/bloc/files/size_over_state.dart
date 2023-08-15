part of 'size_over_cubit.dart';

abstract class SizeOverState extends Equatable {
  const SizeOverState();
}

class SizeOverEmpty extends SizeOverState {
  @override
  List<Object> get props => [];
}

class SizeOverExist extends SizeOverState {
  final List<String> nameLst;

  SizeOverExist(this.nameLst);

  @override
  List<Object> get props => [this.nameLst];
}
