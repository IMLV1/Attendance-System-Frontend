import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {

  final Widget content;
  final AppBar? header;
  final bool hideNavigation;

  const AppScaffold({
    super.key,
    this.hideNavigation = false,
    required this.content,
    this.header
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: header,
      body: content,
    );
  }
}