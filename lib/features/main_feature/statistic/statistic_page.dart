import 'package:attendance_system/features/main_feature/statistic/statistic_body.dart';
import 'package:attendance_system/services/statistic/statistic_service.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/material.dart';

/// 🚩 (2026-08-27) เนื้อหาทั้งหมดย้ายไป [StatisticBody] ซึ่งใช้ร่วมกับแท็บสถิติ
/// ในหน้า "ข้อมูลบุคลากร" — เดิมสองหน้านี้เป็นโค้ดคนละชุดที่ก๊อปกันมา แล้วหน้านั้น
/// ค้างอยู่กับหน้าตาก่อน Phase 3
///
/// เหลือไว้ที่นี่แค่สองอย่างที่เป็นของหน้านี้จริงๆ: แถบหัวเรื่อง กับ service ที่ยิง
class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hideNavigation: false,
      header: Header.mainHeader(
        context,
        title: 'สถิติ',
        subTitle: 'Statistic',
        iconPath: 'statis.svg',
      ),
      content: StatisticBody(
        requests: (yearFilter) => [
          () => StatisticService().getStatistic(year: yearFilter),
          () => StatisticService().getWorkingHour(),
          () => StatisticService().getFilterRange(),
        ],
      ),
    );
  }
}
