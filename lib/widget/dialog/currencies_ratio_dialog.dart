import 'package:flutter/material.dart';
import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/page/base_page.dart';

import 'dialogs.i18n.dart';

class CurrenciesRatioDialog extends AlertDialog {
  CurrenciesRatioDialog({
    required BuildContext context,
    Widget? title,
    Widget? content,
    Function()? close,
    Function()? save,
  }) : super(
          title: title,
          content: content,
          actions: [
            TextButton(
              onPressed: close,
              child: Text('Cancel'.i18n),
            ),
            TextButton(
              onPressed: save,
              child: Text('Confirm'.i18n),
            ),
          ],
        );

  static Future<List<CurrencyExchange>?> show({
    required BuildContext context,
    required List<CurrencyExchange> list,
    Widget? title,
  }) {
    return showDialog<List<CurrencyExchange>?>(
      context: context,
      builder: (context) {
        final currencyList = list.map((e) => _Currency(e)).toList();
        if (currencyList.isEmpty) {
          currencyList.add(_Currency.empty());
        }
        bool canSave = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return CurrenciesRatioDialog(
              context: context,
              close: () => Navigator.pop(context),
              save: canSave
                  ? () =>
                      Navigator.pop(context, currencyList.map((e) => e.toCurrencyExchange).toList())
                  : null,
              title: title,
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Currency'.i18n)),
                        SizedBox(width: 8),
                        Expanded(child: Text('Exchange Ratio'.i18n, textAlign: TextAlign.center)),
                        SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              currencyList.add(_Currency.empty());
                            });
                          },
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: currencyList.length,
                        itemBuilder: (context, index) {
                          final item = currencyList[index];
                          return Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: item.currencyController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(8),
                                    border: OutlineInputBorder(),
                                  ),
                                  textAlignVertical: TextAlignVertical.top,
                                  onChanged: (value) {
                                    setState(
                                        () => canSave = item.currencyExchange.currency != value);
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: item.exchangeRatioController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(8),
                                    border: OutlineInputBorder(),
                                  ),
                                  textAlignVertical: TextAlignVertical.top,
                                  onChanged: (value) {
                                    setState(() => canSave = item.currencyExchange.rate != value);
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (1 < currencyList.length) {
                                      currencyList.remove(item);
                                    }
                                  });
                                },
                                icon: Icon(Icons.close, color: Color(0xFFFF0000)),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) => SizedBox(height: 8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Currency {
  final CurrencyExchange currencyExchange;
  late final TextEditingController currencyController;
  late final TextEditingController exchangeRatioController;

  _Currency(this.currencyExchange) {
    this.currencyController = TextEditingController(text: currencyExchange.currency ?? '');
    this.exchangeRatioController = TextEditingController(text: currencyExchange.rate ?? '');
  }

  factory _Currency.empty() => _Currency(CurrencyExchange('', ''));

  CurrencyExchange get toCurrencyExchange =>
      CurrencyExchange(currencyController.text, exchangeRatioController.text);
}
