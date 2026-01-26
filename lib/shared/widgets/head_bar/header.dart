import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract class Header extends StatelessWidget {

  final String title;

  const Header({super.key, this.title = 'Default Title'});

  @override
  Widget build(BuildContext context);

}
