import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// 🚩 (2026-08-22) เวอร์ชัน lazy ของ [SeparatorCard]
///
/// [SeparatorCard] ต้องรับ children ครบทุกตัวตั้งแต่แรก เพราะต้องรู้ว่าตัวไหน
/// หัว/ท้าย เพื่อวาดขอบมนกับแทรกเส้นคั่น -> ใช้กับลิสต์ยาวๆ ไม่ได้ เพราะ Flutter
/// จะ build ทุกแถวพร้อมกันแม้จะยังไม่ได้เลื่อนไปเห็น (หน้าอนุมัติ/ประวัติกระตุก)
///
/// ตัวนี้คำนวณหัว/ท้ายจาก index แทน เลยใช้กับ [SliverList.builder] ได้
/// หน้าตาที่ออกมาเหมือน [SeparatorCard] ทุกอย่าง
///
/// ⚠️ ต้องวางไว้ใน [CustomScrollView] เท่านั้น (เป็น sliver ไม่ใช่ widget ปกติ)
/// และห้ามมี [SingleChildScrollView] ครอบอยู่ ไม่งั้น sliver จะถูก shrink-wrap
/// แล้ว build ครบทุกแถวเหมือนเดิม (เท่ากับไม่ได้แก้อะไร)
class SliverSeparatorList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry separatorPadding;
  final double radius;

  const SliverSeparatorList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorPadding = EdgeInsets.zero,
    this.radius = 25,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final isFirst = index == 0;
        final isLast = index == itemCount - 1;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(isFirst ? radius : 0),
              bottom: Radius.circular(isLast ? radius : 0),
            ),
          ),
          child: Column(
            children: [
              itemBuilder(context, index),
              if (!isLast)
                Padding(
                  padding: separatorPadding,
                  child: const Divider(height: 0),
                ),
            ],
          ),
        );
      },
    );
  }
}
