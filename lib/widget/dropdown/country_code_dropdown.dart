import 'package:flutter/material.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

class CountryDropdown extends StatefulWidget {
  final String initialCountryCode;
  final ValueChanged<String> onCountrySelected;
  final List<String> data;

  const CountryDropdown({
    Key? key,
    required this.initialCountryCode,
    required this.onCountrySelected,
    required this.data,
  }) : super(key: key);

  @override
  State<CountryDropdown> createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  @override
  void initState() {
    _widgetsBinding.addPostFrameCallback((timeStamp) {
      widget.onCountrySelected(_initialValue);
    });
    super.initState();
  }

  dynamic get _widgetsBinding {
    return WidgetsBinding.instance;
  }

  String get _initialValue {
    return widget.initialCountryCode;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: Key('countryDropdown'),
      isDense: true,
      isExpanded: true,
      autofocus: true,
      alignment: AlignmentDirectional.centerStart,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(10),
        enabled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: AppColors.color3.withOpacity(0.4),
            width: 2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: AppColors.color3.withOpacity(0.4),
            width: 2,
          ),
        ),
      ),
      elevation: 8,
      itemHeight: 52.0,
      selectedItemBuilder: (c) {
        return widget.data
            .map(
              (e) => DropdownMenuItem<String>(
                child: Text(
                  '+$e',
                  overflow: TextOverflow.ellipsis,
                ),
                value: e,
              ),
            )
            .toList();
      },
      items: widget.data
          .map(
            (e) => DropdownMenuItem<String>(
              child: Container(
                width: 50,
                child: Text(
                  '+$e',
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                ),
              ),
              alignment: AlignmentDirectional.center,
              value: e,
            ),
          )
          .toList(),
      onChanged: (String? data) {
        if (data != null) {
          widget.onCountrySelected(data);
        }
      },
      value: _initialValue,
    );
  }
}