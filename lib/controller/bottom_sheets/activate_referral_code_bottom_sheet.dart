import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/controller/otp_text_field/otp_field.dart';
import 'package:safe/controller/otp_text_field/otp_field_style.dart';
import 'package:safe/controller/otp_text_field/style.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/models/customer_referral.dart';

class ActivateReferralCodeBottomSheet extends BaseBottomSheet {
  static const String KEY = 'ActivateReferralCodeBottomSheet';

  final VoidCallback onSuccessfulReferralCallback;
  final VoidCallback onReferralErrorCallback;
  final VoidCallback onAlreadyActivatedCallback;
  final VoidCallback onInvalidReferralCallback;
  static const double TOP_CORNER_BORDER_RADIUS = 25.0;

  ActivateReferralCodeBottomSheet({
    Key? key,
    required TickerProvider tickerProvider,
    required VoidCallback actionCallback,
    required bool showBottomSheet,
    required this.onSuccessfulReferralCallback,
    required this.onReferralErrorCallback,
    required this.onAlreadyActivatedCallback,
    required this.onInvalidReferralCallback,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: showBottomSheet,
          onActionCallback: actionCallback,
        );

  @override
  double bottomSheetHeight(BuildContext context) {
    double sheetHeight = MediaQuery.of(context).size.height;
    return sheetHeight;
  }

  @override
  double topCornerRadius(BuildContext context) {
    return TOP_CORNER_BORDER_RADIUS;
  }

  @override
  double bottomOffsetPercentHeight(BuildContext context) {
    return 0.25;
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

  static const REFERRAL_STATE_NOT_ENOUGH_LENGTH = 0;
  static const REFERRAL_STATE_VALID_REFERRAL = 1;
  static const REFERRAL_STATE_INVALID_REFERRAL = 2;

  RoundedLoadingButtonController _roundBtnController =
      RoundedLoadingButtonController();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _referralSubscription;

  int _getReferralState() {
    // remove any whitespace
    _referralCode = _referralCode.replaceAll(' ', '');

    if (_referralCode.length < 10) {
      return REFERRAL_STATE_NOT_ENOUGH_LENGTH;
    } else if (Customer.isReferralCodeValid(_referralCode)) {
      return REFERRAL_STATE_VALID_REFERRAL;
    } else {
      return REFERRAL_STATE_INVALID_REFERRAL;
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    double HSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.width;
    }

    double VSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.height;
    }

    int _refState = _getReferralState();
    int bkgndColorValLeft, bkgndColorValRight;

    switch (_refState) {
      case REFERRAL_STATE_NOT_ENOUGH_LENGTH:
        bkgndColorValLeft = 0xff990000;
        bkgndColorValRight = 0xffDE0000;
        break;
      case REFERRAL_STATE_VALID_REFERRAL:
        bkgndColorValLeft = 0xff009900;
        bkgndColorValRight = 0xff00DE00;
        break;
      case REFERRAL_STATE_INVALID_REFERRAL:
      default:
        bkgndColorValLeft = 0xffF0f0f0;
        bkgndColorValRight = 0xff000000;
        break;
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
                      colors: [
                        Color(bkgndColorValLeft),
                        Color(bkgndColorValRight),
                      ]),
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
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
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
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.037),
                    IgnorePointer(
                      ignoring: _refState == 0 || _refState == 2,
                      child: RoundedLoadingButton(
                        controller: RoundedLoadingButtonController(),
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.04,
                        onPressed: () async {
                          int _refState = _getReferralState();

                          switch (_refState) {
                            case REFERRAL_STATE_VALID_REFERRAL:
                              break;
                            case REFERRAL_STATE_INVALID_REFERRAL:
                              _roundBtnController.error();
                              return;
                            case REFERRAL_STATE_NOT_ENOUGH_LENGTH:
                            default:
                              _roundBtnController.reset();
                              return;
                          }

                          Map<String, dynamic> referralFields = new Map();

                          referralFields[
                                  ReferralRequest.FIELD_REFERRAL_PARENT_CODE] =
                              _referralCode.toUpperCase();
                          referralFields[
                                  ReferralRequest.FIELD_REFERRAL_CHILD_ID] =
                              FirebaseAuth.instance.currentUser!.uid;
                          referralFields[ReferralRequest.FIELD_DATE_REFERRAL] =
                              FieldValue.serverTimestamp();

                          DocumentReference<Map<String, dynamic>>?
                              _referralRequestRef = await FirebaseFirestore
                                  .instance
                                  .collection(
                                      FIRESTORE_PATHS.COL_REFERRAL_REQUEST)
                                  .add(referralFields);

                          _referralSubscription = _referralRequestRef
                              .snapshots()
                              .listen((snapshot) async {
                            // this event was generated locally, pass. we want server side responses
                            if (snapshot.metadata.hasPendingWrites) {
                              return;
                            }
                            ReferralRequest request =
                                ReferralRequest.fromSnapshot(snapshot);

                            switch (request.referral_status_code) {
                              case ReferralRequest.REFERRAL_STATUS_SUCCESSFUL:
                                _roundBtnController.success();
                                widget.onSuccessfulReferralCallback();
                                break;
                              case ReferralRequest
                                  .REFERRAL_STATUS_ALREADY_ACTIVATED:
                                _roundBtnController.success();
                                widget.onSuccessfulReferralCallback();
                                break;
                              case ReferralRequest
                                  .REFERRAL_STATUS_PARENT_DOES_NOT_EXIST:
                              case ReferralRequest
                                  .REFERRAL_STATUS_CHILD_DOES_NOT_EXIST:
                              case ReferralRequest
                                  .REFERRAL_STATUS_UNKNOWN_ERROR:
                                {
                                  _roundBtnController.error();
                                  Future.delayed(Duration(seconds: 3), () {
                                    _roundBtnController.reset();
                                  });

                                  String errMsg;

                                  if (request.referral_status_code ==
                                      ReferralRequest
                                          .REFERRAL_STATUS_PARENT_DOES_NOT_EXIST) {
                                    errMsg =
                                        "Invalid Referral, \n$_referralCode";
                                    widget.onInvalidReferralCallback();
                                  } else {
                                    errMsg = "Error, please try again";
                                    widget.onReferralErrorCallback();
                                  }

                                  Fluttertoast.showToast(
                                    msg: errMsg,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.grey.shade700,
                                    textColor: Colors.white,
                                    fontSize: 18.0,
                                  );
                                  break;
                                }
                            }
                            _referralSubscription?.cancel();
                          });
                        },
                        child: Text(
                          'SUBMIT',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: _refState == REFERRAL_STATE_NOT_ENOUGH_LENGTH
                            ? Colors.red.shade800
                            : (_refState == REFERRAL_STATE_VALID_REFERRAL
                                ? Colors.green.shade800
                                : Colors.red.shade800),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                        'Enter the 10 digit referral code you have received from your Safe friend.'
                        'Please note that this code is to be sent from a previous user of the SAFE APP.',
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
