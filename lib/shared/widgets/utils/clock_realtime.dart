import 'dart:async';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';
import 'package:intl/intl.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  DateTime? _networkTime;
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _syncTime();
  }

  // ฟังก์ชันดึงเวลาจาก Network
  Future<void> _syncTime() async {
    try {
      // ดึงเวลาจาก Google NTP Server (เสถียรและฟรี)
      DateTime ntpTime = await NTP.now(lookUpAddress: 'time.google.com');

      if (mounted) {
        setState(() {
          _networkTime = ntpTime;
          _isLoading = false;
        });
        _startClock();
      }
    } catch (e) {
      // หากดึงไม่ได้ (เช่น ไม่มีเน็ต)
      debugPrint("NTP Error: $e");
      // คุณอาจจะเลือกหยุดแอป หรือแจ้งให้ต่อเน็ตก่อนใช้งาน
    }
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _networkTime != null) {
        setState(() {
          _networkTime = _networkTime!.add(const Duration(seconds: 1));
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Text("กำลังซิงค์เวลา...");

    return Column(
      children: [
        Text(
          DateFormat('HH:mm').format(_networkTime!),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(
          DateFormat('EEEE d MMMM yyyy', 'th').format(_networkTime!),
          style: const TextStyle(fontSize: 15, color: AppColors.lightTextColor),
        ),
      ],
    );
  }
}