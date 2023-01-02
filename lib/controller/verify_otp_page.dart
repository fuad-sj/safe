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

import 'login_page.dart';

class VerifyOTP extends StatefulWidget {
  final String otpID;
  final String instNo;

  VerifyOTP({required this.otpID, required this.instNo});

  @override
  _VerifyOTPState createState() => _VerifyOTPState();
}

class _VerifyOTPState extends State<VerifyOTP> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _otpSubscription;

  static const int OTP_LENGTH = 4;

  String _otpCode = "";

  final RoundedLoadingButtonController _verificationBtnController =
      RoundedLoadingButtonController();

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
    _otpSubscription?.cancel();
    _otpSubscription?.cancel();
    _otpSubscription = FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_OTP_REQUESTS)
        .doc(widget.otpID)
        .snapshots()
        .listen((snapshot) {
      SafeOTPRequest otpRequest = SafeOTPRequest.fromSnapshot(snapshot);

      switch (otpRequest.otp_status) {
        case SafeOTPRequest.SAFE_OTP_STATUS_OTP_EXPIRED:
          displayToastMessage('OTP Expired, Please Try Again', context);
          Navigator.pop(context);
          break;
      }
    });
  }

  @override
  void dispose() {
    _otpSubscription?.cancel();
    super.dispose();
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
                OTPTextField(
                  length: OTP_LENGTH,
                  width: MediaQuery.of(context).size.width,
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldWidth: 50,
                  fieldStyle: FieldStyle.box,
                  otpFieldStyle: OtpFieldStyle(
                    focusBorderColor: Color(0xff990000),
                    borderColor: Color(0xffDE0000),
                  ),
                  outlineBorderRadius: 15,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.number,
                  onCompleted: (pin) {
                    //    print("Completed: " + pin);
                    setState(() {
                      _otpCode = pin;
                    });
                  },
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
                        child: IgnorePointer(
                            ignoring: _otpCode.length != OTP_LENGTH,
                            child: RoundedLoadingButton(
                                color: (_otpCode.length != OTP_LENGTH)
                                    ? Color(0xffDE0000)
                                    : Colors.white.withOpacity(0.1),
                                child: Text('DONE'),
                                controller: _verificationBtnController,
                                onPressed: () async {
                                  verifyOTPRequest(context);
                                })))),
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
        }
      }

      String custom_token = response["token"];

      UserCredential credential =
          await FirebaseAuth.instance.signInWithCustomToken(custom_token);
      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        displayToastMessage('Error Authenticating, Please Try Again', context);
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
      displayToastMessage('Login error, please try again', context);
    }
  }
}
