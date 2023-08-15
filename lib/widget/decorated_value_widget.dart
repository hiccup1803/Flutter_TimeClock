import 'package:flutter/material.dart';
import 'package:staffmonitor/utils/color_utils.dart';

class DecoratedValueWidget extends StatelessWidget {
  const DecoratedValueWidget(this.value, {this.type, this.color});

  final String value;
  final DecoratedValue? type;
  final Color? color;

  Color? get _color {
    if (color != null) {
      return color;
    }

    if (type == DecoratedValue.MONEY || type == DecoratedValue.MONEY_THIN) {
      return Colors.greenAccent;
    }
    if (type == DecoratedValue.SESSIONS) {
      return Colors.yellow.shade200;
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textStyle = theme.textTheme.bodyText1;
    if (type == DecoratedValue.HOURS_THIN || type == DecoratedValue.MONEY_THIN) {
      textStyle = textStyle!.copyWith(fontWeight: FontWeight.w300);
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: _color,
          shadows: [
            BoxShadow(
                color: Colors.grey.withAlpha(100),
                offset: Offset(0, 1),
                blurRadius: 1.0,
                spreadRadius: 0.0)
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: textStyle!.copyWith(color: _color!.contrastColor()),
          ),
        ),
      ),
    );
  }
}

enum DecoratedValue { SESSIONS, HOURS, HOURS_THIN, MONEY, MONEY_THIN }
