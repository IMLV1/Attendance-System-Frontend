import 'package:attendance_system/features/settings/approval/attendance/attendance_approval.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/head_bar/header.dart';
import 'leave/leave_approval.dart';

class Approval extends StatefulWidget {
  final int initialTab;
  const Approval({super.key, this.initialTab = 0});

  @override
  State<Approval> createState() { return ApprovalState(); }
}

class ApprovalState extends State<Approval> {

  late int select;

  @override
  void initState() {
    super.initState();
    select = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(
        context,
        title: 'อนุมัติคำขอ',
        // 🚩 (2026-08-24) แถบแท็บอยู่ใน AppBar ไม่ใช่ในเนื้อหา — ไม่งั้นถูก
        // `AppScaffold` บีบให้กว้าง 1100 ทั้งที่หัวเต็มจอ เกิดรอยขั้นบันได
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child:
            Container(
              color: AppColors.barColor, // Match header's maroon color
              height: 54, // Increased height slightly to accommodate shadow
              padding: const EdgeInsets.only(left: 15, right: 15, top: 12),
              // แถบพื้นหลังเต็มจอ แต่ตัวแท็บจำกัดกว้างเท่าเนื้อหาข้างล่าง
              // ไม่งั้นแท็บกางยาวจนไม่ตรงกับการ์ดที่อยู่ใต้มัน
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: Responsive.contentMaxWidth),
                  child: Row(
                children: [
                  // Attendance Tab
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => select = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: select == 0 ? AppColors.backgroundColor : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          boxShadow: select == 0 ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, -2),
                            ),
                          ] : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'เวลาเข้า-ออก',
                          style: TextStyle(
                            color: select == 0 ? AppColors.barColor : Colors.white70,
                            fontWeight: select == 0 ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
              
                  const SizedBox(width: 4),
              
                  // Leave Tab
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => select = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: select == 1 ? AppColors.backgroundColor : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          boxShadow: select == 1 ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, -2),
                            ),
                          ] : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'การลางาน',
                          style: TextStyle(
                            color: select == 1 ? AppColors.barColor : Colors.white70,
                            fontWeight: select == 1 ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
              ),
            ),
        ),
      ),
      content: Column(
        children: [
          // Small Bridge Layer to connect active tab to content
          Container(
            height: 1,
            color: AppColors.backgroundColor,
          ),
          Expanded(
            child: SafeArea(
              child: Container(
                color: AppColors.backgroundColor,
                // 🚩 (2026-08-22) เดิมเป็น SingleChildScrollView ครอบ Column ทั้งก้อน
                // -> ทุกแถวของลิสต์ถูก build พร้อมกันตอนเปิดหน้า (กระตุก)
                // เปลี่ยนเป็น CustomScrollView แล้วให้ลูกทั้งสองคืน sliver มาแทน
                // ⚠️ ห้ามเอา SingleChildScrollView กลับมาครอบ ไม่งั้น sliver ข้างในจะ
                // ถูก shrink-wrap แล้วกลับไป build ครบทุกแถวเหมือนเดิม
                child: CustomScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 20, bottom: 20
                      ),
                      sliver: select == 0
                          ? AttendanceApproval()
                          : LeaveApproval(),
                    ),
                  ],
                )
              )
            ),
          ),
        ],
      ),
    );
  }
}