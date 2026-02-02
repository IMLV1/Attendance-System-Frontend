import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/auth/auth_state.dart';
import 'service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Load env
  await dotenv.load(fileName: '.env');

  /// Setup DI
  await setupServiceLocator();

  /// Init auth state (check token + /auth/me)
  await getIt<AuthState>().init();

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
