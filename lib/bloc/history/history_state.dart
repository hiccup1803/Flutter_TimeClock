part of 'history_cubit.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();

  @override
  List<Object> get props => [];
}

class HistoryReady extends HistoryState {
  const HistoryReady(this.list);

  final Loadable<Map<DateTime, List>> list;

  @override
  List<Object> get props => [this.list];
}
