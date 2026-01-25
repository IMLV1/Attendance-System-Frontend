import 'package:attendance_system/core/utils/dimensions_ext.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_state.dart';

class LoginPage extends StatelessWidget {

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
          alignment: AlignmentGeometry.center,
          padding: EdgeInsets.symmetric(horizontal: 20.r(context)),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 13.r(context),
            children: [
              ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: Responsive.isDesktop(context) ? 420 : double.infinity,
                  ),

                  child: AspectRatio(
                      aspectRatio: 362 / 244,
                      child: LayoutBuilder(
                          builder: (context, constraints) {
                            final scale = Responsive.scaleFromWidth(
                              currentWidth: constraints.maxWidth,
                            );

                            return Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(22)
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 20 * scale),
                                width: double.infinity,

                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      spacing: 4 * scale,
                                      children: [
                                        Text("เข้าสู่ระบบ",
                                          style: TextStyle(
                                              fontSize: 18 * scale,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.greyTextColor
                                          ),
                                        ),
                                        Text("ใช้บัญชี Google ของคุณเพื่อเข้าใช้งาน",
                                          style: TextStyle(
                                              fontSize: 13 * scale,
                                              fontWeight: FontWeight.normal,
                                              color: AppColors.lightTextColor
                                          ),
                                        )
                                      ],
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          context.read<AuthState>().loginWithGoogle();
                                        },
                                        style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.all(20 * scale)
                                        ),
                                        child: Row(
                                          spacing: 12 * scale,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/images/google_logo.svg',
                                              width: 20 * scale,
                                              height: 20 * scale,
                                            ),
                                            Text(
                                              'Login with Google',
                                              style: TextStyle(
                                                  fontSize: 15 * scale
                                              ),
                                            )
                                          ],
                                        )
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                                        child: RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                                text: "หากพบปัญหาในการเข้าสู่ระบบ กรุณาติดต่อ",
                                                style: TextStyle(
                                                  fontSize: 11 * scale,
                                                  fontWeight: FontWeight.normal,
                                                  color: AppColors.greyTextColor,
                                                ),
                                                children: [
                                                  TextSpan(
                                                      text: "นักทรัพยากรบุคคล",
                                                      style: TextStyle(
                                                        fontSize: 11 * scale,
                                                        fontWeight: FontWeight.normal,
                                                        color: AppColors.primaryColor,
                                                      )
                                                  ),
                                                  TextSpan(
                                                      text: "ฝ่ายสำนักงานเลขานุการ",
                                                      style: TextStyle(
                                                        fontSize: 11 * scale,
                                                        fontWeight: FontWeight.normal,
                                                        color: AppColors.greyTextColor,
                                                      )
                                                  )
                                                ]
                                            )
                                        )
                                    )
                                  ],
                                )
                            );
                          }
                      )
                  )
              )
            ],
          )
      ),
    );
  }
}