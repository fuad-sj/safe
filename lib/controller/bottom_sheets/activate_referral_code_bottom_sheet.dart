import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/controller/otp_text_field/otp_field.dart';
import 'package:safe/controller/otp_text_field/otp_field_style.dart';
import 'package:safe/controller/otp_text_field/style.dart';
import 'package:safe/models/color_constants.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class ActivateReferralCodeBottomSheet extends BaseBottomSheet {
  static const String KEY = 'WhereToBottomSheet';

  static const double TOP_CORNER_BORDER_RADIUS = 25.0;

  ActivateReferralCodeBottomSheet({
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback actionCallback,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: showBottomSheet,
          onActionCallback: actionCallback,
        );


  @override
  double bottomSheetHeight(BuildContext context) {
    double sheetHeight =
        MediaQuery.of(context).size.height ;
    return sheetHeight;
  }



  @override
  double topCornerRadius(BuildContext context) {
    return TOP_CORNER_BORDER_RADIUS;
  }

  @override
  double bottomOffset(BuildContext context) {
    return 0.20;
  }

  @override
  double horizontalRightOffset(BuildContext context) {
    return 0.02;
  }

  @override
  double horizontalLeftOffset(BuildContext context) {
    return 0.02;
  }

  @override
  bool showBoxShadow(BuildContext context) {
    return false;
  }

  @override
  State<StatefulWidget> buildState() {
    return new _ActivateReferralCodeBottomSheetState();
  }
}

class _ActivateReferralCodeBottomSheetState
    extends State<ActivateReferralCodeBottomSheet>
    implements BottomSheetWidgetBuilder {
  String _referralCode = "";

  @override
  Widget buildContent(BuildContext context) {
    double HSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.width;
    }

    double VSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.height;
    }



    int _refState = -1;
    int bkgndColorValLeft, bkgndColorValRight;

    if (_referralCode.length < 10) {
      _refState = 0;
      bkgndColorValLeft = 0xff990000;
      bkgndColorValRight = 0xffDE0000;
    } else if (Customer.isReferralCodeValid(_referralCode)) {
      _refState = 1;
      bkgndColorValLeft = 0xff009900;
      bkgndColorValRight = 0xff00DE00;
    } else {
      _refState = 2;
      bkgndColorValLeft = 0xffF0f0f0;
      bkgndColorValRight = 0xff000000;
    }

    return Padding(
        padding: EdgeInsets.only(),
        child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.367,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0)),
                    gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topRight,
                        colors:  [Color(bkgndColorValLeft), Color(bkgndColorValRight),]),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.027),
                            child: Text('Referral Code',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16.0,
                                    fontFamily: 'Lato')),
                          )),
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("images/referal.png"),
                              fit: BoxFit.cover),
                        ),
                        height: MediaQuery.of(context).size.height * 0.297,
                      )
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.260,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25.0),
                        bottomRight: Radius.circular(25.0),
                      ),
                      color: Colors.white),
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.037),
                      Container(
                        child: FocusScope(
                          child: Focus(
                            child: OTPTextField(
                              length: 10,
                              width: MediaQuery.of(context).size.width,
                              textFieldAlignment: MainAxisAlignment.spaceAround,
                              fieldWidth: 28,
                              fieldStyle: FieldStyle.box,
                              outlineBorderRadius: 10,
                              otpFieldStyle: OtpFieldStyle(
                                borderColor: Color(0xff990000),
                                focusBorderColor: Color(0xffDE0000),
                                enabledBorderColor: Color(0xff990000),
                              ),

                              style:
                              TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              keyboardType: TextInputType.text,
                              onChanged: (val) {
                                setState(() {
                                  _referralCode = val;
                                });
                              },
                              onCompleted: (val) {
                                setState(() {
                                  _referralCode = val;
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height * 0.037),
                      IgnorePointer(
                        ignoring: _refState == 0 || _refState == 2,
                        child: RoundedLoadingButton(
                          controller: RoundedLoadingButtonController(),
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: MediaQuery.of(context).size.height * 0.04,
                          onPressed: () async {},
                          child: Text(
                            'SUBMIT',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: _refState == 0
                              ? Colors.red.shade800
                              : (_refState == 1
                              ? Colors.green.shade800
                              : Colors.red.shade800),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Padding(padding: EdgeInsets.only(left: 20.0 , right: 20.0 ),
                        child: Text(
                          'Enter the 10 digit referral code you have received from your Safe friend.'
                              ' Please note that this code is to be sent from a previous user of the SAFE APP.',
                          style: TextStyle(
                            fontSize: 10.0,
                            fontFamily: 'Lato',
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return widget.wrapContent(context, buildContent);
  }
}
