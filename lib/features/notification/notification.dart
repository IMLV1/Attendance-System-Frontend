import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/services/notification/notification_model.dart';
import 'package:attendance_system/services/notification/notification_provider.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
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
      content: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
             context.read<NotificationProvider>().markAllAsRead();
          }
        },
        child: Consumer<NotificationProvider>(
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

    bool isActionable = (notification.type == 'APPROVER_LEAVE' || notification.type == 'APPROVER_ATTENDANCE');

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          AppButton(
            arrow: isActionable,
            icon: iconName,
            iconColor: iconColor,
            bg: iconBgColor,
            title: notification.title,
            subTitle: notification.message,
            notation: 'หมายเลขคำขอ: ${notification.requestNumber}',
            timeStamp: _formatDate(notification.createdAt),
            weightTitle: notification.isRead ? FontWeight.normal : FontWeight.bold,
            onPressed: () {
              provider.markAsRead(notification.id);
              
              // Navigate to approval page ONLY if the notification requires approval action
              // 'APPROVER_LEAVE' or 'APPROVER_ATTENDANCE' means a subordinate sent a request
              if (notification.type == 'APPROVER_LEAVE' || notification.type == 'APPROVER_ATTENDANCE') {
                int tabIndex = (notification.type == 'APPROVER_LEAVE') ? 1 : 0;
                context.pushNamed(
                  RouteNames.approval,
                  queryParameters: {'tab': tabIndex.toString()},
                );
              }
            },
          ),
          
          // Status Badges
          if (notification.status == 'APPROVED')
            Positioned(
              left: 32,
              top: 47,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 15),
              ),
            ),
          if (notification.status == 'REJECTED')
            Positioned(
              left: 32,
              top: 47,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel, color: Colors.red, size: 15),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Custom Thai Month formatting
    const thaiMonths = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    String month = thaiMonths[date.month - 1];
    return '$month ${date.day}';
  }
}
