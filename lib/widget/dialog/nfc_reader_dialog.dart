import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/kiosk/nfc_reader/nfc_reader_cubit.dart';

class NfcReaderDialog extends StatefulWidget {
  const NfcReaderDialog({Key? key}) : super(key: key);

  @override
  State<NfcReaderDialog> createState() => _NfcReaderDialogState();
}

class _NfcReaderDialogState extends State<NfcReaderDialog> {
  StreamSubscription? _stream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stream = BlocProvider.of<NfcReaderCubit>(context).onNewTag.listen((event) {
        BlocProvider.of<NfcReaderCubit>(context).stopNfc();
        Navigator.pop(context, event);
      });

      BlocProvider.of<NfcReaderCubit>(context).startNfc();
    });
  }

  @override
  void dispose() {
    _stream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('NFC'),
      content: Text('Touch NFC Card'),
      actions: [
        TextButton(
          onPressed: () {
            BlocProvider.of<NfcReaderCubit>(context).stopNfc();
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
