import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staffmonitor/model/project.dart';

import '../../../../utils/functions.dart';
import '../../../../widget/custom_elevated_button.dart';
import '../../../../widget/custom_text_form_field.dart';
import '../my_start_stop.i18n.dart';

class CreateProjectWidget extends StatefulWidget {
  const CreateProjectWidget({Key? key, required this.createProject}) : super(key: key);

  final Future<Project> Function(String, Color) createProject;

  @override
  State<CreateProjectWidget> createState() => _CreateProjectWidgetState();
}

class _CreateProjectWidgetState extends State<CreateProjectWidget> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();
  late Color selectedColor;
  bool loading = false;

  List<Color> sampleColors = [
    Colors.grey,
    Colors.green,
    Colors.cyan,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = sampleColors[Random().nextInt(sampleColors.length)];
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
                SizedBox(width: 24),
                Text(
                  'Create new project'.i18n,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headline1!.color,
                  ),
                ),
                GestureDetector(
                  onTap: loading ? null : () => Navigator.pop(context),
                  child: Icon(
                    Icons.close_outlined,
                    size: 24,
                    color: Theme.of(context).textTheme.headline1!.color,
                  ),
                )
              ],
            ),
            Text(
              'Enter Project name and choose a color to create a project'.i18n,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.headline2!.color,
              ),
            ),
            SizedBox(height: 20),
            Form(
              autovalidateMode: AutovalidateMode.disabled,
              key: _key,
              child: CustomTextFormField(
                  controller: _controller,
                  hint: 'Your project name'.i18n,
                  enabled: !loading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required'.i18n;
                    }
                    return null;
                  }),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${'Pick a color'.i18n}:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.headline2!.color,
                  ),
                ),
                SizedBox(width: 15),
                InkWell(
                  onTap: loading
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          pickColor(context, selectedColor);
                        },
                  child: Container(
                    height: 20,
                    width: 20,
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: selectedColor,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: selectedColor,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            CustomElevatedButton(
              label: 'Create project'.i18n,
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
    widget.createProject(_controller.text, selectedColor).then((value) {
      Navigator.pop(context, value);
    }, onError: (e, stack) {
      setState(() {
        loading = false;
      });
      showOneButtonDialog(
        context,
        'Oops'.i18n,
        e.toString(),
        'Close'.i18n,
      );
    });
  }

  void pickColor(BuildContext context, Color pickerColor) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Pick your color'.i18n,
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.headline1!.color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MaterialPicker(
                pickerColor: Colors.grey,
                enableLabel: false,
                portraitOnly: true,
                onColorChanged: (color) {
                  pickerColor = color;
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedColor = pickerColor;
                  });
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Text(
                  'Select'.i18n,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.headline1!.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
