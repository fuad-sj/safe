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
import 'package:safe/language_selector_dialog.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LoginPage extends StatefulWidget {
  static const String idScreen = 'LoginPage';

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String _verificationId;

  bool _loginBtnActive = false;
  final RoundedLoadingButtonController _loginBtnController =
      RoundedLoadingButtonController();

  String _countryCode = '+251'; //start off with Ethiopia
  TextEditingController _phoneController = TextEditingController();

  String? _appVersionNumber;

  bool _languageDialogShown = false;

  void _setPhoneControllerText(String newPhone) {
    _phoneController.value = TextEditingValue(
      text: newPhone,
      selection: TextSelection.collapsed(offset: newPhone.length),
    );
  }

  @override
  void initState() {
    super.initState();

    // _phoneController.text = '+251'; // start off with ethiopian phone number

    _phoneController.addListener(() {
      String phone = _phoneController.text;

      if (_countryCode == "+251") {
        // if the phone number is ethiopian, only allow valid phone numbers
        if (!phone.startsWith('9')) {
          _setPhoneControllerText('');
        } else if (phone.length > 9) {
          _setPhoneControllerText(phone.substring(0, 9));
        }
        _loginBtnActive = _phoneController.text.length == 9;
      } else {
        _loginBtnActive = true;
      }
      /*
      // reset to +251 if non ethiopian phone is used
      if (!phone.startsWith('+251')) {
        _setPhoneControllerText('+251');
      } else if (phone.length >= 5 && !phone.startsWith('+2519')) {
        _setPhoneControllerText('+251');
      } else if (phone.length > 13) {
        _setPhoneControllerText(phone.substring(0, 13));
      }

      _loginBtnActive = _phoneController.text.length == 13;

     */
      setState(() {});
    });

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String version = packageInfo.version;

      _appVersionNumber = '${version}';
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff7f072d),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage('images/logo.png'),
                      height: MediaQuery.of(context).size.height * 0.20,
                      width: 120.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        children: [
                          CountryCodePicker(
                              onChanged: (newCode) {
                                _countryCode = newCode.dialCode ?? '+251';
                              },
                              initialSelection: 'ET',
                              favorite: ['+251', 'ET'],
                              showFlagDialog: true,
                              enabled: true,
                              textStyle: TextStyle(color: Colors.white),
                              padding: EdgeInsets.all(15.0)),
                          Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(top: 5.0, right: 30.0),
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.phone,
                                controller: _phoneController,
                                decoration: InputDecoration(
                                    suffixIcon: Icon(
                                      Icons.phone_android,
                                      color: Colors.white,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.blueGrey, width: 2.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 2.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    labelText: SafeLocalizations.of(context)!
                                        .login_phone_number,
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintText: '912345678',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    fillColor: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xffffffff),
                          Color(0xffb1aeaf),
                        ]),
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(150.0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blueGrey.shade50.withOpacity(0.8),
                          spreadRadius: 7,
                          blurRadius: 6,
                          offset: Offset(0, 7))
                    ]),
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: IgnorePointer(
                            ignoring: !_loginBtnActive,
                            child: RoundedLoadingButton(
                                child: Text('Verify Your Phone',
                                    style: TextStyle(color: Colors.white)),
                                controller: _loginBtnController,
                                onPressed: () {
                                  if (_loginBtnActive) {
                                    verifyPhone(context);
                                  }
                                },
                                color: _loginBtnActive
                                    ? Color(0xff077f59)
                                    : Colors.grey.shade700),
                          )),
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
        ));
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

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _countryCode + _phoneController.text,
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
