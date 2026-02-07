import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppButton extends StatelessWidget {
  final String icon;
  final String title;
  final String? subTitle;
  final FontWeight weightTitle;
  final String? notation;
  final Color? iconColor;
  final bool arrow;
  final String? timeStamp;
  final VoidCallback? onPressed;

  const AppButton({
    super.key,
    required this.icon,
    required this.title,
    this.subTitle,
    this.notation,
    this.iconColor,
    this.arrow = true,
    this.timeStamp,
    this.onPressed,
    this.weightTitle = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // เวลา (ถ้ามี)
            if (timeStamp != null)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  timeStamp!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7C7C7C)
                  ),
                ),
              ),

            // const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ไอคอน
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (iconColor ?? const Color(0xFFC7C7C7))
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset(
                      'assets/images/$icon',
                      colorFilter: iconColor != null
                          ? ColorFilter.mode(
                        iconColor!,
                        BlendMode.srcIn,
                      )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // ข้อความ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: weightTitle),
                      ),

                      if (subTitle != null) ...[
                        Text(
                          subTitle!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7C7C7C),
                          ),
                        ),
                      ],

                      if (notation != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          notation!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7E7E7E),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ลูกศร
                if (arrow)
                  const SizedBox(width: 10),

                if (arrow)
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: SvgPicture.asset(
                      'assets/images/icon_next.svg',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
