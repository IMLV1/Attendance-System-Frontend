import 'package:attendance_system/core/utils/navigation_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sealed_countries/sealed_countries.dart';

import 'app/app.dart';
import 'core/auth/auth_state.dart';
import 'service_locator.dart';
import 'services/notification/notification_provider.dart';

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

  usePathUrlStrategy(); // see https://pub.dev/packages/url_strategy
  GoRouter.optionURLReflectsImperativeAPIs = true;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthState>.value(
          value: getIt<AuthState>(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..fetchNotifications(),
        ),
        ChangeNotifierProvider(
          create: (_) => NavigationGuard(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: child!,
          );
        },
        home: App(),
      )
    ),
  );
}
