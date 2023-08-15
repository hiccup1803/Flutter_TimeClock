import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

///This function throws an exception if a random generated number equals 1
void throwException() {
  if (Random().nextInt(2) == 1) throw Exception();
}

// String? validateNotNull({
//   required String? value,
//   required BuildContext context,
// }) {
//   if (value == null || value.isEmpty) {
//     return 'Required';
//   }
//   return null;
// }
//
// String? validateNotNullMinLength({
//   required String? value,
//   required BuildContext context,
//   required int minLength,
// }) {
//   if (value == null || value.isEmpty) {
//     return 'Field required';
//   } else if (value.length < minLength) {
//     return AppLocalizations.of(context)!.min_caracters(minLength.toString());
//   }
//   return null;
// }

// String? validateNumberInt(
//     {required String? value, required BuildContext context}) {
//   if (value == null || value.isEmpty) {
//     return AppLocalizations.of(context)!.field_required;
//   }
//   if (int.tryParse(value) == null) {
//     return AppLocalizations.of(context)!.value_invalid;
//   }
//   return null;
// }

// String? validateEmail({required String? value, required BuildContext context}) {
//   String pattern =
//       r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
//   RegExp regExp = RegExp(pattern);
//   if (value == null || value.isEmpty) {
//     return AppLocalizations.of(context)!.field_required;
//   } else if (!regExp.hasMatch(value)) {
//     return AppLocalizations.of(context)!.invalid_email;
//   } else {
//     return null;
//   }
// }

void showSnackBarMessage({
  required BuildContext context,
  required String hintMessage,
  int seconds = 2,
  IconData icon = Icons.check_outlined,
  double fontSize = 16,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration(seconds: seconds),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          SizedBox(
            width: 15,
          ),
          Text(hintMessage,
              style: GoogleFonts.openSans(
                fontSize: fontSize,
                color: Colors.white,
              )),
        ],
      ),
    ),
  );
}

void showOneButtonDialog(
  BuildContext context,
  String? title,
  String body,
  String buttonLabel,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 0.0),
      title: title == null
          ? null
          : Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Theme.of(context).textTheme.headline1!.color,
                fontWeight: FontWeight.bold,
              ),
            ),
      content: Text(
        body,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Theme.of(context).textTheme.headline1!.color,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            buttonLabel,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    ),
  );
}

Future showCustomModalBottomSheet({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
}) =>
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: builder,
    );
