import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:flutter/material.dart';
// import 2 ไฟล์ด้านบนมาด้วย และ import ServiceUpdater ของคุณ

class MainScreenExample extends StatelessWidget {
  const MainScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 1. เรียกเปิด DynamicPushPopup
            DynamicPushPopup(
              initialConfig: PopupConfig(
                title: 'หน้าแรก',
                maxHeight: 600,
              ),
              builder: (context) => const PageOne(), // โยนหน้า 1 เข้าไป
            ).showPopup(context);
          },
          child: const Text('เปิด Dynamic Popup'),
        ),
      ),
    );
  }
}

// ==========================================
// หน้าที่ 1 (หน้าธรรมดา)
// ==========================================
class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('นี่คือหน้าแรก'),
        ElevatedButton(
          onPressed: () async {
            final provider = PopupProvider.of(context);
            final oldConfig = provider.config;

            // 2. เซ็ตค่าเตรียมตัวไปหน้ายิง API
            // **ทริค**: เราเตรียมปุ่มขวาบนไว้รอเลย (ปุ่ม ยืนยัน)
            provider.setConfig(PopupConfig(
              title: 'ยืนยันการบันทึก',
              buttonLabel: 'ยืนยัน',
              // buttonAction: (ctx) {...} ยังไม่ต้องใส่ เพราะเดี๋ยวหน้า 2 จะมาทับให้
            ));

            await PopupProvider.of(context).push(context, const PageTwoApi());

            // 3. พอกลับมา คืนค่าเดิม
            provider.setConfig(oldConfig);
          },
          child: const Text('ไปหน้ายิง API >'),
        ),
      ],
    );
  }
}

// ==========================================
// หน้าที่ 2 (หน้ายิง API โดยมี ServiceUpdater)
// ==========================================
class PageTwoApi extends StatelessWidget {
  const PageTwoApi({super.key});

  @override
  Widget build(BuildContext context) {
    // ใช้ ServiceUpdater ตามปกติของคุณเลย
    return ServiceUpdater(
      request: () async {
        return Utils.mockResponse(delayed: 200, statusCode: 200);
      },
      onSuccess: () {
        Navigator.of(context).pop('success'); // เสร็จแล้วปิดหน้านี้
      },
      builder: (trigger, state, errorMessage) {

        // ⚡ หัวใจสำคัญ ⚡
        // ตรวจสอบว่า state ปัจจุบันคือ Loading หรือเปล่า
        final bool isApiLoading = (state == ServiceUpdatorState.loading);

        // ส่งค่าขึ้นไปบอก Header (ต้องใส่ใน addPostFrameCallback ป้องกัน Error วาดทับซ้อน)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final provider = PopupProvider.of(context);

          // อัปเดตเฉพาะเมื่อสถานะมันเปลี่ยน เพื่อไม่ให้มันรีเฟรชรัวๆ
          if (provider.config.isLoading != isApiLoading || provider.config.buttonAction != trigger) {
            provider.setConfig(
              // copyWith ดีมากตรงที่มันจะเก็บ Title เดิมไว้ แต่เปลี่ยนแค่ปุ่มกับ Loading
                provider.config.copyWith(
                  isLoading: isApiLoading,
                  buttonAction: (ctx) => trigger(), // ผูกปุ่มขวาบนเข้ากับ trigger ของหน้านี้!
                )
            );
          }
        });

        // -------------------------

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text('กรุณากดปุ่ม "ยืนยัน" ที่มุมขวาบน เพื่อเริ่มยิง API'),
              const SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
            ],
          ),
        );
      },
    );
  }
}