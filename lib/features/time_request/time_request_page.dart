import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeRequestPage extends StatelessWidget {
  const TimeRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AppScaffold(
      header: Header.mainHeader(context),
      content: MaterialApp(),
    );
  }

}