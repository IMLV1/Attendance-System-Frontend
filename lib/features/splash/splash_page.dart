import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// หน้าที่ผู้ใช้เห็นระหว่างรอ `AuthState.init()` ตอนเปิดแอป
///
/// 🚩 (2026-08-26) route `/splash` มีมาตั้งแต่แรกแต่**ไม่มีวันถูกเห็น** เพราะ
/// `main()` เดิม `await init()` ให้จบก่อนแล้วค่อย `runApp()` — กว่า Flutter จะ
/// วาดเฟรมแรก `auth.status` ก็ไม่ใช่ `unknown` แล้ว redirect จึงไม่เคยพามาที่นี่
/// (ของเดิมเป็น `Center(child: CircularProgressIndicator())` ลอยๆ ไม่มีพื้นหลัง
/// ด้วยซ้ำ ถ้าถูกเห็นจริงจะเป็นวงกลมบนพื้นดำ)
///
/// พอย้าย `init()` ไปหลัง `runApp()` หน้านี้กลายเป็นของจริงที่ผู้ใช้เห็นทุกครั้ง
/// ที่เปิดแอป จึงต้องต่อเนื่องกับสองชั้นที่ขนาบมัน:
///
/// - **ชั้นก่อนหน้า** = LaunchScreen ของ OS (`flutter_native_splash`) ซึ่งวาง
///   `app_logo.png` กลางจอบนพื้น `#F6F6F6`
/// - **ชั้นถัดไป** = `/login` ซึ่งวางโลโก้ตัวเดียวกันกว้าง 200 บนพื้นสีเดียวกัน
///
/// จึงใช้โลโก้ตัวเดิม ขนาดเดิม สีพื้นเดิมทั้งสามชั้น ผู้ใช้จะไม่เห็นรอยต่อ
/// เห็นแค่ตัวหมุนโผล่ขึ้นมาใต้โลโก้ที่นิ่งอยู่แล้ว
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 36),

            // ตัวหมุนเล็กๆ พอให้รู้ว่าไม่ได้ค้าง — ไม่ควรเด่นกว่าโลโก้
            // เพราะปกติจะอยู่บนจอแค่เสี้ยววินาที
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
