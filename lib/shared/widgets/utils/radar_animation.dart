import 'package:flutter/material.dart';

class RadarAnimation extends StatefulWidget {
  final Color color; // รับสีมาจากปุ่มหลักเพื่อให้สีเรดาร์เหมือนสีปุ่ม

  /// 🚩 (2026-08-22) ขนาดตั้งต้นของวงคลื่น — เดิม hardcode 180
  /// ตอนนี้ปุ่มเช็คอินยืด-หดตามความสูงจอ เรดาร์เลยต้องยืดตามด้วย
  final double size;

  const RadarAnimation({super.key, required this.color, this.size = 180});

  @override
  State<RadarAnimation> createState() => _RadarAnimationState();
}

class _RadarAnimationState extends State<RadarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 1. กำหนดเวลา: 1 รอบใช้เวลา 2.5 วินาที
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(); // สั่งให้ทำงานวนไปเรื่อยๆ (Infinite Loop)
  }

  @override
  void dispose() {
    _controller.dispose(); // สำคัญมาก: ต้องคืนหน่วยความจำเมื่อไม่ได้ใช้
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // เราจะสร้างวงกลม 3 วงที่เริ่มขยายตัวไม่พร้อมกัน
            _buildCircle(0.0),
            _buildCircle(0.33),
          ],
        );
      },
    );
  }

  Widget _buildCircle(double delay) {
    // คำนวณค่าความก้าวหน้า (0.0 ถึง 1.0)
    double progress = (_controller.value - delay) % 1.0;
    double opacity = (0.8 - progress).clamp(0.0, 0.8);

    return Transform.scale(
      // ขยายจากขนาด 1.0 (เท่าปุ่ม) ไปจนถึง 1.8 เท่า
      scale: 0.9 + (progress * 0.7),

      child: Container(
        // ขนาดตั้งต้น (ให้เล็กกว่าปุ่มจริงนิดหน่อยจะดูฟุ้งสวยกว่า)
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // ความจาง (Opacity) จะค่อยๆ ลดลงตามการขยายตัว
          color: widget.color.withOpacity(opacity),
        ),
      ),
    );
  }
}