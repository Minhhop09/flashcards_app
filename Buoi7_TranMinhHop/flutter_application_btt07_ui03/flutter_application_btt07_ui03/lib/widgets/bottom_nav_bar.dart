import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_btt07_ui03/constants.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    required Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      height: 80,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          BottomNavItem(
            key: Key("today"),
            title: "Today",
            svgScr: "assets/icons/calendar.svg",
            press: () {
              // Add your onTap functionality here
            },
          ),
          BottomNavItem(
            key: Key("all_exercises"),
            title: "All Exercises",
            svgScr: "assets/icons/gym.svg",
            isActive: true,
            press: () {
              // Add your onTap functionality here
            },
          ),
          BottomNavItem(
            key: Key("settings"),
            title: "Settings",
            svgScr: "assets/icons/Settings.svg",
            press: () {
              // Add your onTap functionality here
            },
          ),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final String svgScr;
  final String title;
  final VoidCallback press;
  final bool isActive;
  const BottomNavItem({
    required Key key,
    required this.svgScr,
    required this.title,
    required this.press,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SvgPicture.asset(
            svgScr,
            color: isActive ? kActiveIconColor : kTextColor,
          ),
          Text(
            title,
            style: TextStyle(color: isActive ? kActiveIconColor : kTextColor),
          ),
        ],
      ),
    );
  }
}
