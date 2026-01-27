import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {

  final Widget content;
  final Header? header;

  const AppScaffold({super.key, required this.content, this.header});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          content,
          ?header
        ],
      )
    );
  }

}