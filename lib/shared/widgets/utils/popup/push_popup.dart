import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/theme/app_theme.dart';
import 'package:attendance_system/shared/widgets/utils/popup/popup_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PushPopup {

  final String title;
  final String buttonLabel;
  final void Function(BuildContext context)? buttonAction;
  final bool backButton;
  final Widget Function(BuildContext context) builder;
  final double maxHeight;
  final double minHeight;
  final FlexFit fit;
  final bool scroll;

  const PushPopup({
    this.title = 'Default Title',
    this.buttonLabel = '',
    this.buttonAction,
    this.backButton = true,
    required this.builder,
    this.maxHeight = double.infinity,
    this.minHeight = 0,
    this.fit = FlexFit.loose,
    this.scroll = true,
  });

  void showPopup(BuildContext context) {

    // 🚩 (2026-08-24) เดิมเรียก showModalBottomSheet เองพร้อมเปลือกทั้งชุด
    // (มุมโค้ง 40, เงา, ขีดจับ, SafeArea, เพดาน 88% ของจอ) ทำให้บน iPad/desktop
    // ได้แผ่นเลื่อนกว้างเต็มจอที่ดูผิดสัดส่วน — ย้ายส่วนนำเสนอไป PopupSurface
    // ซึ่งเลือกให้เองว่าจอไหนควรเป็นแผ่นเลื่อน จอไหนควรเป็นกล่องกลางจอ
    PopupSurface.show(
      context: context,
      maxHeight: maxHeight,
      minHeight: minHeight,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 15,
          children: [
            Column(
              spacing: 1,
              children: [
                Stack(
                  children: [
                    if (backButton)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Transform.translate(
                          offset: const Offset(-5, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              overlayColor: Colors.transparent,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: SvgPicture.asset(
                              'assets/images/back_button.svg',
                              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                            ),
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        title,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: AppTheme.systemFontFamily,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    if (buttonLabel != '')
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            setState(() {
                              if (buttonAction != null) buttonAction!(context);
                            });
                          },
                          child: Text(
                            buttonLabel,
                            style: TextStyle(
                              fontSize: 17,
                              color: AppColors.primaryColor,
                              fontFamily: AppTheme.systemFontFamily,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const Divider(height: 0),
              ],
            ),
            Flexible(
              // 🚩 (2026-08-24) call site ส่ง FlexFit.tight มา 69 จุด ซึ่งบังคับให้
              // เนื้อหายืดเต็มเพดานเสมอ — บนแผ่นเลื่อนที่ยึดขอบล่างอยู่แล้วดูปกติ
              // แต่พอเป็นกล่องกลางจอจะได้กล่องสูงโย่งที่ว่างเป็นครึ่ง
              // โหมดกล่องจึงบังคับ loose ให้กล่องหดตามเนื้อหาแทน
              fit: PopupSurface.presentationOf(context) == PopupPresentation.dialog
                  ? FlexFit.loose
                  : fit,
              child: scroll
                  ? SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: builder(context),
                    )
                  : builder(context),
            ),
          ],
        ),
      ),
    );
  }
}
