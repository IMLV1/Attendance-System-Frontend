import 'package:attendance_system/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'routes.dart';

class App extends StatelessWidget {

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      // แตะที่ว่างแล้วปิดคีย์บอร์ด — ย้ายมาจาก MaterialApp ชั้นนอกใน main.dart
      builder: (context, child) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: child!,
      ),
    );
  }
}