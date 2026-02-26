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
  final Widget? arrowWidget;
  final Color? bg;

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
    this.arrowWidget,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Stack(
          children: [
            Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ไอคอน
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bg ?? (iconColor ?? const Color(0xFFC7C7C7)).withValues(alpha: 0.2),
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

                if (arrow)
                  arrowWidget ?? SvgPicture.asset(
                    'assets/images/icon_next.svg',
                  )
              ],
            ),
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
          ],
        ),
      ),
    );
  }
}
