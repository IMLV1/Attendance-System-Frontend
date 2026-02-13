import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloatingPopup {

  final String title;
  final Widget content;

  const FloatingPopup({this.title = 'Default Title', required this.content});

  void showPopup(BuildContext context) {

    // showCupertinoDialog(
    //   context: context,
    //   builder: (context) => CupertinoAlertDialog(
    //     title: Text('Title'),
    //     content: Text('Message'),
    //     actions: [
    //       CupertinoDialogAction(
    //         child: Text('OK'),
    //         onPressed: () => Navigator.pop(context),
    //       ),
    //     ],
    //   ),
    // );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: CupertinoColors.black.withOpacity(0.2),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        final isReversing = animation.status == AnimationStatus.reverse;

        Widget dialog = Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground
                  .resolveFrom(context),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  blurRadius: 30,
                  color: CupertinoColors.black.withOpacity(0.2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
                Row(
                  spacing: 15,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)
                          ),
                          backgroundColor: Color(0xFFD3D3D3),
                        ),
                        onPressed: () => Navigator.pop(context),

                        child: Container(
                          child: Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)
                          ),
                          backgroundColor: Color(0xFFD3D3D3),
                        ),
                        onPressed: () => Navigator.pop(context),

                        child: Container(
                          child: Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );

        // 🔥 เข้า = scale + fade
        if (!isReversing) {
          dialog = Transform.scale(
            scale: Tween(begin: 1.1, end: 1.0).evaluate(curved),
            child: Theme(
              data: Theme.of(context),
              child: dialog,
            ),
          );
        }

        // 🔥 ออก = fade อย่างเดียว
        return FadeTransition(
          opacity: curved,
          child: Theme(
            data: Theme.of(context),
            child: dialog,
          ),
        );
      },
    );
  }
}

