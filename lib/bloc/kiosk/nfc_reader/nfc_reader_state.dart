import 'package:equatable/equatable.dart';

abstract class NfcReaderState extends Equatable {
  const NfcReaderState();
}

class ReaderInitial extends NfcReaderState {
  @override
  List<Object> get props => [];
}

class ReaderStartInitial extends NfcReaderState {
  @override
  List<Object> get props => [];
}

class ReaderStopInitial extends NfcReaderState {
  @override
  List<Object> get props => [];
}
