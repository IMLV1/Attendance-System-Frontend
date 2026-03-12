import 'package:flutter/cupertino.dart'; // เพิ่มสำหรับ CupertinoDatePicker
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarTimePopupContent extends StatefulWidget {
  // แก้ไข Parameter ให้รับทั้งวันที่และเวลา
  final Function(DateTime? start, DateTime? end, String startTime, String endTime) onSave;

  const CalendarTimePopupContent({super.key, required this.onSave});

  @override
  State<CalendarTimePopupContent> createState() => _CalendarTimePopupContentState();
}

class _CalendarTimePopupContentState extends State<CalendarTimePopupContent> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // เพิ่มสถานะเวลา (ส่วนที่ 3)
  bool _isStartTimePickerOpen = false;
  bool _isEndTimePickerOpen = false;
  String _startTime = "08:30";
  String _endTime = "--:--";

  void _onDataChanged() {
    widget.onSave(_rangeStart, _rangeEnd, _startTime, _endTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCalendarCard(), // ส่วนที่ 1: ปฏิทิน
        const SizedBox(height: 12),
        _buildDateSummary(), // ส่วนที่ 2: สรุปวันที่
        const SizedBox(height: 12),
        _buildTimeSelectionSection(), // ส่วนที่ 3: เลือกเวลา (เพิ่มใหม่)
      ], // ปิด Column หลัก
    ); // ปิด Column หลัก
  }

  // --- ฟังก์ชันส่วนที่ 3: เลือกเวลาแบบแยกซ้าย-ขวา ---
  // --- ส่วนเลือกเวลาแบบ Column ตาม Figma ---
  // --- ส่วนเลือกเวลาแบบ Column ตาม Figma ---
  Widget _buildTimeSelectionSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // --- ส่วนของ เวลาเข้างาน ---
          _buildTimeExpandableItem(
            label: "เวลาเข้างาน",
            time: _startTime,
            icon: Icons.access_time_outlined,
            isOpen: _isStartTimePickerOpen,
            onTap: () => setState(() {
              _isStartTimePickerOpen = !_isStartTimePickerOpen;
              _isEndTimePickerOpen = false; // ปิดอีกส่วนไว้เสมอ
            }),
            onTimeChanged: (newTime) {
              setState(() {
                _startTime = "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}";
              });
              _onDataChanged();
            },
          ),

          const Divider(height: 1, indent: 50, endIndent: 16, color: Colors.black12),

          // --- ส่วนของ เวลาออกงาน ---
          _buildTimeExpandableItem(
            label: "เวลาออกงาน",
            time: _endTime,
            icon: Icons.access_time_outlined,
            isOpen: _isEndTimePickerOpen,
            onTap: () => setState(() {
              _isEndTimePickerOpen = !_isEndTimePickerOpen;
              _isStartTimePickerOpen = false; // ปิดอีกส่วนไว้เสมอ
            }),
            onTimeChanged: (newTime) {
              setState(() {
                _endTime = "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}";
              });
              _onDataChanged();
            },
          ),
        ], // ปิด Column หลัก
      ), // ปิด Container หลัก
    );
  }

  // Widget ช่วยสร้างแถวที่ขยายได้ (Expandable Item)
  Widget _buildTimeExpandableItem({
    required String label,
    required String time,
    required IconData icon,
    required bool isOpen,
    required VoidCallback onTap,
    required Function(DateTime) onTimeChanged,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 22, color: Colors.black87),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                const Spacer(),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isOpen ? Colors.blue : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        // ถ้าเปิดอยู่ ให้แสดงกงล้อเลือกเวลาเฉพาะของตัวเอง
        if (isOpen)
          SizedBox(
            height: 150,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              initialDateTime: () {
                try {
                  if (time == "--:--" || time == "---") return DateTime.now();
                  final parts = time.split(':');
                  return DateTime(2026, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
                } catch (e) {
                  return DateTime.now(); // ถ้าพลาดให้กลับมาที่เวลาปัจจุบัน
                }
              }(),              onDateTimeChanged: onTimeChanged,
            ),
          ),
      ],
    );
  }

  // --- ส่วนที่ 2: สรุปวันที่ (จากรอบที่แล้ว) ---
  Widget _buildDateSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(child: _infoCol("จากวันที่", _formatDate(_rangeStart))),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          Expanded(child: _infoCol("ถึงวันที่", _formatDate(_rangeEnd))),
        ], // ปิด Row วันที่
      ),
    );
  }

  // --- ส่วนที่ 1: ปฏิทิน  ---
  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: TableCalendar(
        locale: 'th_TH',
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(3000, 12, 31),
        focusedDay: _focusedDay,
        rangeStartDay: _rangeStart,
        rangeEndDay: _rangeEnd,
        rangeSelectionMode: RangeSelectionMode.enforced,
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        onRangeSelected: (start, end, focusedDay) {
          setState(() {
            _rangeStart = start;
            _rangeEnd = end;
            _focusedDay = focusedDay;
          });
          _onDataChanged();
        },
        calendarStyle: CalendarStyle(
          // 1. สีไฮไลต์ช่วงวันที่ (จะขึ้นก็ต่อเมื่อเราเริ่มเลือกแล้ว)
          rangeHighlightColor: const Color(0xFFE3F2FD),

          rangeStartDecoration: const BoxDecoration(
            color: Color(0xFF4A80F0),
            shape: BoxShape.circle,
          ),

          rangeEndDecoration: const BoxDecoration(
            color: Color(0xFF4A80F0),
            shape: BoxShape.circle,
          ),

          // --- แก้ไขจุดนี้: ปิดสีฟ้าของวันที่ปัจจุบันออก ---

          // 2. ปรับ Today ให้ไม่มีพื้นหลังสีฟ้า (ทำให้ดูเหมือนยังไม่ได้เลือก)
          todayDecoration: BoxDecoration(
            color: Colors.transparent, // ทำให้โปร่งใส
            shape: BoxShape.circle,
          ),

          // 3. ปรับสีตัวเลขของวันนี้ให้เป็นสีดำปกติ (ไม่ใช่สีขาว) เพื่อให้มองเห็นบนพื้นขาว
          todayTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),

          // 4. ส่วนวันที่ถูกเลือก (เมื่อจิ้มแล้วถึงจะขึ้นสีฟ้า)
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF4A80F0),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "---";
    final months = ['', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
    return "${date.day} ${months[date.month]} ${(date.year + 543).toString().substring(2)}";
  }

  Widget _infoCol(String label, String value) {
    return Row(
      children: [
        const Icon(Icons.calendar_month, size: 18, color: Colors.black45),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}