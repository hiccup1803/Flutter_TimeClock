import 'package:flutter/material.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/company_profile.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/settings/settings_form.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget(this.profile);

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: profile.isEmployee || profile.isSupervisor
              ? SettingsForm(profile, null)
              : FutureBuilder<CompanyProfile?>(
                  future: injector.profileCompanyRepository.getProfileCompany(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SettingsForm(profile, snapshot.data ?? CompanyProfile.create());
                    }
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
