import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/auth/auth_state.dart';
import 'service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env.example');
  await setupServiceLocator();

  final authState = getIt<AuthState>();
  await authState.init();

  runApp(
    ChangeNotifierProvider<AuthState>.value(
      value: authState,
      child: const App(),
    ),
  );
}
