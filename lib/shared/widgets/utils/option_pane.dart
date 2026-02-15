import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OptionPane extends StatefulWidget{

  final String selected;
  final List<String> options;
  final BorderRadius borderRadius;
  final void Function(String)? onSelected;

  const OptionPane({
    super.key,
    this.selected = '',
    required this.options,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.onSelected
  });

  @override
  State<StatefulWidget> createState() => _OptionPaneState();
}

class _OptionPaneState extends State<OptionPane> {

  int selectedIndex = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedIndex = widget.options.indexOf(widget.selected);
  }

  @override
  Widget build(BuildContext context) {

    return SeparatorCard(
      borderRadius: widget.borderRadius,
      children: [
        ...widget.options.asMap().entries.map((entry) {
          final index = entry.key;
          final m = entry.value;

          return ElevatedButton(
            onPressed: () {
              setState(() {
                selectedIndex = index;
              });

              widget.onSelected?.call(m);
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: EdgeInsets.zero,
              shadowColor: Colors.transparent,
              backgroundColor: Color(0xFFF6F6F6),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      m,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selectedIndex == index)
                    SizedBox(
                      height: 15,
                      width: 15,
                      child: SvgPicture.asset(
                        'assets/images/check_circle.svg',
                      ),
                    ),
                ],
              ),
            ),
          );
        })
      ],

    );

  }
}