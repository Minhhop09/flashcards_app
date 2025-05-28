import 'package:flutter/material.dart';
import 'package:flutter_application_btt07/constant.dart';
import 'package:flutter_application_btt07/widgets/my_header.dart';
import 'package:flutter_svg/svg.dart';
import 'widgets/counter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Covid 19 - Trần Minh Hợp 1050080180',
      theme: ThemeData(
          scaffoldBackgroundColor: kBackgroundColor,
          fontFamily: "Poppins",
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: kBodyTextColor),
          )),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            MyHeader(
              image: "assets/icons/Drcorona.svg",
              textTop: "All you need",
              textBottom: "is stay at home",
              isActived: true,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFFe5e5e5),
                ),
              ),
              child: Row(
                children: <Widget>[
                  SvgPicture.asset("assets/icons/maps-and-flags.svg"),
                  Expanded(
                    child: DropdownButton(
                      isExpanded: true,
                      underline: SizedBox(),
                      icon: SvgPicture.asset("assets/icons/dropdown.svg"),
                      value: "Indonesia",
                      items: ['Indonesia', 'Bangladesh', 'United States', 'Japan']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {},
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Kasus Terbaru\n",
                              style: kTitleTextStyle,
                            ),
                            TextSpan(
                              text: "Berita terbaru 25 April 2022",
                              style: TextStyle(color: kTitleTextColor),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Lihat detail",
                        style: TextStyle(
                            color: kPrimaryColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 30,
                            color: kShadowColor),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const <Widget>[
                        Counter(
                          color: kInfectedColor,
                          number: 6044150,
                          title: "Terkonfirmasi",
                        ),
                        Counter(
                          color: kDeathColor,
                          number: 156100,
                          title: "Meninggal",
                        ),
                        Counter(
                          color: kRecoverColor,
                          number: 5870419,
                          title: "Sembuh",
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const <Widget>[
                      Text(
                        "Peta sebaran virus",
                        style: kTitleTextStyle,
                      ),
                      Text(
                        "Lihat detail",
                        style: TextStyle(
                            color: kPrimaryColor, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.all(20),
                    height: 178,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            offset: const Offset(0, 10),
                            blurRadius: 30,
                            color: kShadowColor),
                      ],
                    ),
                    child: Image.asset(
                      "assets/images/map.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
