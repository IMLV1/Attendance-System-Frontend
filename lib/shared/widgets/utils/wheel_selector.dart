import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WheelSelector extends StatefulWidget {
  final List<String> leftItems;
  final List<String>? rightItems;

  final int initialLeftIndex;
  final int? initialRightIndex;

  final void Function(int leftIndex, int? rightIndex) onChanged;

  const WheelSelector({
    super.key,
    required this.leftItems,
    this.rightItems,
    this.initialLeftIndex = 0,
    this.initialRightIndex,
    required this.onChanged,
  });

  @override
  State<WheelSelector> createState() => _WheelSelectorState();
}

class _WheelSelectorState extends State<WheelSelector> {
  late int _leftIndex;
  int? _rightIndex;

  late FixedExtentScrollController _leftController;
  FixedExtentScrollController? _rightController;

  static const double _itemExtent = 40;
  static const double _pickerHeight = 216;

  // 👇 ปรับความกว้างได้ตรงนี้
  static const double _leftWidth = 110;
  static const double _rightWidth = 110;
  static const double _spacing = 6;

  @override
  void initState() {
    super.initState();

    _leftIndex = widget.initialLeftIndex;
    _rightIndex = widget.initialRightIndex;

    _leftController =
        FixedExtentScrollController(initialItem: _leftIndex);

    if (widget.rightItems != null) {
      _rightController =
          FixedExtentScrollController(initialItem: _rightIndex ?? 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _pickerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ---------- PICKERS ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: _leftWidth,
                child: CupertinoPicker(
                  scrollController: _leftController,
                  itemExtent: _itemExtent,
                  selectionOverlay: const SizedBox(),
                  onSelectedItemChanged: (index) {
                    setState(() => _leftIndex = index);
                    widget.onChanged(_leftIndex, _rightIndex);
                  },
                  children: widget.leftItems
                      .map((e) => Center(child: Text(e)))
                      .toList(),
                ),
              ),

              if (widget.rightItems != null) ...[
                SizedBox(width: _spacing),
                SizedBox(
                  width: _rightWidth,
                  child: CupertinoPicker(
                    scrollController: _rightController,
                    itemExtent: _itemExtent,
                    selectionOverlay: const SizedBox(),
                    onSelectedItemChanged: (index) {
                      setState(() => _rightIndex = index);
                      widget.onChanged(_leftIndex, _rightIndex);
                    },
                    children: widget.rightItems!
                        .map((e) => Center(child: Text(e)))
                        .toList(),
                  ),
                ),
              ],
            ],
          ),

          // ---------- CENTER GREY BAR ----------
          IgnorePointer(
            child: Container(
              height: _itemExtent,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
