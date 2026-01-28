import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SubHeader extends Header {

  const SubHeader({
    super.key,
    super.title,
  });

  @override
  Widget build(BuildContext context) {

    int permissionLevel = 3;

    return AppBar(
        backgroundColor: AppColors.barColor,
        elevation: 0,

        leadingWidth: 56,

        toolbarHeight: 40,

        centerTitle: true,

        automaticallyImplyLeading: false,

        leading: Navigator.of(context).canPop() ? IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: SvgPicture.asset(
            'assets/images/back_button.svg',
            width: 24,
            height: 24,
          ),
        ) : null,

        title: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.titleColor,
          ),
        ),
      );
  }
}
