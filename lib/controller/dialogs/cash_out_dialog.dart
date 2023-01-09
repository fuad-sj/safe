import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
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

class CashOutDialog extends StatefulWidget {
  late Customer currentCustomer;
  late ReferralCurrentBalance currentBalance;

  CashOutDialog(
      {Key? key, required this.currentCustomer, required this.currentBalance})
      : super(key: key);

  @override
  _CashOutDialogState createState() => _CashOutDialogState();
}

class _CashOutDialogState extends State<CashOutDialog> {
  TextEditingController amountController = TextEditingController();

  late Image _teleIcon;
  double _cashoutAmount = -1;

  @override
  void initState() {
    super.initState();

    _teleIcon =
        Image(image: AssetImage('images/telelogo.png'), color: Colors.white);

    amountController.addListener(() {
      double amount = AlphaNumericUtil.parseDouble(amountController.text);

      setCashoutAmount(amount);
    });
  }

  List<double> possibleCashoutAmounts = [
    100,
    150,
    200,
    250,
    300,
    500,
    1000,
    1500,
  ];

  void setCashoutAmount(double amount) {
    _cashoutAmount = min(amount, widget.currentBalance.current_balance!);

    String str_amt = AlphaNumericUtil.formatDouble(_cashoutAmount, 0);
    amountController.value = TextEditingValue(
      text: str_amt,
      selection: TextSelection.collapsed(offset: str_amt.length),
    );
    setState(() {});
  }

  bool disableCashoutBtn() {
    return _cashoutAmount <= 0;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double HORIZONTAL_PADDING = 15.0;

    return Dialog(
      elevation: 2.0,
      insetPadding: EdgeInsets.symmetric(horizontal: screenHeight * 0.034),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dialog Header
          Container(
            height: screenHeight * 0.086,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xffDE0000),
                    Color(0xff990000),
                  ],
                ),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: screenWidth * 0.044),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context, true);
                    },
                    child: Icon(
                      Icons.close,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                ),
                Spacer(flex: 1),
                Container(
                  padding: EdgeInsets.only(left: screenWidth * 0.044),
                  child: Text(
                    "Cash out",
                    style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                ),
                Spacer(flex: 2),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.045),

          Center(
            child: Container(
              width: screenWidth * 0.70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'Amount',
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(43, 47, 45, 1)),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.025),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.045,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(225, 224, 223, 1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: screenWidth * 0.025),
                          Expanded(
                            child: TextField(
                              controller: amountController,
                              expands: true,
                              maxLines: null,
                              minLines: null,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                              keyboardType: TextInputType.numberWithOptions(signed:false , decimal: true),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '200',
                                hintStyle: TextStyle(color: Colors.grey),
                                fillColor: Colors.black,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.040),
          Container(
            height: screenHeight * 0.040,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: possibleCashoutAmounts.map((cashoutAmount) {
                return InkWell(
                  onTap: () {
                    setCashoutAmount(cashoutAmount);
                    setState(() {});
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 10, left: 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Color(0xffDE0000),
                            Color(0xff990000),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${AlphaNumericUtil.formatDouble(cashoutAmount, 2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: screenHeight * 0.040),

          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                if (disableCashoutBtn()) {
                  return;
                }
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return FutureProgressDialog(
                        Future(() async {
                          await createCashoutRequest();
                          await Future.delayed(Duration(seconds: 2));

                          if (mounted) {
                            Navigator.pop(
                                context); // pop-off this page to go back to wallet overview
                          }
                        }),
                        message: Text("Cash-out, Please Wait..."),
                      );
                    });
              },
              child: Container(
                width: screenWidth * 0.46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      disableCashoutBtn()
                          ? Colors.grey.shade500
                          : Color(0xffDE0000),
                      disableCashoutBtn()
                          ? Colors.grey.shade500
                          : Color(0xff990000),
                    ],
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(width: 25.0, child: _teleIcon),
                      SizedBox(width: 15.0),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Lato',
                              letterSpacing: 1),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Done Trip
          SizedBox(height: screenHeight * 0.040),
        ],
      ),
    );
  }

  Future<void> createCashoutRequest() async {
    if (disableCashoutBtn()) return;

    Map<String, dynamic> requestFields = new Map();

    requestFields[ReferralPaymentRequest.FIELD_CLIENT_TRIGGERED_EVENT] = true;
    requestFields[ReferralPaymentRequest.FIELD_REQUEST_STATUS] =
        ReferralPaymentRequest.REQUEST_STATUS_CREATED;
    requestFields[ReferralPaymentRequest.FIELD_REQUEST_TYPE] =
        ReferralPaymentRequest.PAYMENT_REQUEST_TYPE_CASH_OUT;
    requestFields[ReferralPaymentRequest.FIELD_PAYMENT_AMOUNT] = _cashoutAmount;
    requestFields[ReferralPaymentRequest.FIELD_REQUESTER_ID] =
        PrefUtil.getCurrentUserID();
    requestFields[ReferralPaymentRequest.FIELD_REQUESTER_NAME] =
        widget.currentCustomer.user_name;
    requestFields[ReferralPaymentRequest.FIELD_REQUESTER_PHONE] =
        await PrefUtil.getCurrentUserPhone();
    requestFields[ReferralPaymentRequest.FIELD_REQUESTED_TIME] =
        FieldValue.serverTimestamp();

    await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_REFERRAL_PAYMENT_REQUESTS)
        .add(requestFields);
  }
}
