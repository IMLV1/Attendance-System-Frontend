import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/services/notification/notification_model.dart';
import 'package:attendance_system/services/notification/notification_provider.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications if needed (already fetched in main.dart but we can refresh)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      maxWidth: Responsive.widthFor(ContentShape.list),
      hideNavigation: true, // Hide bottom navigation when viewing notifications
      header: Header.subHeader(
        context,
        title: 'การแจ้งเตือน',
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(RouteNames.checkin);
          }
        },
      ),
      // 🚩 (2026-09-03) เดิมห่อด้วย PopScope ที่สั่ง markAllAsRead() ตอนกดย้อนกลับ
      // — แค่ "เปิดหน้าแล้วออก" ก็ล้าง unread ทั้งกล่อง ทั้งที่ผู้ใช้ยังไม่ได้อ่าน
      // อะไรเลย ตอนนี้มาร์กเฉพาะใบที่กดจริง (ดู _buildNotificationItem)
      content: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.notifications.isEmpty) {
              return const Center(
                child: Text(
                  'ไม่มีการแจ้งเตือน',
                  style: TextStyle(
                    color: AppColors.subTitleColor,
                    fontSize: 16,
                  ),
                ),
              );
            }

            final unread = provider.notifications.where((n) => !n.isRead).toList();
            final read = provider.notifications.where((n) => n.isRead).toList();

            // 🚩 (2026-08-22) CustomScrollView + SliverList.builder — เดิมเป็น Column
            // ใน SingleChildScrollView สร้าง widget ของแจ้งเตือนทุกอันพร้อมกัน
            // (แจ้งเตือนสะสมได้เรื่อยๆ ไม่มีเพดาน) ตอนนี้สร้างเฉพาะที่อยู่ในจอ
            //
            // หมายเหตุ: SeparatorCard วาดเส้นคั่น+มุมโค้งให้ทั้งกล่อง ซึ่งต้องรู้จำนวน
            // ลูกทั้งหมด เลยใช้ไม่ได้กับ builder — จัดเส้นคั่น/มุมโค้งเองรายตัวแทน
            Widget buildGroup(List<NotificationModel> list, int index) {
              final isFirst = index == 0;
              final isLast = index == list.length - 1;
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isFirst ? 25 : 0),
                    bottom: Radius.circular(isLast ? 25 : 0),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildNotificationItem(context, list[index], provider),
                    if (!isLast) const Divider(height: 0),
                  ],
                ),
              );
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverPadding(padding: EdgeInsets.only(top: 20)),

                if (unread.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 16, bottom: 8),
                      child: Text(
                        'ยังไม่อ่าน',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.builder(
                      itemCount: unread.length,
                      itemBuilder: (context, i) => buildGroup(unread, i),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],

                if (read.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 16, bottom: 8),
                      child: Text(
                        'กล่องข้อความ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.subTitleColor,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.builder(
                      itemCount: read.length,
                      itemBuilder: (context, i) => buildGroup(read, i),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          },
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, NotificationModel notification, NotificationProvider provider) {
    
    // Determine the icon and background color based on Type + Status
    String iconName = 'notification.svg'; // Default
    Color iconColor = AppColors.primaryColor;
    Color iconBgColor = const Color(0xFFF3F3F3);

    if (notification.type == 'LEAVE_REQUEST' || notification.type == 'APPROVER_LEAVE') {
      if (notification.status == 'APPROVED') {
        iconName = 'leave.svg';
        iconColor = Colors.green;
      } else if (notification.status == 'REJECTED') {
        iconName = 'leave.svg';
        iconColor = Colors.red;
      } else {
        iconName = 'leave.svg';
        iconColor = const Color(0xFFFFAD00);
      }
    } else if (notification.type == 'ATTENDANCE_REQUEST' || notification.type == 'APPROVER_ATTENDANCE') {
       if (notification.status == 'APPROVED') {
        iconName = 'clock_attendance.svg';
        iconColor = Colors.green;
      } else if (notification.status == 'REJECTED') {
        iconName = 'clock_attendance.svg';
        iconColor = Colors.red;
      } else {
        iconName = 'clock_attendance.svg';
        iconColor = const Color(0xFFFFAD00);
      }
    }


    final isApproverNotif =
        notification.type == 'APPROVER_LEAVE' || notification.type == 'APPROVER_ATTENDANCE';
    final isLeave =
        notification.type == 'LEAVE_REQUEST' || notification.type == 'APPROVER_LEAVE';

    return Container(
      color: Colors.white,
      child: AppButton(
        // 🚩 (2026-09-03) เดิม arrow โชว์เฉพาะแจ้งเตือนที่หัวหน้าต้องไปกดอนุมัติ
        // ส่วนแจ้งเตือน "คำขอของคุณถูกอนุมัติ/ปฏิเสธ" แตะแล้วไม่ไปไหนเลย
        // ตอนนี้พาไปหน้ารายการของประเภทนั้นให้ทุกแบบ
        arrow: true,
        icon: iconName,
        iconColor: iconColor,
        bg: iconBgColor,
        iconBadge: switch (notification.status) {
          'APPROVED' => const Icon(Icons.check_circle, color: Colors.green, size: 15),
          'REJECTED' => const Icon(Icons.cancel, color: Colors.red, size: 15),
          _ => null,
        },
        title: notification.title,
        subTitle: notification.message,
        notation: 'หมายเลขคำขอ: ${notification.requestNumber}',
        timeStamp: _formatDate(notification.createdAt),
        weightTitle: notification.isRead ? FontWeight.normal : FontWeight.bold,
        onPressed: () {
          provider.markAsRead(notification.id);

          if (isApproverNotif) {
            // ลูกน้องส่งคำขอมา -> ไปหน้าอนุมัติ แท็บของประเภทนั้น
            context.pushNamed(
              RouteNames.approval,
              queryParameters: {'tab': isLeave ? '1' : '0'},
            );
          } else {
            // คำขอของตัวเอง -> ไปหน้ารายการคำขอของประเภทนั้น
            context.pushNamed(
              isLeave ? RouteNames.leaveRequest : RouteNames.attendanceRequest,
            );
          }
        },
      ),
    );
  }

  // 🚩 (2026-09-03) เดิมคืน "กันยายน 3" — เดือนนำหน้าวัน ไม่มีปี ไม่มีเวลา
  // แจ้งเตือนสะสมข้ามปีแล้วแยกไม่ออกว่าอันไหนปีไหน ใช้ตัวกลางร่วมกับหน้าอื่น
  String _formatDate(DateTime date) => Utils.formatDateTimeFull(date);
}
