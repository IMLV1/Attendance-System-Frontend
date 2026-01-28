import 'package:flutter/material.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavigation extends StatefulWidget {


  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();

}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.cardColor,
      elevation: 8,
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.subTitleColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navigationItem('time-request', 'approve_time.svg', 'ขออนุมัติเวลา'),
            _navigationItem('leave', 'leave.svg', 'ลางาน'),
            _centerItem('checkin', 'check-in.svg', 'เข้า-ออกงาน'),
            _navigationItem('statistic', 'stat.svg', 'สถิติ'),
            _profileItem('profile', '', 'โปรไฟล์'),
          ],
        ),
      ),
    );
  }

  Widget _navigationItem(String pageName, String iconPath, String label) {
    return Expanded(
      child: InkWell(
        onTap: () {},

        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height:30,
              width: 30,
              child: SvgPicture.asset(
                'assets/images/$iconPath',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _centerItem(String pageName, String iconPath, String label) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, 2),
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFF5DBB8D),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/$iconPath',
                    width: 35,
                    height: 35,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 2),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _profileItem(String pageNage,String iconPath, String label) {
    return Expanded(
      child: InkWell(
        onTap: () {
          // onTap
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/$iconPath',
                  width: 35,
                  height: 35,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 35),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
    ],
        ),
      ),
    );
  }
}