import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class Header extends StatelessWidget {

  final String title;

  const Header({super.key, this.title = 'Default Title'});

  @override
  Widget build(BuildContext context);

}
