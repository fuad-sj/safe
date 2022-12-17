import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:safe/controller/recent_transaction_screen.dart';
import 'package:safe/controller/send_money_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:safe/controller/graphview/GraphView.dart';
import 'dart:ui' as ui;

import 'main_payment_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late int bottomIndex;

  void changeScreenPayment(int? index) {
    setState(() {
      bottomIndex = index!;
    });
  }

  var paymentPages = [
    homePage(),
    sendMoneyScreen(),
    RecentTransactionsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    bottomIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(bottomIndex == 0 ? 0xff1c1c1e : 0xffffffff),
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.05,
        backgroundColor: Color(bottomIndex == 0 ? 0xff1c1c1e : 0xffffffff),
        elevation: 0.0,
        leading: MaterialButton(
          elevation: 6.0,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xffDD0000),
          ),
          shape: CircleBorder(),
        ),
        centerTitle: true,
        title: Text(
          'Payments',
          style: TextStyle(
              color: Color(bottomIndex == 0 ? 0xffffffff : 0xff1c1c1e),
              fontWeight: FontWeight.w800,
              fontFamily: 'Lato',
              fontSize: 21.0,
              letterSpacing: 1),
        ),
        actions: <Widget>[],
      ),
      body: paymentPages[bottomIndex],
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.05,
        child: BubbleBottomBar(
          backgroundColor: Color(bottomIndex == 0 ? 0xff1c1c1e : 0xffffffff),
          opacity: 1.0,
          hasNotch: true,
          currentIndex: bottomIndex,
          onTap: changeScreenPayment,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(
              backgroundColor: Color(0xffDE0000),
              icon: Icon(
                Icons.home,
                color: Color(bottomIndex == 0 ? 0xffffffff : 0xff1c1c1e),
              ),
              activeIcon: Icon(
                Icons.home,
                color: Colors.white,
              ),
              title: Text(
                "Home",
                style: TextStyle(color: Colors.white),
              ),
            ),
            BubbleBottomBarItem(
              showBadge: true,
              badge: Text("5"),
              badgeColor: Colors.green,
              backgroundColor: Color(0xffDE0000),
              icon: Icon(Icons.monetization_on,
                  color: Color(bottomIndex == 0 ? 0xffffffff : 0xff1c1c1e)),
              activeIcon: Icon(
                Icons.monetization_on_outlined,
                color: Colors.white,
              ),
              title: Text(
                "Cash out",
                style: TextStyle(color: Colors.white),
              ),
            ),
            BubbleBottomBarItem(
              backgroundColor: Color(0xffDE0000),
              icon: Icon(
                Icons.history,
                color: Color(bottomIndex == 0 ? 0xffffffff : 0xff1c1c1e),
              ),
              activeIcon: Icon(
                Icons.history,
                color: Colors.white,
              ),
              title: Text(
                "Recent",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Random r = Random();

  Widget rectangleWidget(int? a) {
    return Container(
        width: 100,
        height: 50,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.blue[100]!, spreadRadius: 1),
          ],
        ),
        child: Text('Node ${a}'));
  }
}

class DateOfEarning {
  DateOfEarning(this.date);

  final String date;
}

class CustomTotalPriceClipPath extends CustomClipper<Path> {
  var radius = 100.0;

  @override
  Path getClip(Size size) {
    Path path0 = Path();
    path0.moveTo(size.width * 0.001, size.height * 0.200);
    path0.lineTo(size.width * 0.448, size.height * 0.204);
    path0.lineTo(size.width * 0.500, size.height * 0.002);
    path0.lineTo(size.width * 0.55075, size.height * 0.19892);
    path0.lineTo(size.width * 0.999, size.height * 0.200);
    path0.lineTo(size.width * 0.997, size.height * 0.994);
    path0.lineTo(size.width * 0.001, size.height * 0.996);
    path0.lineTo(size.width * 0.001, size.height * 0.200);
    path0.close();

    return path0;
    throw UnimplementedError();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
