import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/bloc/main/settings/settings_cubit.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/company_profile.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';

import 'settings.i18n.dart';
import 'settings_form.dart';

class SettingsPage extends BasePageWidget {
  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    final theme = Theme.of(context);
    return BlocProvider<SettingsCubit>(
      create: (context) => SettingsCubit(
        BlocProvider.of<AuthCubit>(context),
        injector.profileRepository,
        injector.usersRepository,
        injector.profileCompanyRepository,
      ),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 50,
          titleSpacing: 0,
          title: Text(
            'Settings'.i18n,
            style: theme.textTheme.headline4,
          ),
          actions: [Center(child: SettingsSaveButton())],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: profile == null
                  ? Container()
                  : profile.isEmployee || profile.isSupervisor
                      ? SettingsForm(profile, null)
                      : FutureBuilder<CompanyProfile?>(
                          future: injector.profileCompanyRepository.getProfileCompany(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return SettingsForm(
                                  profile, snapshot.data ?? CompanyProfile.create());
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
        ),
      ),
    );
  }
}