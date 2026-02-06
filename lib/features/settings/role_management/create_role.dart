import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:flutter/cupertino.dart';

import '../../../shared/widgets/head_bar/header.dart';

class CreateRole extends StatelessWidget {
  const CreateRole({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        header: Header.subHeader(
            context,
            title: 'สร้างตำแหน่งใหม่'
        ),
        content: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(),
          )
        )
    );
  }
}