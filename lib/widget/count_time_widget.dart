import 'package:flutter/material.dart';
import 'package:staffmonitor/utils/time_utils.dart';

class CountTimeWidget extends StatefulWidget {
  final DateTime? startTime;
  final DurationFormat? format;
  final bool allowNegative;
  final Widget Function(BuildContext context, String durationText) builder;

  CountTimeWidget({
    required this.startTime,
    required this.builder,
    this.format,
    this.allowNegative = false,
    Key? key,
  }) : super(key: key);

  @override
  _CountTimeWidgetState createState() => _CountTimeWidgetState();
}

class _CountTimeWidgetState extends State<CountTimeWidget> {
  late String _text;

  Duration? get _duration =>
      widget.startTime != null ? DateTime.now().difference(widget.startTime!) : null;

  @override
  void initState() {
    super.initState();
    var dur = _duration;
    if (dur == null)
      _text = widget.format == DurationFormat.HMS ? '--:--:--' : '--:--';
    else
      _text = dur.format(widget.format);

    Future.delayed(Duration(seconds: 1), nextTic);
  }

  nextTic() {
    if (mounted) {
      setState(() {
        var duration = _duration;
        if (duration == null || (duration.isNegative && widget.allowNegative != true)) {
          duration = Duration();
        }
        _text = duration.format(widget.format);
      });
      Future.delayed(Duration(seconds: 1), nextTic);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder.call(context, _text);
}
