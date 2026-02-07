import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  /// Load env
  await dotenv.load(fileName: '.env');

  /// Setup DI
  await setupServiceLocator();

  /// Init auth state (check token + /auth/me)
  await getIt<AuthState>().init();

  prepareNationalities();

  runApp(
    ChangeNotifierProvider<AuthState>.value(
      value: getIt<AuthState>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: App(),
      )
    ),
  );
}
