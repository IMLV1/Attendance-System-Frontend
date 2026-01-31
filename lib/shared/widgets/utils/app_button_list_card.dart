import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'app_button.dart';

class AppButtonListCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const AppButtonListCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return AppButton(
            icon: item['icon'],
            title: item['title'],
            subTitle: item['subTitle'],
            iconColor: item['iconColor'],
            arrow: item['arrow'] ?? false,
            timeStamp: item['timeStamp'],
            notation: item['notation'],
            onPressed: item['onPressed'],
          );
        },
        separatorBuilder: (_, index) => const Divider(
          height: 1,
          thickness: 1,
          indent: 70,
          endIndent: 10,
          color: Color(0xFFE0E0E0),
        ),
      ),
    );
  }
}
