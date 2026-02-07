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
        ...widget.options.map((m) {
          return ElevatedButton(

              onPressed: () {
                setState(() {
                  selectedIndex = widget.options.indexOf(m);
                });

                if (widget.onSelected != null) widget.onSelected!(m);
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.all(0),
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
              ),

              child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Text(
                          m,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black
                          )
                      ),
                      Spacer(),
                      if (selectedIndex >= 0 && selectedIndex < widget.options.length &&  widget.options[selectedIndex] == m) SizedBox(
                          height: 15,
                          width: 15,
                          child: SvgPicture.asset(
                            'assets/images/check_circle.svg',
                          )
                      ),
                    ],
                  )
              )
          );
        })
      ],
    );

  }
}