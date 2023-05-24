//import 'dart:html';

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/otp_text_field/otp_field.dart';
import 'package:safe/controller/otp_text_field/otp_field_style.dart';
import 'package:safe/controller/otp_text_field/style.dart';
import 'package:safe/controller/registration_screen.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/models/safe_otp_request.dart';
import 'package:safe/utils/http_util.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'login_page.dart';

class VerifyOTP extends StatefulWidget {
  final String otpID;
  final String instNo;

  VerifyOTP({required this.otpID, required this.instNo});

  @override
  _VerifyOTPState createState() => _VerifyOTPState();
}

class _VerifyOTPState extends State<VerifyOTP> {
  static const int OTP_LENGTH = 4;

  String _otpCode = "";

  final RoundedLoadingButtonController _verificationBtnController =
      RoundedLoadingButtonController();

  Timer? _otpStatusTimer;
  bool _isOnPingRequest = false;

  @override
  void initState() {
    super.initState();

    _subscribeToOTPStateChange();
  }

  @override
  void didUpdateWidget(VerifyOTP oldWidget) {
    super.didUpdateWidget(oldWidget);

    _subscribeToOTPStateChange();
  }

  void _subscribeToOTPStateChange() async {
    _otpStatusTimer?.cancel();
    _otpStatusTimer = new Timer.periodic(
      Duration(seconds: 2),
      (timer) async {
        if (_isOnPingRequest) {
          return;
        }

        _isOnPingRequest = true;

        bool retry_request = true;
        var statusResponse;

        while (retry_request) {
          try {
            statusResponse = await HttpUtil.getHttpsRequest(
                "us-central1-safetransports-et.cloudfunctions.net",
                "/OTPEndpoint${widget.instNo}/api/v1/otp_status", {
              "otp_id": widget.otpID,
            });
            retry_request = false;
          } catch (err) {
            retry_request = true;
          }
        }
        _isOnPingRequest = false;

        bool expired = statusResponse["expired"];

        if (expired) {
          _otpStatusTimer?.cancel();
          displayToastMessage('OTP Expired, Please Try Again', context);
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  void dispose() {
    _otpStatusTimer?.cancel();
    super.dispose();
  }

  bool isValidOTP() {
    return _otpCode.length == OTP_LENGTH && _otpCode.trim() != "9981";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topRight,
                      colors: [
                        Color(0xff990000),
                        Color(0xffDE0000),
                      ]),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(
                          MediaQuery.of(context).size.width * 0.5,
                          MediaQuery.of(context).size.height * 0.125),
                      bottomRight: Radius.elliptical(
                          MediaQuery.of(context).size.width * 0.5,
                          MediaQuery.of(context).size.height * 0.125))),
              child: Stack(children: <Widget>[
                Positioned(
                    top: MediaQuery.of(context).size.height * 0.06,
                    left: 22.0,
                    child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_sharp),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const LoginPage()));
                        })),
                Center(
                    child: Image(
                  image: AssetImage('images/white_logo.png'),
                  height: MediaQuery.of(context).size.height * 0.120,
                )),
              ])),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 5.0),
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                    child: Text(
                      "Enter OTP",
                      style: TextStyle(
                          color: Color(0xff000000), fontFamily: 'Open Sans'),
                    )),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.07),
                  child: PinFieldAutoFill(
                    decoration: CirclePinDecoration(
                      strokeWidth: 1.5,
                      strokeColorBuilder: PinListenColorBuilder(
                          Color(0xff990000), Color(0xff990000)),
                      bgColorBuilder: PinListenColorBuilder(
                          Colors.white, Colors.white.withOpacity(0.9)),
                    ),
                    onCodeChanged: (code) async {
                      if (mounted) {
                        setState(() {
                          _otpCode = code;
                          if (_otpCode.trim().length == OTP_LENGTH) {
                            _verificationBtnController.start();
                          }
                        });
                      }
                    },
                    codeLength: OTP_LENGTH,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.04),
                    child: Container(
                        height: MediaQuery.of(context).size.height * 0.06,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomRight,
                                end: Alignment.topRight,
                                colors: [
                                  Color(0xff990000),
                                  Color(0xffDE0000),
                                ]),
                            borderRadius: BorderRadius.circular(25.0)),
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (_otpCode.trim() == "9981") {
                              displayToastMessage('9981 is not Valid', context);
                            }
                          },
                          child: IgnorePointer(
                              ignoring: !isValidOTP(),
                              child: RoundedLoadingButton(
                                  color: !isValidOTP()
                                      ? Color(0xffDE0000)
                                      : Colors.white.withOpacity(0.1),
                                  child: Text('DONE'),
                                  controller: _verificationBtnController,
                                  onPressed: () async {
                                    verifyOTPRequest(context);
                                  })),
                        ))),
              ],
            ),
          )
        ],
      )),
    );
  }

  Future<void> verifyOTPRequest(BuildContext context) async {
    try {
      Map<String, dynamic> params = {
        "otp_id": widget.otpID,
        "otp_code": _otpCode,
      };
      var response = await HttpUtil.getHttpsRequest(
          "us-central1-safetransports-et.cloudfunctions.net",
          "/OTPEndpoint${widget.instNo}/api/v1/verify_otp",
          params);

      bool success = response["success"];
      if (!success) {
        int otp_error = response["otp_error"];
        if (otp_error == SafeOTPRequest.SAFE_OTP_ERROR_INVALID_STATE) {
          displayToastMessage('OTP Expired, Please Try Again', context);
          Navigator.pop(context);
        } else {
          displayToastMessage('Wrong OTP Code, Please Try Again', context);
          _verificationBtnController.reset();
        }
      }

      _otpStatusTimer?.cancel();

      String custom_token = response["token"];

      UserCredential credential =
          await FirebaseAuth.instance.signInWithCustomToken(custom_token);
      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        displayToastMessage('Error Authenticating, Please Try Again', context);
        _verificationBtnController.reset();
        return;
      }

      await PrefUtil.setLoginStatus(PrefUtil.LOGIN_STATUS_LOGIN_JUST_NOW);

      Customer customer = Customer.fromSnapshot(
        await FirebaseFirestore.instance
            .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
            .doc(firebaseUser.uid)
            .get(),
      );

      Navigator.pushNamedAndRemoveUntil(
          context,
          customer.documentExists() && customer.accountFullyCreated()
              ? MainScreenCustomer.idScreen
              : RegistrationScreen.idScreen,
          (route) => false);
    } catch (err) {
      _verificationBtnController.reset();
      displayToastMessage('Login error, please try again', context);
    }
  }
}
