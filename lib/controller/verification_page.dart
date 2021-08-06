import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:safe/auth_service.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/registration_screen.dart';

// ignore: must_be_immutable
class VerifyPhone extends StatefulWidget {
  final String verificationId;

  VerifyPhone({required this.verificationId});

  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  late String _smsCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          backgroundColor: Color(0xfe7a110a),
          elevation: 0.0,
          leading: new BackButton(color: Colors.black),
          title: Text('Please enter OTP'),
          actions: <Widget>[]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Column(
            children: [
              Container(
                  child: Text(
                "Verification Code",
                style: TextStyle(
                    color: Color(0xff000000),
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'Open Sans'),
              )),
              Container(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                  child: Text(
                    "Please enter the OTP sent to  \n your Phone Text message",
                    style: TextStyle(
                        color: Color(0xff000000), fontFamily: 'Open Sans'),
                  )),
              OTPTextField(
                length: 6,
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldWidth: 55,
                fieldStyle: FieldStyle.box,
                outlineBorderRadius: 15,
                style: TextStyle(fontSize: 17),
                keyboardType: TextInputType.number,
                onCompleted: (pin) {
                  print("Completed: " + pin);
                  setState(() {
                    _smsCode = pin;
                  });
                },
              ),
              Container(
                padding: const EdgeInsets.only(top: 10.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0.5,
                      blurRadius: 6,
                      offset: Offset(0, 5), // changes position of shadow
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xff7a110a)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ))),
                    child: Center(
                        child: Text(
                      'Verify',
                      style: TextStyle(
                          color: Color(0xffffffff),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Open Sans'),
                    )),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => CustomProgressDialog(
                            message: 'Verifying SMS, Please Wait...'),
                      );

                      bool result =
                          await AuthService.signInWithSMSVerificationCode(
                              context,
                              MainScreenCustomer.idScreen,
                              RegistrationScreen.idScreen,
                              _smsCode,
                              widget.verificationId);

                      if (!result) {
                        Navigator.pop(context);
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
