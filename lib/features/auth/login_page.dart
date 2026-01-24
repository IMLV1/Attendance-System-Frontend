import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatelessWidget {

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(

              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 500,
                  ),

                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final currentWidth = constraints.maxWidth;

                      return SizedBox(
                          height: currentWidth * (238.0 / 362.0),
                          width: double.infinity,

                          child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .cardColor,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Text('เข้าสู่ระบบ'),

                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(
                                          double.infinity, 0),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                    child: Row(
                                      spacing: 12,
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/google_logo.svg',
                                          width: 20,
                                          height: 20,
                                        ),
                                        Text('Login with Google')
                                      ],
                                    ),
                                    onPressed: () {
                                      print('i sus');
                                    },
                                  ),
                                ],
                              )
                          )
                      );
                    },
                  )
              )
          ),
        )
    );
  }
}
