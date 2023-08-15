import 'package:flutter/material.dart';
import 'package:staffmonitor/utils/time_utils.dart';

class TimeWidget extends StatefulWidget {
  final DateTime? time;
  final String? format;
  final Widget Function(BuildContext context, String formattedTime) builder;

  TimeWidget({
    this.time,
    this.format,
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  _TimeWidgetState createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  String _text = '';

  DateTime? get _time => widget.time; // ?? DateTime.now();

  String get _format => widget.format ?? 'HH:mm:ss';

  @override
  void initState() {
    super.initState();
    print('init time: $_time');
    _text = _time?.format(_format) ?? '00:00:00';
    if (_time != null) {
      Future.delayed(Duration(seconds: 1), nextTic);
    }
  }

  nextTic() {
    print('nextTic');
    if (mounted) {
      setState(() {
        _text = _time?.format(_format) ?? '00:00:00';
      });
      Future.delayed(Duration(seconds: 1), nextTic);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder.call(context, _text);
}
