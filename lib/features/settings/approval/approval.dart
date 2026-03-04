import 'package:attendance_system/features/settings/approval/attendance/attendance_approval.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/head_bar/header.dart';
import 'leave/leave_approval.dart';

class Approval extends StatefulWidget {
  const Approval({super.key});

  @override
  State<Approval> createState() { return ApprovalState(); }
}

class ApprovalState extends State<Approval> {

  int select = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.mainHeader(
        context,
        title: 'อนุมัติคำขอ',
        subTitle: 'Approval',
      ),
      content: Column(
        children: [
          Container(
            padding: EdgeInsetsGeometry.only(left: 15, right: 15),
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.barColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        select = 0;
                      });
                    },
                    child: Container(
                      color: select == 0 ? Colors.pink : null,
                      alignment: Alignment.center,
                      child: Text(
                        'เวลาเข้า-ออก',
                        style: TextStyle(
                          color: select == 0
                              ? Colors.white
                              : Color(0xFFCFCFCF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 15),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        select = 1;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      color: select == 1 ? Colors.pink : null,
                      child: Text(
                        'การลางาน',
                        style: TextStyle(
                          color: select == 1
                              ? Colors.white
                              : Color(0xFFCFCFCF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: select == 0
                ? AttendanceApproval()
                : LeaveApproval(),
          ),
        ],
      ),
    );
  }
}