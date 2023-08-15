import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import 'nfc_reader_state.dart';

class NfcReaderCubit extends Cubit<NfcReaderState> {
  NfcReaderCubit() : super(ReaderInitial());

  Future<bool> get isNfcAvailable => NfcManager.instance.isAvailable();

  final _newTagController = StreamController<String>.broadcast();

  Stream<String> get onNewTag => _newTagController.stream;

  @override
  Future<void> close() async {
    await stopNfc();
    return super.close();
  }

  Future<void> startNfc() async {
    // Check availability
    bool isAvailable = await isNfcAvailable;
    debugPrint('NfcReaderCubit.startNfc: $isAvailable');
    if (isAvailable) {
      // Start Session
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          // Do something with an NfcTag instance.
          debugPrint('NfcReaderCubit.startNfc: data -> ${tag.data}');

          var nfcTagId = _findTagId(tag);
          if (nfcTagId.isNotEmpty) {
            _newTagController.add(nfcTagId);
          }
        },
        onError: (error) async {
          debugPrint('NfcReaderCubit.startNfc: error -> $error');
        },
      );
    }
  }

  Future<void> stopNfc() => NfcManager.instance.stopSession();

  String _findTagId(NfcTag tag) {
    var nfca = NfcA.from(tag);
    if (nfca != null) {
      return nfca.identifier.toHex();
    }

    return '';
  }
}

extension Uint8ListEx on Uint8List {
  String toHex([String separator = '']) =>
      map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase()).join(separator);
}
