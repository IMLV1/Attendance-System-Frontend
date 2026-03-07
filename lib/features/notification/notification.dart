import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:flutter/cupertino.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/head_bar/header.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() {
    return NotificationState();
  }
}

class NotificationState extends State<NotificationPage> {

  List<dynamic> list = [];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(context,
          title: 'การแจ้งเตือน'
      ),
      content: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            color: AppColors.backgroundColor,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 13,
                children: [
                  SeparatorCard(
                    children: [
                      ...list.map((e) {
                        return AppButton(
                          icon: '',
                          title: ''
                        );
                      })
                    ],
                  )
                ]
              )
            )
          )
        )
      )
    );
  }
}