//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:safe/auth_service.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/otp_text_field/otp_field.dart';
import 'package:safe/controller/otp_text_field/otp_field_style.dart';
import 'package:safe/controller/otp_text_field/style.dart';
import 'package:safe/controller/registration_screen.dart';

import 'login_page.dart';

class VerifyPhone extends StatefulWidget {
  final String verificationId;

  VerifyPhone({required this.verificationId});

  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  late String _smsCode = "";
  bool _activationIgnore = false;

  final RoundedLoadingButtonController _verificationBtnController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    if (_smsCode.length == 6) {
      _activationIgnore = true;
    } else {
      _activationIgnore = false;
    }

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
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const LoginPage()));
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
                  length: 6,
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
                  onChanged: (pin) {
                    setState(() {
                      _smsCode = pin;
                    });
                  },
                  onCompleted: (pin) {
                    //    print("Completed: " + pin);
                    setState(() {
                      _smsCode = pin;
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
                            ignoring: !_activationIgnore,
                            child: RoundedLoadingButton(
                                color: _activationIgnore
                                    ? Color(0xffDE0000)
                                    : Colors.white.withOpacity(0.1),
                                child: Text('DONE'),
                                controller: _verificationBtnController,
                                onPressed: () async {
                                  String? errMessage = await AuthService
                                      .signInWithSMSVerificationCode(
                                          context,
                                          MainScreenCustomer.idScreen,
                                          RegistrationScreen.idScreen,
                                          _smsCode,
                                          widget.verificationId);

                                  if (errMessage != null) {
                                    Navigator.pop(context);
                                    displayToastMessage(errMessage, context);
                                  }
                                })))),
              ],
            ),
          )
        ],
      )),
    );
  }
}
