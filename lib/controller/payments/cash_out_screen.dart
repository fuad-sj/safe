import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safe/controller/dialogs/cash_out_dialog.dart';
import 'package:safe/controller/dialogs/send_money_dialog.dart';
import 'package:safe/controller/graphview/GraphView.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/models/referral_current_balance.dart';
import 'package:safe/models/referral_payment_request.dart';
import 'package:safe/models/sys_config.dart';
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
  StreamSubscription? _liveSysConfigStream;
  ReferralCurrentBalance? _currentBalance;

  late Image _teleIcon;
  SysConfig? _sysConfig;
  Customer? _currentCustomer;

  @override
  void initState() {
    super.initState();

    _teleIcon =
        Image(image: AssetImage('images/telelogo.png'), color: Colors.white);

    setupLivePriceStreams();

    Future.delayed(Duration.zero, () async {
      _currentCustomer = Customer.fromSnapshot(await FirebaseFirestore.instance
          .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get());
      if (!(_currentCustomer?.documentExists() ?? false)) {
        _currentCustomer = null;
      }
    });
  }

  @override
  void dispose() {
    _liveCurrentBalanceStream?.cancel();
    _liveSysConfigStream?.cancel();
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

    _liveSysConfigStream = FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_CONFIG)
        .doc(FIRESTORE_PATHS.DOC_CONFIG)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        _sysConfig = null;
      } else {
        _sysConfig = SysConfig.fromSnapshot(snapshot);
      }

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

  bool hasSufficientCashoutBalance() {
    if (_currentCustomer == null ||
        _sysConfig == null ||
        _currentBalance == null) return false;
    return _currentBalance!.current_balance! >=
        _sysConfig!.customer_cashout_min_balance!;
  }

  @override
  Widget build(BuildContext context) {
    double vHeight = MediaQuery.of(context).size.height;
    double hWidth = MediaQuery.of(context).size.width;

    String str_current_balance = "";
    double fontSize = 50.0;
    if (_currentBalance != null) {
      str_current_balance =
          AlphaNumericUtil.formatDouble(_currentBalance!.current_balance!, 2);

      double log10(num x) => log(x) / ln10;

      int numDigits = _currentBalance!.current_balance! <= 0
          ? 1
          : log10(_currentBalance!.current_balance!).floor() + 1;

      if (numDigits >= 4) fontSize = 40.0;
    }

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
                    _currentBalance != null ? '$str_current_balance ETB' : '-',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
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
            //height: vHeight * 0.16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    if (!hasSufficientCashoutBalance()) {
                      Fluttertoast.showToast(
                        msg: "Your balance is insufficient to cash out",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey.shade700,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else {
                      await showDialog(
                        context: context,
                        builder: (_) => CashOutDialog(
                            currentCustomer: _currentCustomer!,
                            currentBalance: _currentBalance!),
                      );
                    }
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: hasSufficientCashoutBalance()
                                ? Colors.green
                                : Colors.grey,
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(2, 8),
                          ),
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 30.0, child: _teleIcon),
                        SizedBox(height: 15.0),
                        Text(
                          'Cash Out',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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
