import 'package:attendance_system/features/settings/approval/attendance/attendance_approval.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
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
      ),
      content: Column(
        children: [
          // Folder Style Tab Switcher (Reference: User Image)
          Container(
            color: AppColors.barColor, // Match header's maroon color
            height: 54, // Increased height slightly to accommodate shadow
            padding: const EdgeInsets.only(left: 15, right: 15, top: 12),
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
          
          // Small Bridge Layer to connect active tab to content
          Container(
            height: 1,
            color: AppColors.backgroundColor,
          ),
          Expanded(
            child: SafeArea(
              child: Container(
                color: AppColors.backgroundColor,
                alignment: Alignment.topCenter,
                child: Padding(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 20
                    ),
                    child: Column(
                        children: [
                          Expanded(
                              child: SingleChildScrollView(
                                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: select == 0
                                      ? AttendanceApproval()
                                      : LeaveApproval(),
                              )
                          )
                        ]
                    )
                )
              )
            ),
          ),
        ],
      ),
    );
  }
}