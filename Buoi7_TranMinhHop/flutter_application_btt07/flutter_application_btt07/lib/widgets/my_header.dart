import 'package:flutter/material.dart';
import 'package:flutter_application_btt07/constant.dart';
import 'package:flutter_application_btt07/info_screen.dart';
import 'package:flutter_application_btt07/main.dart';
import 'package:flutter_svg/svg.dart';

import 'counter.dart';

class MyHeader extends StatelessWidget {
  final String image;
  final String textTop;
  final String textBottom;
  final bool isActived;
  const MyHeader({
    Key? key,
    required this.image,
    required this.textTop,
    required this.textBottom,
    this.isActived = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: Container(
        padding: EdgeInsets.only(
          left: 40,
          top: 50,
          right: 20,
        ),
        height: 350,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF3383cd), Color(0xff11249f)],
          ),
          image: DecorationImage(
            image: AssetImage("assets/images/virus.png"),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                  onTap: () {
                    isActived
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return InfoScreen();
                              },
                            ),
                          )
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return HomeScreen();
                              },
                            ),
                          );
                  },
                  child: SvgPicture.asset("assets/icons/menu.svg")),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Stack(
                children: <Widget>[
                  SvgPicture.asset(
                    image,
                    width: 230,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                  ),
                  Positioned(
                    top: 20,
                    left: 150,
                    child: Text(
                      "$textTop \n$textBottom",
                      style: kHeadingTextStyle.copyWith(color: Colors.white),
                    ),
                  ),
                  Container(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
