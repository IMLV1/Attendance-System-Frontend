import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WheelSelector extends StatefulWidget {
  final List<String> leftItems;
  final List<String>? rightItems;

  final int initialLeftIndex;
  final int? initialRightIndex;

  final double height;
  final double leftWidth;
  final double rightWidth;
  final double spacing;
  final bool looping;

  final bool refreshRight;

  final void Function(int leftIndex, int? rightIndex) onChanged;

  const WheelSelector({
    super.key,
    required this.leftItems,
    this.rightItems,
    this.initialLeftIndex = 0,
    this.initialRightIndex,
    required this.onChanged,
    this.height = 200,
    this.leftWidth = 110,
    this.rightWidth = 110,
    this.spacing = 6,
    this.looping = true,
    this.refreshRight = false,
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

  @override
  void didUpdateWidget(covariant WheelSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.refreshRight) {
      if (widget.initialLeftIndex != _leftIndex) {
        _leftIndex = widget.initialLeftIndex;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _leftController.jumpToItem(_leftIndex);
          }
        });
      }

      if (widget.rightItems != null &&
          widget.initialRightIndex != _rightIndex) {
        _rightIndex = widget.initialRightIndex;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _rightController?.jumpToItem(_rightIndex ?? 0);
          }
        });
      }
    }
  }

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
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ---------- PICKERS ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: widget.leftWidth,
                child: CupertinoPicker(
                  looping: widget.looping,
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
                SizedBox(width: widget.spacing),
                SizedBox(
                  width: widget.rightWidth,
                  child: CupertinoPicker(
                    looping: widget.looping,
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
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
