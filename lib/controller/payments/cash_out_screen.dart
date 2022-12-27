import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:safe/controller/dialogs/cash_out_dialog.dart';
import 'package:safe/controller/dialogs/send_money_dialog.dart';
import 'package:safe/controller/graphview/GraphView.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/referral_current_balance.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as ui;

import '../dialogs/driver_not_found_dialog.dart';
import '../dialogs/ride_cancellation_dialog.dart';

class CashOutScreen extends StatefulWidget {
  const CashOutScreen({Key? key}) : super(key: key);

  @override
  _CashOutScreenState createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  StreamSubscription? _liveCurrentBalanceStream;
  ReferralCurrentBalance? _currentBalance;

  late Image _teleIcon;

  @override
  void initState() {
    super.initState();

    _teleIcon = Image(image: AssetImage('images/telelogo.png'));

    setupLivePriceStreams();
  }


  @override
  void dispose() {
    _liveCurrentBalanceStream?.cancel();
    super.dispose();
  }

  void setupLivePriceStreams() async {
    _liveCurrentBalanceStream?.cancel();

    _liveCurrentBalanceStream = FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_REFERRAL_CURRENT_BALANCE)
        .doc(PrefUtil.getCurrentUserID())
        .snapshots()
        .listen((snapshot) {
      _currentBalance = ReferralCurrentBalance.fromSnapshot(snapshot);
      if (mounted) {
        setState(() {});
      }
    });
  }

  TextStyle unSelectedTextFieldStyle() {
    return const TextStyle(
        color: Color.fromRGBO(255, 255, 255, 1),
        fontWeight: FontWeight.w700,
        fontFamily: 'Lato',
        fontSize: 14.0,
        letterSpacing: 1);
  }

  TextStyle selectedTextFieldStyle() {
    return const TextStyle(
        color: Color(0xffDE0000),
        fontWeight: FontWeight.w700,
        fontFamily: 'Lato',
        fontSize: 14.0,
        letterSpacing: 2);
  }

  LinearGradient selectedDateColorGradiant() {
    return const LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color(0xffDE0000),
        Color(0xff990000),
      ],
    );
  }

  LinearGradient unSelectedDateColorGradiant() {
    return const LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color(0xFCC0BEBE),
        Color(0xff9b9b9b),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double vHeight = MediaQuery.of(context).size.height;
    double hWidth = MediaQuery.of(context).size.width;
    return Container(
      height: vHeight * 0.75,
      width: hWidth,
      padding: EdgeInsets.only(
          top: vHeight * 0.058, left: hWidth * 0.086, right: hWidth * 0.086),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: vHeight * 0.274,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'images/safe_gray.png',
                  ),
                ),
                gradient: selectedDateColorGradiant(),
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 9,
                    offset: Offset(2, 8),
                  ),
                ]),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Current Balance',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lato',
                          letterSpacing: 2)),
                  Text(
                    _currentBalance != null ? '${AlphaNumericUtil.formatDouble(_currentBalance!.current_balance!, 2)} ETB' : '-',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 60.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lato',
                        letterSpacing: 1),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: vHeight * 0.06),
          Container(
            height: vHeight * 0.16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => cashOutDialog(),
                    );
                  },
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 30.0, child: _teleIcon),
                        SizedBox(height: 15.0),
                        Text(
                          'Cash Out',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                /*
                Padding(
                  padding:
                      EdgeInsets.only(left: hWidth * 0.1, right: hWidth * 0.1),
                  child: Container(
                    height: vHeight * 0.16,
                    width: 1.0,
                    color: Colors.black26,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => sendMoneyDialog(),
                    );
                  },
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.monetization_on_outlined,
                          color: Colors.black,
                        ),
                        SizedBox(height: 15.0),
                        Text(
                          'Send Money',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                */
              ],
            ),
          )
        ],
      ),
    );
  }
}
