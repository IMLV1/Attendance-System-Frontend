import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String titleThai;
  final String titleEng;
  final iconHamburger = Icons.menu;
  final iconNotification = Icons.notifications_none;
  final String? iconPath ;
  const Header({
    super.key,
    required this.titleThai,
    this.titleEng = '',
    this.iconPath
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context){

    return AppBar(
      backgroundColor: AppColors.barColor,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          if (iconPath != null)
            Image.asset(
              iconPath!,
              width: 40,
              height: 40,
              color: AppColors.cardColor,
            )
          else
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: AppColors.cardColor,
              onPressed: () => Navigator.pop(context),
            ),

          const SizedBox(width: 10),

          if (iconPath != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titleThai,
                    style: const TextStyle(
                        color: AppColors.cardColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                if (titleEng.isNotEmpty)
                  Text(titleEng,
                      style: const TextStyle(
                          color: AppColors.greyTextColor, fontSize: 14)),
              ],
            )
          else
            Expanded(
              child: Text(
                titleThai,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.cardColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
