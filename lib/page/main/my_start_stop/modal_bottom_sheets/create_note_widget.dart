import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/functions.dart';
import '../../../../widget/custom_elevated_button.dart';
import '../../../../widget/custom_text_form_field.dart';
import '../my_start_stop.i18n.dart';

class CreateNote extends StatefulWidget {
  final Future<void> Function(String) createNote;
  final String? initialNote;
  final Function()? onClose;

  const CreateNote({Key? key, required this.createNote, this.initialNote, this.onClose})
      : super(key: key);

  @override
  State<CreateNote> createState() => _CreateNote();
}

class _CreateNote extends State<CreateNote> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();
  bool loading = false;

  @override
  void initState() {
    _controller.text = widget.initialNote ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 32),
                Text(
                  'Create note'.i18n,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headline1!.color,
                  ),
                ),
                InkWell(
                  onTap: loading ? null : () {
                    Navigator.pop(context);
                    widget.onClose?.call();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.close_outlined,
                      size: 24,
                      color: Theme.of(context).textTheme.headline1!.color,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Form(
              autovalidateMode: AutovalidateMode.disabled,
              key: _key,
              child: CustomTextFormField(
                hint: 'Your note',
                maxLines: 4,
                maxLength: 180,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                onEditingComplete: finish,
                enabled: !loading,
                controller: _controller,
              ),
            ),
            SizedBox(height: 20),
            CustomElevatedButton(
              label: 'Save note'.i18n,
              loading: loading,
              onPressed: finish,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> finish() async {
    FocusScope.of(context).unfocus();
    if (!_key.currentState!.validate()) return;
    setState(() {
      loading = true;
    });
    try {
      await widget.createNote(_controller.text);
      Navigator.pop(context);
    } catch (e) {
      showOneButtonDialog(
        context,
        'Oops',
        e.toString(),
        'Close'.i18n,
      );
      setState(() {
        loading = false;
      });
    }
  }
}
