import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hideNavigation: true,
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              /// 🔹 MAIN CONTENT (centered vertically)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: Responsive.isDesktop(context) ? 450 : 400
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// 🔹 LOGO
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 36),

                          /// 🔹 LOGIN CARD
                          const _LoginCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// 🔹 COPYRIGHT (pinned at bottom)
              const _CopyrightText(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 🃏 LOGIN CARD
// ─────────────────────────────────────────────

class _LoginCard extends StatefulWidget {
  const _LoginCard();

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// TITLE
          Text(
            "เข้าสู่ระบบ",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.greyTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "ใช้บัญชี Google ของคุณเพื่อเข้าใช้งาน",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.lightTextColor,
            ),
          ),
          const SizedBox(height: 28),

          /// 🔹 GOOGLE BUTTON
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () async {
                String res =
                    await context.read<AuthState>().loginWithGoogle();
                setState(() {
                  error = res;
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  SvgPicture.asset(
                    'assets/images/google_logo.svg',
                    width: 20,
                    height: 20,
                  ),
                  Text(
                    'Login with Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ERROR MESSAGE
          if (error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 24),

          /// 🔹 FOOTNOTE
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 11,
                color: AppColors.lightTextColor,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text: "หากพบปัญหาในการเข้าสู่ระบบ กรุณาติดต่อ",
                ),
                TextSpan(
                  text: "นักทรัพยากรบุคคล",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(
                  text: "\nฝ่ายสำนักงานเลขานุการ",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 📝 COPYRIGHT TEXT
// ─────────────────────────────────────────────

class _CopyrightText extends StatelessWidget {
  const _CopyrightText();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Text(
        'Copyright © 2026 CatIsPink Inc. All rights reserved.\nKU Time Attendance System',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.lightTextColor,
        ),
      ),
    );
  }
}
