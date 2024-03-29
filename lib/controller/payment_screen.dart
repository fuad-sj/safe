import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:safe/controller/bubble_bottom_bar.dart';
import 'package:safe/controller/payments/recent_transaction_screen.dart';
import 'package:safe/controller/payments/cash_out_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as ui;

import 'payments/main_payment_screen.dart';

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

  late var paymentPages;
  late ImageIcon _teleImageIcon;

  @override
  void initState() {
    super.initState();

    _teleImageIcon = ImageIcon(AssetImage('images/telelogo.png'),
        color: Colors.blue, size: 24.0);

    paymentPages = [
      MainPaymentScreen(),
      CashOutScreen(),
      TransactionsHistoryScreen(),
    ];

    bottomIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    bool is_dark_mode = bottomIndex == 0;

    return Scaffold(
      backgroundColor: Color(is_dark_mode ? 0xff1c1c1e : 0xffffffff),
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.05,
        backgroundColor: Color(is_dark_mode ? 0xff1c1c1e : 0xffffffff),
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
              color: Color(is_dark_mode ? 0xffffffff : 0xff1c1c1e),
              fontWeight: FontWeight.w800,
              fontFamily: 'Lato',
              fontSize: 21.0,
              letterSpacing: 1),
        ),
        actions: <Widget>[],
      ),
      body: paymentPages[bottomIndex],
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        child: BubbleBottomBar(
          backgroundColor: Color(is_dark_mode ? 0xff1c1c1e : 0xffffffff),
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
                color: Color(!is_dark_mode ? 0xff1c1c1e : 0xffffffff),
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
              backgroundColor: Color(0xffDE0000),
              icon: _teleImageIcon,
              activeIcon: _teleImageIcon,
              title: Text(
                "Cash out",
                style: TextStyle(color: Colors.white),
              ),
            ),
            BubbleBottomBarItem(
              backgroundColor: Color(0xffDE0000),
              icon: Icon(
                Icons.history,
                color: Color(is_dark_mode ? 0xffffffff : 0xff1c1c1e),
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
}
