import 'package:attendance_system/core/utils/responsive.dart';
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

    return LayoutBuilder(
        builder: (context, child) {
          final width = MediaQuery
              .of(context)
              .size
              .width;

          double scaleFactor;

          if (Responsive.isMobile(context)) {
            scaleFactor = 1.0; // mobile
          } else if (Responsive.isTablet(context)) {
            scaleFactor = 1.2; // tablet
          } else {
            scaleFactor = 1.4; // desktop
          }

          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scaleFactor),
            ),
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: header,
                body: Align(
                  alignment: Alignment.topCenter,
                  child: content


                  // LayoutBuilder(
                  //   builder: (context, constraints) {
                  //     double width = constraints.maxWidth;
                  //
                  //     return ConstrainedBox(
                  //         constraints: BoxConstraints(
                  //           maxWidth: width > 1200 ? 1100 : width,
                  //         ),
                  //         child: content,
                  //     );
                  //   },
                  // ),

                )
            )
          );
        }
    );
  }
}