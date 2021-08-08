import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe/auth_service.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/registration_screen.dart';
import 'package:safe/controller/verification_page.dart';
import 'package:safe/main.dart';

class LoginPage extends StatefulWidget {
  static const String idScreen = 'LoginPage';

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String _phoneNo;
  late String _verificationId;

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
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 2.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: '+251912345678',
                              hintStyle: TextStyle(color: Colors.grey),
                              fillColor: Colors.white),
                          onChanged: (phoneVal) {
                            _phoneNo = phoneVal;
                            setState(() {});
                          },
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
                          verifyPhone(context);
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xffE63830)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ))),
                        child: Text(
                          "Log In",
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
                    child: Text('Powered By Mukera Technologies',
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
      builder: (context) =>
          CustomProgressDialog(message: 'Logging In, Please Wait...'),
    );

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNo,
        verificationCompleted: verificationCompleted,
        verificationFailed: (FirebaseAuthException e) {
          // pop off the progress dialog and show a toast message instead
          Navigator.pop(context);
          displayToastMessage(e.message ?? 'Error logging in', context);
        },
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoRetrievalTimeout);
  }
}
