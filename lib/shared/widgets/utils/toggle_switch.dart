import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ToggleSwitch extends StatefulWidget {
  final String icon;
  final String label;
  final ValueChanged<bool>? onChanged;

  final bool subSwitch;
  final String? subLabel;
  final ValueChanged<bool>? onSubChanged;

  const ToggleSwitch({
    super.key,
    required this.icon,
    required this.label,
    this.onChanged,
    this.subSwitch = false,
    this.subLabel,
    this.onSubChanged,
  });

  @override
  State<ToggleSwitch> createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch> {
  bool _value = false;
  bool _subValue = false;

  @override
  Widget build(BuildContext context) {
    final showSub = widget.subSwitch && _value;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------- MAIN SWITCH ----------
          Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: SvgPicture.asset(
                  'assets/images/${widget.icon}',
                  colorFilter: ColorFilter.mode(
                    AppColors.blackTextColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Spacer(),
              Transform.scale(
                scale: 0.85,
                child: CupertinoSwitch(
                  value: _value,
                  activeTrackColor: AppColors.primaryColor,
                  onChanged: (val) {
                    setState(() {
                      _value = val;
                      if (!val) _subValue = false;
                    });
                    widget.onChanged?.call(val);
                  },
                ),
              )
            ],
          ),

          // ---------- SUB SWITCH (SLIDE FROM TOP) ----------
          AnimatedSize(
            duration: Duration(milliseconds: 200),
            alignment: Alignment.bottomCenter,
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 180),
              opacity: showSub ? 1 : 0,
              child: showSub
                  ? Column(
                children: [
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Divider(height: 0),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.subLabel ?? 'จำเป็นต้องแนบ',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Spacer(),
                        Transform.scale(
                          scale: 0.85,
                          child: CupertinoSwitch(
                            value: _subValue,
                            activeTrackColor: AppColors.primaryColor,
                            onChanged: (val) {
                              setState(() => _subValue = val);
                              widget.onSubChanged?.call(val);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
                  : SizedBox(),
            ),
          )

        ],
      ),
    );
  }
}
