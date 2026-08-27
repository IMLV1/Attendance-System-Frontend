import 'dart:math' as math;

import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:flutter/material.dart';

/// ป้ายตำแหน่งของผู้ใช้ — จำกัดจำนวนบรรทัด แล้วบอกด้วยป้าย `...` ว่ายังมีที่ซ่อนอยู่
///
/// 🚩 (2026-08-27) เดิมทั้ง `UserInfoButton` และ `TextRoleButton` ต่างเขียน
/// `Wrap` ของตัวเองด้วย markup ชุดเดียวกันเป๊ะ และมีปัญหาเดียวกันสองข้อ:
///
/// 1. **ล้นกรอบ** — ป้ายเดี่ยวที่ยาวกว่าพื้นที่ที่เหลือทำให้ `Wrap` ล้น
///    (`Wrap` ไม่ตัดของที่กว้างเกิน มันปล่อยให้ทะลุออกไป) เห็นเป็นแถบส้มดำ
///    "RIGHT OVERFLOWED BY n PIXELS" ตอนคอลัมน์ขวาของ master-detail แคบลง
/// 2. **สูงไม่จำกัด** — ผู้ใช้ที่มีหลายตำแหน่งดัน `Wrap` ลงไปหลายบรรทัด
///    แถวในลิสต์เลยสูงไม่เท่ากันจนอ่านยาก
///
/// ที่นี่วัดความกว้างของแต่ละป้ายด้วย `TextPainter` (สไตล์เดียวกับที่วาดจริง
/// รวม `textScaler` ของระบบ) แล้วคำนวณเองว่าป้ายไหนอยู่ใน [maxLines] บรรทัดแรก
/// ที่เหลือถูกซ่อนแล้วแทนด้วยป้ายเดียว
class RoleChips extends StatelessWidget {

  final List<Role> roles;

  /// จำนวนบรรทัดสูงสุด — เกินกว่านี้ตัดแล้วขึ้น `...`
  final int maxLines;

  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;

  static const double _padH = 5;
  static const double _padV = 2;
  static const double _fontSize = 10;

  const RoleChips({
    super.key,
    required this.roles,
    this.maxLines = 2,
    this.spacing = 5,
    this.runSpacing = 5,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        // ไม่มีขอบเขตให้คิด (เช่นอยู่ใน Row ที่ไม่ได้ห่อ Expanded/Flexible)
        // — วาดตรงๆ เหมือนเดิม ดีกว่าเดาแล้วตัดผิด
        if (!maxWidth.isFinite) {
          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            alignment: alignment,
            children: [for (final r in roles) _chip(context, r.name, r.color, maxWidth)],
          );
        }

        final base = DefaultTextStyle.of(context).style;
        final scaler = MediaQuery.textScalerOf(context);

        double widthOf(String text, Color color) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: _styleFor(base, color)),
            textDirection: Directionality.of(context),
            textScaler: scaler,
            maxLines: 1,
          )..layout();
          // ป้ายเดี่ยวที่ยาวเกินพื้นที่จะถูกบีบให้พอดีแล้วตัดด้วย ellipsis
          return math.min(painter.width + _padH * 2, maxWidth);
        }

        final widths = [for (final r in roles) widthOf(r.name, r.color)];
        final moreWidth = widthOf('...', _moreColor);

        // จัดป้ายลงบรรทัดแบบเดียวกับที่ Wrap ทำ (เติมจนไม่พอแล้วขึ้นบรรทัดใหม่)
        final lines = <List<int>>[];
        var current = <int>[];
        var currentWidth = 0.0;
        var index = 0;

        while (index < roles.length) {
          final width = widths[index];
          final needed = current.isEmpty ? width : currentWidth + spacing + width;

          if (needed <= maxWidth) {
            current.add(index);
            currentWidth = needed;
            index++;
            continue;
          }

          lines.add(current);
          current = <int>[];
          currentWidth = 0;
          if (lines.length == maxLines) break; // ไม่มีบรรทัดให้ขึ้นแล้ว
        }
        if (current.isNotEmpty && lines.length < maxLines) lines.add(current);

        var hidden = roles.length - lines.fold<int>(0, (sum, l) => sum + l.length);

        // ถ้ามีของซ่อน ต้องเจียดที่บรรทัดสุดท้ายให้ป้าย `...` ด้วย
        if (hidden > 0 && lines.isNotEmpty) {
          final last = lines.last;
          double lineWidth() => last.isEmpty
              ? 0
              : last.fold<double>(0, (sum, i) => sum + widths[i]) +
                  spacing * (last.length - 1);

          while (last.isNotEmpty && lineWidth() + spacing + moreWidth > maxWidth) {
            last.removeLast();
            hidden++;
          }
        }

        final visible = [for (final line in lines) ...line];

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          alignment: alignment,
          children: [
            for (final i in visible)
              _chip(context, roles[i].name, roles[i].color, maxWidth),
            if (hidden > 0) _chip(context, '...', _moreColor, maxWidth),
          ],
        );
      },
    );
  }

  static const Color _moreColor = Color(0xFF7E7E7E);

  TextStyle _styleFor(TextStyle base, Color color) =>
      base.merge(TextStyle(color: color, fontSize: _fontSize));

  Widget _chip(BuildContext context, String text, Color color, double maxWidth) {
    final style = _styleFor(DefaultTextStyle.of(context).style, color);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth.isFinite ? maxWidth : double.infinity,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: _padV, horizontal: _padH),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: color.withAlpha((20 * 255 / 100).toInt()),
        ),
        child: Text(
          text,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
