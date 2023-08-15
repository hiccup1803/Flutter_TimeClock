import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

typedef void OnKey(String value);
typedef void OnClear();
typedef void OnSubmit();

class NumericKeyboardWidget extends StatelessWidget {
  const NumericKeyboardWidget(
      {this.onKey, this.onClear, this.onSubmit, this.enabled = true, this.playClicks = true});

  final OnKey? onKey;
  final OnClear? onClear;
  final OnSubmit? onSubmit;
  final bool enabled;
  final bool playClicks;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Size size = Size(80, 80);
      TextStyle textStyle = TextStyle(fontSize: 20);
      double iconSize = 20;
      if (constraints.maxHeight.isFinite) {
        double d = (constraints.maxHeight - 60) / 4;
        textStyle = TextStyle(fontSize: d / 3);
        iconSize = d / 2;
        size = Size(d, d);
      }

      final buttonStyle = TextButton.styleFrom(
        minimumSize: size,
        textStyle: textStyle,
        primary: AppColors.primary,
      );
      final acceptStyle = TextButton.styleFrom(
        minimumSize: size,
        textStyle: textStyle,
        primary: AppColors.positiveGreen,
      );
      final clearStyle = TextButton.styleFrom(
        minimumSize: size,
        textStyle: textStyle,
        primary: Colors.red,
      );

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _SingleKey(
                    value: '1',
                    onKey: enabled ? onKey : null,
                    style: buttonStyle,
                  ),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  child: _SingleKey(
                    value: '2',
                    onKey: enabled ? onKey : null,
                    style: buttonStyle,
                  ),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  child: _SingleKey(
                    value: '3',
                    onKey: enabled ? onKey : null,
                    style: buttonStyle,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _SingleKey(
                    value: '4',
                    onKey: enabled ? onKey : null,
                    style: buttonStyle,
                  ),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  child: _SingleKey(
                    value: '5',
                    onKey: enabled ? onKey : null,
                    style: buttonStyle,
                  ),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  child: _SingleKey(
                    value: '6',
                    onKey: enabled ? onKey : null,
                    style: buttonStyle,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _SingleKey(
                    value: '7',
                    onKey: enabled ? onKey : null,
                    style: buttonStyle,
                  ),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  child: _SingleKey(
                    value: '8',
                    onKey: enabled ? onKey : null,
                    style: buttonStyle,
                  ),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  child: _SingleKey(
                    value: '9',
                    onKey: enabled ? onKey : null,
                    style: buttonStyle,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _SingleKey(
                    value: '-1',
                    child: Icon(
                      Icons.close,
                      size: iconSize,
                    ),
                    onKey: enabled && onClear != null
                        ? (value) {
                            onClear?.call();
                          }
                        : null,
                    style: clearStyle,
                  ),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  child: _SingleKey(
                    value: '0',
                    onKey: enabled ? onKey : null,
                    style: buttonStyle,
                  ),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  child: _SingleKey(
                    value: '-2',
                    child: Icon(
                      Icons.check,
                      size: iconSize,
                    ),
                    onKey: enabled && onSubmit != null
                        ? (value) {
                            onSubmit?.call();
                          }
                        : null,
                    style: acceptStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _SingleKey extends StatelessWidget {
  const _SingleKey({
    required this.value,
    this.style,
    this.child,
    this.onKey,
    this.playClick = true,
  });

  final Widget? child;
  final String value;
  final OnKey? onKey;
  final ButtonStyle? style;
  final bool playClick;

  void _onPressed() {
    if (playClick == true) {
      SystemSound.play(SystemSoundType.click);
    }
    onKey?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: style,
      onPressed: onKey != null ? _onPressed : null,
      child: child ?? Text(value),
    );
  }
}
