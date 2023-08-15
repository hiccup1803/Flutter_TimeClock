import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/invitation.dart';

import '../../../../utils/ui_utils.dart';
import '../../../../widget/dialog/dialogs.i18n.dart';

class CreateInvitationBottomSheet extends StatefulWidget {
  @override
  State<CreateInvitationBottomSheet> createState() => _CreateInvitationBottomSheetState();

  static Future<Invitation?> show({required BuildContext context}) {
    return showModalBottomSheet(
      context: context,
      enableDrag: false,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (sheetContext) => CreateInvitationBottomSheet(),
    );
  }
}

class _CreateInvitationBottomSheetState extends State<CreateInvitationBottomSheet> {
  bool processing = false;
  String? note;
  String? error;

  void _close() => Navigator.pop(context);

  void _save() {
    setState(() {
      processing = true;
      error = null;
    });
    injector.invitationRepository.create(note).then(
      (value) {
        Navigator.pop(context, value);
      },
      onError: (e, stack) {
        String? er = e.toString();
        if (e is AppError) {
          e.messages.forEach((element) {
            if (error == null) {
              er = element;
            } else {
              er = '$error\n$element';
            }
          });
        }
        setState(() {
          processing = false;
          error = er;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        top: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'New Invitation'.i18n,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.color6,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add a note to your new invitation'.i18n,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.color3,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            minLines: 5,
            maxLines: 8,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              enabled: processing != true,
              hintText: 'Write a note (optional)'.i18n,
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.color3,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              errorText: error,
            ),
            onChanged: (value) {
              setState(() {
                note = value;
              });
            },
            enabled: !processing,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: processing ? null : _save,
            style: ElevatedButton.styleFrom(minimumSize: Size(80, 45)),
            child: processing
                ? SpinKitWave(size: 20, color: Colors.white)
                : Text('Create Invitation'.i18n),
          ),
        ],
      ),
    );
  }
}
