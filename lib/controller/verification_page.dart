import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:safe/auth_service.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/otp_text_field/otp_field.dart';
import 'package:safe/controller/otp_text_field/style.dart';
import 'package:safe/controller/registration_screen.dart';

class VerifyPhone extends StatefulWidget {
  final String verificationId;

  VerifyPhone({required this.verificationId});

  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  late String _smsCode;
  final RoundedLoadingButtonController _verificationBtnController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: new AppBar(
          backgroundColor: Color(0xffffffff),
          elevation: 0.0,
          leading: new BackButton(color: Color(0xff7a110a)),
          actions: <Widget>[]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 5.0),
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(right: 80.0),
                  child: Text(
                    "what\'s the Code ?",
                    style: TextStyle(
                        color: Color(0xff000000),
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        fontFamily: 'Open Sans'),
                  )),
              Container(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                  child: Text(
                    "Enter the Code sent to " ,
                    style: TextStyle(
                        color: Color(0xff000000), fontFamily: 'Open Sans'),
                  )),
              OTPTextField(
                length: 6,
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldWidth: 50,
                fieldStyle: FieldStyle.underline,
                outlineBorderRadius: 15,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                keyboardType: TextInputType.number,
                onCompleted: (pin) {
                  //    print("Completed: " + pin);
                  setState(() {
                    _smsCode = pin;
                  });
                },
              ),
              Container(
                padding: const EdgeInsets.only(top: 10.0),
                width: MediaQuery.of(context).size.width * 0.5,
                child: RoundedLoadingButton(
                  color: Color(0xff077f59),
                  child: Text('Verify'),
                  controller: _verificationBtnController,
                  onPressed: () async {
                    String? errMessage =
                        await AuthService.signInWithSMSVerificationCode(
                            context,
                            MainScreenCustomer.idScreen,
                            RegistrationScreen.idScreen,
                            _smsCode,
                            widget.verificationId);

                    if (errMessage != null) {
                      Navigator.pop(context);
                      displayToastMessage(errMessage, context);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
