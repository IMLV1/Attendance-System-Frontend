import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextToggleSwitch extends StatefulWidget {
  final Function(bool isFirst) onChanged;

  final double width;
  final double height;

  final String label1;
  final String label2;

  final Color color;
  final Color backgroundColor;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isFirst;

  const TextToggleSwitch({
    super.key,
    required this.onChanged,
    this.width = 150,
    this.height = 30,
    required this.label1,
    required this.label2,
    this.color = const Color(0xFF4986FF),
    this.backgroundColor = const Color(0xFF515151),
    this.fontSize = 15,
    this.fontWeight = FontWeight.normal,
    this.isFirst = true
  });

  @override
  State<TextToggleSwitch> createState() => _TextToggleSwitchState();
}

class _TextToggleSwitchState extends State<TextToggleSwitch> {
  // false = เช้า, true = เย็น (หรือแล้วแต่ logic ที่คุณต้องการ)
  bool isSecond = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSecond = !widget.isFirst;
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 4.0;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor.withValues(alpha: 0.05), // สีพื้นหลังรวม (สีเทาจางๆ)
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          // 1. ส่วนของตัวเลื่อน (Background สีฟ้าอ่อนที่วิ่งไปมา)
          AnimatedAlign(
            alignment: isSecond ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              width: (widget.width / 2) - padding, // ความกว้างครึ่งหนึ่ง ลบ padding
              margin: const EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1), // สีฟ้าอ่อนตามรูป
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),

          Row(
            children: [
              _buildLabel(
                title: widget.label1,
                isSelected: !isSecond,
                onTap: () {
                  setState(() => isSecond = false);
                  widget.onChanged(true); // true = morning
                },
              ),
              _buildLabel(
                title: widget.label2,
                isSelected: isSecond,
                onTap: () {
                  setState(() => isSecond = true);
                  widget.onChanged(false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent, // ให้กดติดง่ายขึ้น
        child: Container(
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              color: isSelected ? widget.color : widget.backgroundColor,
            ),
          ),
        ),
      ),
    );
  }
}