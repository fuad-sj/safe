import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe/auth_service.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/registration_screen.dart';
import 'package:safe/controller/verification_page.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class LoginPage extends StatefulWidget {
  static const String idScreen = 'LoginPage';

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String _verificationId;

  bool _loginBtnActive = false;

  TextEditingController _phoneController = TextEditingController();

  String? _appVersionNumber;

  void _setPhoneControllerText(String newPhone) {
    _phoneController.value = TextEditingValue(
      text: newPhone,
      selection: TextSelection.collapsed(offset: newPhone.length),
    );
  }

  @override
  void initState() {
    super.initState();

    _phoneController.text = '+251'; // start off with ethiopian phone number

    _phoneController.addListener(() {
      String phone = _phoneController.text;

      // reset to +251 if non ethiopian phone is used
      if (!phone.startsWith('+251')) {
        _setPhoneControllerText('+251');
      } else if (phone.length >= 5 && !phone.startsWith('+2519')) {
        _setPhoneControllerText('+251');
      } else if (phone.length > 13) {
        _setPhoneControllerText(phone.substring(0, 13));
      }

      _loginBtnActive = _phoneController.text.length == 13;
      setState(() {});
    });

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      _appVersionNumber = '${version}_$buildNumber';
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xffF00699),
                    Color(0xffBF1A2F),
                  ]),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.0),
                  bottomRight: Radius.circular(50.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 6), // changes position of shadow
                ),
              ],
            ),
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage('images/safe.png'),
                  //  height: MediaQuery.of(context).size.height * 0.30,
                  width: 150.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: [
                      Container(),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                            EdgeInsets.only(top: 10.0, left: 30.0, right: 30.0),
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 2.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              labelText: SafeLocalizations.of(context)!
                                  .login_phone_number,
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: '+251912345678',
                              hintStyle: TextStyle(color: Colors.grey),
                              fillColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0.5,
                          blurRadius: 9,
                          offset: Offset(3, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ElevatedButton(
                        onPressed: () {
                          if (_loginBtnActive) {
                            verifyPhone(context);
                          }
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                _loginBtnActive
                                    ? Colors.orange.shade800
                                    : Colors.grey.shade700),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ))),
                        child: Text(
                          SafeLocalizations.of(context)!.login_log_in,
                          style: TextStyle(
                              color: Color(0xfffefefe),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Open Sans'),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Container(
                    child: Text(
                        SafeLocalizations.of(context)!.login_powered_by +
                            (_appVersionNumber != null
                                ? ' $_appVersionNumber'
                                : ''),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Open Sans')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> verifyPhone(BuildContext context) async {
    PhoneVerificationCompleted verificationCompleted =
        (AuthCredential authCredential) {
      AuthService.signInWithLoginCredential(
          context,
          MainScreenCustomer.idScreen,
          RegistrationScreen.idScreen,
          authCredential);
    };

    PhoneCodeSent smsSent = (verificationID, int? forceResend) {
      _verificationId = verificationID;
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VerifyPhone(verificationId: _verificationId)),
        );
      }
    };

    PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout =
        (String verificationID) {
      _verificationId = verificationID;
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VerifyPhone(verificationId: _verificationId)),
        );
      }
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomProgressDialog(
          message: SafeLocalizations.of(context)!.login_logging_in),
    );

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        verificationCompleted: verificationCompleted,
        verificationFailed: (FirebaseAuthException e) {
          // pop off the progress dialog and show a toast message instead
          Navigator.pop(context);
          displayToastMessage(
              e.message ??
                  SafeLocalizations.of(context)!.login_error_logging_in,
              context);
        },
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoRetrievalTimeout);
  }
}
