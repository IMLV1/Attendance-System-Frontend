import 'dart:math' as math;

import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// วิธีแสดง popup
enum PopupPresentation {
  /// แผ่นเลื่อนขึ้นจากขอบล่าง — มือถือเท่านั้น (ทุกแนวจอ)
  sheet,

  /// กล่องกลางจอ — แท็บเล็ตขึ้นไป ทั้งแนวตั้งและแนวนอน
  dialog,
}

/// เปลือกกลางของ popup ทุกชนิดในแอป
///
/// 🚩 (2026-08-24) เดิม popup ทุกตัวเป็น `showModalBottomSheet` ตายตัว
/// (`PushPopup`, `ServicePopup`, `DynamicPushPopup` — สามตัวนี้คือทั้งหมดที่
/// สร้าง sheet จริง ส่วนที่เหลืออีกร้อยกว่าจุดเรียกผ่านสามตัวนี้)
///
/// ปัญหาบนจอใหญ่: แผ่นเลื่อนขึ้นมาจากขอบล่างกว้างเต็มจอ 1376px สูงแค่ 700px
/// ที่ hardcode ไว้ กลายเป็นแถบแบนยาวผิดสัดส่วน และปุ่มไปกองอยู่ขอบล่างสุด
/// ไกลจากสายตา ตัวเลข maxHeight ที่ call site ใส่ไว้ (700 / 750 / 400 / 650)
/// ถูกตั้งมาจากสายตาบนมือถือทั้งหมด
///
/// ตรงนี้จึงแยก "การนำเสนอ" ออกจาก "เนื้อหา": มือถือยังเป็นแผ่นเลื่อนเหมือนเดิม
/// แท็บเล็ตขึ้นไปกลายเป็นกล่องกลางจอที่กว้างพอดีอ่าน ส่วน maxHeight ที่ส่งเข้ามา
/// ถือเป็น "เพดาน" ไม่ใช่ความสูงตายตัว — เนื้อหาสั้นก็หดตาม
class PopupSurface {
  /// ความกว้างกล่องกลางจอ — กว้างกว่านี้บรรทัดข้อความจะยาวจนอ่านยาก
  static const double dialogMaxWidth = 560;

  /// สัดส่วนความสูงสูงสุดเทียบกับจอ
  static const double _sheetMaxHeightFactor = 0.88;
  static const double _dialogMaxHeightFactor = 0.82;

  /// 🚩 (2026-08-24, รอบสอง) เดิมผูกกับ `showSidebar` ซึ่งเป็นจริงเฉพาะโหมด
  /// `expanded` -> iPad **แนวตั้ง** (โหมด `medium`) จึงยังได้แผ่นเลื่อนกว้างเต็มจอ
  /// 834px ซึ่งเป็นอาการเดียวกับที่ย้ายมา PopupSurface เพื่อแก้ตั้งแต่แรก
  ///
  /// เกณฑ์ที่ถูกคือ "จอเล็กแค่ไหน" ไม่ใช่ "มี sidebar รึเปล่า" — แผ่นเลื่อนเหมาะ
  /// กับมือถือเพราะนิ้วโป้งเอื้อมถึงขอบล่างพอดี พอจอกว้างเกินนั้นกล่องกลางจอ
  /// อ่านง่ายกว่าเสมอ ไม่เกี่ยวกับแนวจอ
  static PopupPresentation presentationOf(BuildContext context) =>
      Responsive.isCompact(context)
          ? PopupPresentation.sheet
          : PopupPresentation.dialog;

  /// `builder` ต้องคืน widget ที่ยอมหดได้ (เช่น `Column(mainAxisSize: min)`)
  /// เพราะจะถูกวางไว้ใน `Flexible` ให้อีกที
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    double maxHeight = double.infinity,
    double minHeight = 0,
    bool showHandle = true,
    bool dismissible = true,
  }) {
    final theme = Theme.of(context);

    if (presentationOf(context) == PopupPresentation.dialog) {
      return showDialog<T>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: dismissible,
        barrierColor: Colors.black.withValues(alpha: 0.25),
        builder: (context) {
          final screenHeight = MediaQuery.sizeOf(context).height;
          return Theme(
            data: theme,
            child: Dialog(
              backgroundColor: AppColors.backgroundColor,
              clipBehavior: Clip.antiAlias,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: minHeight,
                  maxWidth: dialogMaxWidth,
                  maxHeight: math.min(maxHeight, screenHeight * _dialogMaxHeightFactor),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  // กล่องกลางจอไม่มีที่ให้ลากปิด จึงไม่ต้องมีขีดจับ
                  child: builder(context),
                ),
              ),
            ),
          );
        },
      );
    }

    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 200),
    );

    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isDismissible: dismissible,
      barrierColor: Colors.black.withValues(alpha: 0.15),
      transitionAnimationController: controller,
      builder: (context) {
        final screenHeight = MediaQuery.sizeOf(context).height;
        return Theme(
          data: theme,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              borderRadius: BorderRadius.circular(40),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: minHeight,
                      maxHeight: math.min(maxHeight, screenHeight * _sheetMaxHeightFactor),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showHandle) ...[
                          Container(
                            color: const Color(0xFFA6A6A6),
                            width: 70,
                            height: 3,
                          ),
                          const SizedBox(height: 15),
                        ],
                        Flexible(child: builder(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
