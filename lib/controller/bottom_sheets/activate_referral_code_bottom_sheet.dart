import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:safe/controller/otp_text_field/otp_field.dart';
import 'package:safe/controller/otp_text_field/style.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/models/customer_referral.dart';

class ActivateReferralCodeBottomSheet extends StatefulWidget {
  static const String KEY = 'ActivateReferralCodeBottomSheet';

  final VoidCallback onSuccessfulReferralCallback;
  final VoidCallback onReferralErrorCallback;
  final VoidCallback onAlreadyActivatedCallback;
  final VoidCallback onInvalidReferralCallback;

  ActivateReferralCodeBottomSheet({
    Key? key,
    required this.onSuccessfulReferralCallback,
    required this.onReferralErrorCallback,
    required this.onAlreadyActivatedCallback,
    required this.onInvalidReferralCallback,
  }) : super(key: key);

  @override
  _ActivateReferralCodeBottomSheetState createState() =>
      _ActivateReferralCodeBottomSheetState();
}

class _ActivateReferralCodeBottomSheetState
    extends State<ActivateReferralCodeBottomSheet> {
  String _referralCode = "";

  static const REFERRAL_STATE_NOT_ENOUGH_LENGTH = 0;
  static const REFERRAL_STATE_VALID_REFERRAL = 1;
  static const REFERRAL_STATE_INVALID_REFERRAL = 2;

  RoundedLoadingButtonController _roundBtnController =
      RoundedLoadingButtonController();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _referralSubscription;

  int _getReferralState() {
    if (_referralCode.length < 10) {
      return REFERRAL_STATE_NOT_ENOUGH_LENGTH;
    } else if (Customer.isReferralCodeValid(_referralCode)) {
      return REFERRAL_STATE_VALID_REFERRAL;
    } else {
      return REFERRAL_STATE_INVALID_REFERRAL;
    }
  }

  @override
  Widget build(BuildContext context) {
    double HSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.width;
    }

    double VSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.height;
    }

    int _refState = _getReferralState();

    return Positioned(
      left: HSpace(0.005),
      right: HSpace(0.005),
      top: VSpace(0.35),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: HSpace(0.025)),
        padding: EdgeInsets.symmetric(horizontal: HSpace(0.05)),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.all(
              Radius.circular(min(HSpace(0.06), VSpace(0.06)))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: Container(
                    margin: EdgeInsets.only(top: VSpace(0.005)),
                    width: 30.0,
                    height: 2.0,
                    color: Colors.grey.shade700)),
            SizedBox(height: VSpace(0.024)),
            //
            OTPTextField(
              length: 10,
              width: MediaQuery.of(context).size.width,
              textFieldAlignment: MainAxisAlignment.spaceAround,
              fieldWidth: 28,
              fieldStyle: FieldStyle.underline,
              outlineBorderRadius: 8,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            SizedBox(height: VSpace(0.015)),
            IgnorePointer(
              ignoring: _refState != REFERRAL_STATE_VALID_REFERRAL,
              child: RoundedLoadingButton(
                controller: _roundBtnController,
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

                  referralFields[ReferralRequest.FIELD_REFERRAL_PARENT_CODE] =
                      _referralCode.toUpperCase();
                  referralFields[ReferralRequest.FIELD_REFERRAL_CHILD_ID] =
                      FirebaseAuth.instance.currentUser!.uid;
                  referralFields[ReferralRequest.FIELD_DATE_REFERRAL] =
                      FieldValue.serverTimestamp();

                  DocumentReference<Map<String, dynamic>>? _referralRequestRef =
                      await FirebaseFirestore.instance
                          .collection(FIRESTORE_PATHS.COL_REFERRAL_REQUEST)
                          .add(referralFields);

                  _referralSubscription =
                      _referralRequestRef.snapshots().listen((snapshot) async {
                    ReferralRequest request =
                        ReferralRequest.fromSnapshot(snapshot);

                    if (request.referral_status_code ==
                        null) // this is fired b/c we created a doc ourselves, wait for the server to respond
                      return;

                    switch (request.referral_status_code) {
                      case ReferralRequest.REFERRAL_STATUS_SUCCESSFUL:
                        _roundBtnController.success();
                        widget.onSuccessfulReferralCallback();
                        break;
                      case ReferralRequest.REFERRAL_STATUS_ALREADY_ACTIVATED:
                        _roundBtnController.success();
                        widget.onAlreadyActivatedCallback();
                        break;
                      case ReferralRequest
                          .REFERRAL_STATUS_PARENT_DOES_NOT_EXIST:
                      case ReferralRequest.REFERRAL_STATUS_CHILD_DOES_NOT_EXIST:
                      case ReferralRequest.REFERRAL_STATUS_UNKNOWN_ERROR:
                        _roundBtnController.error();
                        Future.delayed(Duration(seconds: 3), () {
                          _roundBtnController.reset();
                        });
                        widget.onReferralErrorCallback();
                        break;
                    }
                    _referralSubscription?.cancel();
                  });
                },
                child: Text(
                  'VERIFY',
                  style: TextStyle(color: Colors.white),
                ),
                errorColor: Colors.red.shade800,
                successColor: Colors.green.shade800,
                color: (_refState == REFERRAL_STATE_VALID_REFERRAL
                    ? Colors.green.shade800
                    : (_refState == REFERRAL_STATE_INVALID_REFERRAL
                        ? Colors.red.shade800
                        : Colors.blue.shade800)),
              ),
            ),
            SizedBox(height: VSpace(0.02)),
          ],
        ),
      ),
    );
  }
}
