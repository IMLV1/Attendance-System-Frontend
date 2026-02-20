import 'package:attendance_system/core/data/provider/profile_provider.dart';
import 'package:attendance_system/core/data/repositories/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sealed_countries/sealed_countries.dart';

import 'app/app.dart';
import 'core/auth/auth_state.dart';
import 'service_locator.dart';

List<String> cachedThaiNationalities = [];

void prepareNationalities() {
  // Doing this while the app is loading or idle
  // means the work is already done when the popup opens.
  cachedThaiNationalities = WorldCountry.list.map((country) {
    return country.translations.firstWhere(
          (t) => t.language == const LangTha(),
      orElse: () => country.name,
    ).common;
  }).toList()..sort();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th_TH', null);
  await dotenv.load(fileName: '.env');
  await setupServiceLocator();
  await getIt<AuthState>().init();
  prepareNationalities();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(

    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => getIt<AuthState>(),
        ),

        ChangeNotifierProxyProvider<AuthState, ProfileProvider>(
          create: (_) => ProfileProvider(ProfileRepository()),
          update: (_, auth, profile) {
            profile ??= ProfileProvider(ProfileRepository());

            if (auth.status == AuthStatus.authenticated) {
              profile.load(forceRefresh: true);
            } else {
              profile.clear();
            }

            return profile;
          },
        ),
      ],
      child: App()
    ),
  );
}
