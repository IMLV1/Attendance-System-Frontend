import 'package:flutter/material.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/helper/color_picker_popup/hue_thumb_shape.dart';
import 'package:attendance_system/shared/widgets/helper/color_picker_popup/input_box.dart';

class ColorPickerPopup {
  final String title;
  final String buttonLabel;
  final Color selected;
  final void Function(Color color)? onSubmit;

  final double maxHeight;
  final double minHeight;
  final FlexFit fit;
  final bool scroll;

  const ColorPickerPopup({
    this.title = 'เลือกสี',
    this.buttonLabel = 'บันทึก',
    required this.selected,
    this.onSubmit,
    this.maxHeight = 700,
    this.minHeight = 0,
    this.fit = FlexFit.tight,
    this.scroll = false,
  });

  void showPopup(BuildContext context) {
    HSVColor hsv = HSVColor.fromColor(selected);

    const pickerSize = 28.0;
    const innerSize = 20.0;

    final hexCtrl = TextEditingController();
    final rCtrl = TextEditingController();
    final gCtrl = TextEditingController();
    final bCtrl = TextEditingController();

    void syncTextFromHSV() {
      final c = hsv.toColor();
      final argb = c.toARGB32();

      rCtrl.text = ((argb >> 16) & 0xFF).toString();
      gCtrl.text = ((argb >> 8) & 0xFF).toString();
      bCtrl.text = (argb & 0xFF).toString();

      hexCtrl.text = '#${argb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    }

    PushPopup(
      title: title,
      backButton: true,
      buttonLabel: buttonLabel,
      maxHeight: maxHeight,
      minHeight: minHeight,
      fit: fit,
      scroll: scroll,
      buttonAction: (val) {
        Navigator.of(val).pop();
        if (onSubmit != null) onSubmit!(hsv.toColor());
      },
      content: StatefulBuilder(
        builder: (context, setState) {
          const svWidth = 380.0;
          const svHeight = 280.0;

          void updateSV(Offset p) {
            final s = (p.dx / svWidth).clamp(0.0, 1.0);
            final v = 1 - (p.dy / svHeight).clamp(0.0, 1.0);
            setState(() {
              hsv = hsv.withSaturation(s).withValue(v);
              syncTextFromHSV();
            });
          }

          void updateFromRGB(StateSetter setState) {
            final r = int.tryParse(rCtrl.text) ?? 0;
            final g = int.tryParse(gCtrl.text) ?? 0;
            final b = int.tryParse(bCtrl.text) ?? 0;

            final color = Color.fromARGB(255, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));

            setState(() {
              hsv = HSVColor.fromColor(color);
            });
          }
          
          syncTextFromHSV();

          final color = hsv.toColor();

          const padding = 3.0;

          final double pickerLeft = (hsv.saturation * svWidth - pickerSize / 2).clamp(padding, svWidth - pickerSize - padding);

          final double pickerTop = ((1 - hsv.value) * svHeight - pickerSize / 2).clamp(padding, svHeight - pickerSize - padding);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: SizedBox(
                  width: svWidth,
                  height: svHeight,
                  child: GestureDetector(
                    onPanDown: (val) => updateSV(val.localPosition),
                    onPanUpdate: (val) => updateSV(val.localPosition),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [ Colors.white, Color(0xCCFFFFFF), Color(0x66FFFFFF), Color(0x00FFFFFF) ],
                              stops: [ 0.0, 0.35, 0.65, 1.0 ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x00000000), Color(0x33000000), Color(0x99000000), Color(0xFF000000) ],
                              stops: [ 0.0, 0.45, 0.75, 1.0 ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: pickerLeft,
                          top: pickerTop,
                          child: Container(
                            width: pickerSize,
                            height: pickerSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: innerSize,
                                height: innerSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Column(
                children: [
                  SizedBox(
                    height: 18,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              colors: [ Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.purple, Colors.red ]
                            )
                          ),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 0,
                            activeTickMarkColor: Colors.transparent,
                            inactiveTrackColor: Colors.transparent,
                            disabledActiveTrackColor: Colors.transparent,
                            disabledInactiveTrackColor: Colors.transparent,
                            overlayShape: SliderComponentShape.noOverlay,
                            tickMarkShape: SliderTickMarkShape.noTickMark,
                            thumbColor: hsv.toColor(),
                            thumbShape: HueThumbShape(),
                          ),
                          child: Slider(
                            value: hsv.hue,
                            min: 0,
                            max: 360,
                            onChanged: (val) => setState(() => hsv = hsv.withHue(val)),
                          )
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  InputBox(label: 'Hex', flex: 2, controller: hexCtrl,
                    onChanged: (v) {
                      final hex = v.replaceAll('#', '');
                      if (hex.length != 6) return;

                      final val = int.tryParse(hex, radix: 16);
                      if (val == null) return;

                      setState(() {
                        hsv = HSVColor.fromColor(Color(0xFF000000 | val));
                      });
                    },
                  ),
                  InputBox(label: 'R', controller: rCtrl, onChanged: (_) => updateFromRGB(setState)),
                  InputBox(label: 'G', controller: gCtrl, onChanged: (_) => updateFromRGB(setState)),
                  InputBox(label: 'B', controller: bCtrl, onChanged: (_) => updateFromRGB(setState)),
                ],
              ),
            ],
          );
        }
      ),
    ).showPopup(context);
  }
}

