import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 1. คลาสเก็บการตั้งค่าของ Popup ในแต่ละหน้า
class PopupConfig {
  final String title;
  final String buttonLabel;
  final void Function(BuildContext context)? buttonAction;
  final bool backButton;
  final bool isLoading; // ตัวบอกสถานะว่ากำลังยิง API อยู่หรือไม่
  final double maxHeight;
  final double minHeight;
  final FlexFit fit;
  final bool scroll;
  final Color buttonColor;
  final bool safeArea;

  PopupConfig({
    required this.title,
    this.buttonLabel = '',
    this.buttonAction,
    this.backButton = true,
    this.isLoading = false,
    this.maxHeight = double.infinity,
    this.minHeight = 0,
    this.fit = FlexFit.loose,
    this.scroll = true,
    this.buttonColor = AppColors.primaryColor,
    this.safeArea = true,
  });

  // ฟังก์ชันช่วยก็อปปี้ค่าเดิม แล้วเปลี่ยนแค่บางค่า (เช่น เปลี่ยนแค่ isLoading)
  PopupConfig copyWith({
    String? title,
    String? buttonLabel,
    void Function(BuildContext context)? buttonAction,
    bool? backButton,
    bool? isLoading,
    double? maxHeight,
    double? minHeight,
    FlexFit? fit,
    bool? scroll,
    Color? buttonColor,
    bool? safeArea,
  }) {
    return PopupConfig(
      title: title ?? this.title,
      buttonLabel: buttonLabel ?? this.buttonLabel,
      buttonAction: buttonAction ?? this.buttonAction,
      backButton: backButton ?? this.backButton,
      isLoading: isLoading ?? this.isLoading,
      maxHeight: maxHeight ?? this.maxHeight,
      minHeight: minHeight ?? this.minHeight,
      fit: fit ?? this.fit,
      scroll: scroll ?? this.scroll,
      buttonColor: buttonColor ?? this.buttonColor,
      safeArea: safeArea ?? this.safeArea,
    );
  }
}

class PopupProvider extends InheritedWidget {
  final PopupConfig config;
  final void Function(PopupConfig) setConfig;

  const PopupProvider({
    super.key,
    required this.config,
    required this.setConfig,
    required super.child,
  });

  static PopupProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<PopupProvider>();
    assert(provider != null, 'No PopupProvider found in context');
    return provider!;
  }

  // ⚡ เพิ่มฟังก์ชัน push แบบ Global ไว้ตรงนี้! ⚡
  // มันจะจัดการเอา Material สีทึบ และ ScrollView มาห่อให้ทุกหน้าอัตโนมัติ
  Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute( // แนะนำให้ใช้ Cupertino เพื่อให้ตอนสไลด์ขอบมันเนียนกว่า Material
        builder: (navContext) {

          print(config.scroll);

          // 1. ห่อด้วย SingleChildScrollView (ถ้าตั้งค่า scroll เป็น true)
          Widget content = config.scroll
              ? SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            child: page,
          )
              : page;

          // 2. ห่อด้วย Material สีทึบ เพื่อแก้ปัญหา Text ซ้อนกัน!
          return Material(
            color: AppColors.backgroundColor, // ดึงสีพื้นหลังมาใช้
            child: content,
          );
        },
      ),
    );
  }

  @override
  bool updateShouldNotify(PopupProvider oldWidget) => true;
}