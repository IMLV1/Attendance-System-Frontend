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
    this.TitleEng = '',
    this.IconPath
  });

  @override
  Widget build(BuildContext context){
  final double screenWidth = MediaQuery.of(context).padding.top;

    return Container(
      color: AppColors.barColor,
      padding: EdgeInsets.only(top:screenWidth+10, left: 20, right: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if(IconPath != null)
            Image.asset(
              IconPath!,
              width: 40,
              height: 40,
              color: AppColors.cardColor,
            )
          else
            GestureDetector(
              onTap: () {
                // Navigate back to the previous screen
              },
              child: Icon (
                Icons.arrow_back,
                color: AppColors.cardColor,
                size: 30,
              ),
            )
          ,
          const SizedBox(width: 10),
          if(IconPath != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TitleThai,
                  style: const TextStyle(
                    color: AppColors.cardColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TitleEng,
                  style: const TextStyle(
                    color: AppColors.greyTextColor,
                    fontSize: 15,
                  ),
                ),
              ],
            )
          else
            Expanded(
              child:
                Text(
                  TitleThai,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.cardColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ),
          if(IconPath == null)
            const SizedBox(width: 40) // To balance the back icon on the left
        ],
      ),
    );
  }
}
