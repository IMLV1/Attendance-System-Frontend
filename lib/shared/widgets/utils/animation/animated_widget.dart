import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedSizeWidget extends StatelessWidget {

  final bool enable;
  final Widget child;

  const AnimatedSizeWidget({
    super.key,
    required this.enable,
    required this.child
  });

  @override
  Widget build(BuildContext context) {

    return AnimatedSize(
      duration: Duration(milliseconds: 250),
      alignment: Alignment.bottomCenter,
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 180),
        opacity: enable ? 1 : 0,
        child: enable
            ? child
            : SizedBox(),
      ),
    );
  }

}