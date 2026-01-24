import 'package:attendance_system/service_locator.dart';
import 'package:flutter/cupertino.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'core/auth/auth_state.dart';
import 'core/network/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiConfig.init();
  await setupServiceLocator();
  await setupAppDI();

  await getIt<AuthState>().init();

  runApp(const App());
}