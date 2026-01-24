import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class Header extends StatelessWidget {
  final String TitleThai;
  final String TitleEng;
  final IconHamburger = Icons.menu;
  final IconNotification = Icons.notifications_none;
  final String? IconPath ;
  const Header({
    super.key,
    required this.TitleThai,
    required this.TitleEng,
    this.IconPath
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.barColor,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(IconPath != null)
            Image.asset(
              IconPath!,
              width: 40,
              height: 40,
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
            children: [
              Text(
                TitleThai,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                TitleEng,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
