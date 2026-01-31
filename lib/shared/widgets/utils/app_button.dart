import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppButton extends StatelessWidget {
  final String icon;
  final String title;
  final String subTitle;
  final String? notation;
  final Color? iconColor;
  final bool arrow;
  final String? timeStamp;
  final VoidCallback? onPressed;

  const AppButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.notation,
    this.iconColor,
    required this.arrow,
    this.timeStamp,
    this.onPressed,
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
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: timeStamp == null ? 15 : 5,
          bottom: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (timeStamp != null)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  timeStamp!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (iconColor ?? Color(0xFFC7C7C7)).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/$icon',
                    width: 24,
                    height: 24,
                    colorFilter: iconColor != null ? ColorFilter.mode(iconColor!, BlendMode.srcIn) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7E7E7E),
                        ),
                      ),
                      if (notation != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          notation!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (arrow)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
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
