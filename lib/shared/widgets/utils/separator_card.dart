import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SeparatorCard extends StatelessWidget {

  final List<Widget> children;
  final EdgeInsetsGeometry separatorPadding;
  final BorderRadius borderRadius;

  const SeparatorCard({
    super.key,
    this.children = const [],
    this.separatorPadding = const EdgeInsetsGeometry.all(0),
    this.borderRadius = const BorderRadius.all(Radius.circular(25))
  });

  @override
  Widget build(BuildContext context) {

    List<Widget> withSeparator(List<Widget> children) {

      Widget separator = Padding(
          padding: separatorPadding,
          child: Divider(height: 0)
      );

      final result = <Widget>[];

      for (int i = 0; i < children.length; i++) {
        result.add(children[i]);
        if (i != children.length - 1) {
          result.add(separator);
        }
      }
      return result;
    }

    return children.isNotEmpty ? Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: borderRadius
        ),
        child: Column(
          children: withSeparator(children),
        )
    ) : SizedBox.shrink();
  }
}