import 'package:attendance_system/core/utils/dimensions_ext.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final role = context.watch<AuthState>().role;

    return AppScaffold(
      hideNavigation: true,
      // header: Header.mainHeader(context),
      content: SafeArea(

        child: Container(
            color: AppColors.backgroundColor,
            alignment: Alignment.center,

            padding: EdgeInsets.symmetric(horizontal: 20),

            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: _AppLogoLoginCard(),
                ),
                Spacer(),

                Text(
                  'Copyright © 2026 CatIsPink Inc. All rights reserved. KU Time Attendance System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.lightTextColor,
                  ),
                ),
              ],

            )
        )
      )
    );
  }
}

class _AppLogoLoginCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, pageConstraints) {
          return Column(
            spacing: 13.r(context),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 🔹 LOGO
              LayoutBuilder(
                builder: (context, constraints) {
                  final logoWidth = (constraints.maxWidth * 0.55).clamp(120.0, 260.0);

                  return Image.asset(
                    'assets/images/app_logo.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                  );
                },
              ),

              /// 🔹 CARD
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                  !Responsive.isMobile(context) ? 350 : double.infinity,
                ),
                child: AspectRatio(
                  aspectRatio: 362 / 244,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final scale = Responsive.scaleFromWidth(
                        currentWidth: constraints.maxWidth,
                      );

                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14 * scale,
                          vertical: 20 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              spacing: 4 * scale,
                              children: [
                                Text(
                                  "เข้าสู่ระบบ",
                                  style: TextStyle(
                                    fontSize: 18 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.greyTextColor,
                                  ),
                                ),
                                Text(
                                  "ใช้บัญชี Google ของคุณเพื่อเข้าใช้งาน",
                                  style: TextStyle(
                                    fontSize: 13 * scale,
                                    color: AppColors.lightTextColor,
                                  ),
                                ),
                              ],
                            ),

                                  /// 🔹 BUTTON
                                  ElevatedButton(
                                    onPressed: () async {
                                      await context.read<AuthState>().loginWithGoogle();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding:
                                      EdgeInsets.all(20 * scale),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      spacing: 12 * scale,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/google_logo.svg',
                                          width: 20 * scale,
                                          height: 20 * scale,
                                        ),
                                        Text(
                                          'Login with Google',
                                          style: TextStyle(
                                            fontSize: 15 * scale,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                            /// 🔹 FOOTNOTE
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10 * scale,
                              ),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 11 * scale,
                                    color: AppColors.greyTextColor,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                      "หากพบปัญหาในการเข้าสู่ระบบ กรุณาติดต่อ",
                                    ),
                                    TextSpan(
                                      text: "นักทรัพยากรบุคคล",
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: "ฝ่ายสำนักงานเลขานุการ",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      );
  }
}
