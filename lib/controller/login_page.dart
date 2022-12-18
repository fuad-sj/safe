//import 'dart:html';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/registration_screen.dart';
import 'package:safe/controller/verify_otp_page.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:safe/language_selector_dialog.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/safe_otp_request.dart';
import 'package:safe/utils/http_util.dart';
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

  bool _isVerifyClicked = false;
  bool _loginBtnActive = false;
  final RoundedLoadingButtonController _loginBtnController =
      RoundedLoadingButtonController();

  String _countryCode = '+251'; //start off with Ethiopia
  TextEditingController _phoneController = TextEditingController();

  String? _appVersionNumber;

  bool _languageDialogShown = false;
  bool _isVerifyTrue = false;

  late String _instNo;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _otpSubscription;

  void _setPhoneControllerText(String newPhone) {
    _phoneController.value = TextEditingValue(
      text: newPhone,
      selection: TextSelection.collapsed(offset: newPhone.length),
    );
  }

  @override
  void initState() {
    super.initState();

    Random random = new Random();
    _instNo = '${random.nextInt(10) + 1}';

    _phoneController.addListener(() {
      String phone = _phoneController.text;

      if (_countryCode == "+251") {
        // if the phone number is ethiopian, only allow valid phone numbers
        if (!phone.startsWith('9') && !phone.startsWith('7')) {
          _setPhoneControllerText('');
        } else if (phone.length > 9) {
          _setPhoneControllerText(phone.substring(0, 9));
        }
        _loginBtnActive = _phoneController.text.length == 9;
      } else {
        _loginBtnActive = true;
      }

      setState(() {});
    });

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String version = packageInfo.version;

      _appVersionNumber = '${version}';
      setState(() {});
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
                        MediaQuery.of(context).size.height * 0.125)),
              ),
              height: !_isVerifyTrue
                  ? MediaQuery.of(context).size.height * 0.71
                  : MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: <Widget>[
                  Positioned(
                      top: !_isVerifyTrue
                          ? 0.0
                          : MediaQuery.of(context).size.height * 0.06,
                      left: !_isVerifyTrue ? 0.0 : 22.0,
                      child: IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_sharp,
                              size: !_isVerifyTrue ? 0.0 : 18.0),
                          color: Colors.white,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                          })),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: !_isVerifyTrue
                              ? MediaQuery.of(context).size.height * 0.20
                              : MediaQuery.of(context).size.height * 0.11),
                      child: Image(
                        image: AssetImage('images/white_logo.png'),
                        height: !_isVerifyTrue
                            ? MediaQuery.of(context).size.height * 0.180
                            : MediaQuery.of(context).size.height * 0.120,
                      ),
                    ),
                  )
                ],
              )),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02),
                    child: Visibility(
                      visible: !_isVerifyTrue,
                      child: Container(
                        child: Text(
                          'THE FUTURE IS SAFE',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.02,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                      left: MediaQuery.of(context).size.width * 0.1,
                      right: MediaQuery.of(context).size.width * 0.1,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xffDD0000),
                            width: 3.0,
                          ),
                          borderRadius: BorderRadius.circular(20.0)),
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
                            textStyle: TextStyle(color: Colors.black),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.04,
                            width: 1.0,
                            decoration: BoxDecoration(color: Color(0xff0f0f0f)),
                          ),
                          Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(right: 30.0),
                              child: FocusScope(
                                child: Focus(
                                  onFocusChange: (focus) =>
                                      _isVerifyTrue = !_isVerifyTrue,
                                  child: TextField(
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20),
                                    keyboardType: TextInputType.phone,
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 10.0
                                            ),
                                        hintText: '912345678',
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        fillColor: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                Visibility(
                    visible: _isVerifyTrue,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.04),
                      child: Container(
                          width: _isVerifyClicked
                              ? MediaQuery.of(context).size.width * 0.11
                              : MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.width * 0.1,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.bottomRight,
                                  end: Alignment.topRight,
                                  colors: [
                                    Color(0xff990000),
                                    Color(0xffDE0000),
                                  ]),
                              borderRadius: BorderRadius.circular(
                                25.0,
                              )),
                          child: IgnorePointer(
                            ignoring: !_loginBtnActive,
                            child: RoundedLoadingButton(
                                child: Text('Verify Your Phone',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white)),
                                controller: _loginBtnController,
                                onPressed: () async {
                                  if (_loginBtnActive) {
                                    sendOTPRequest(context);
                                    setState(() {
                                      _isVerifyClicked = true;
                                    });
                                  }
                                },
                                color: _loginBtnActive
                                    ? Color(0xffDE0000)
                                    : Colors.white.withOpacity(0.1)),
                          )),
                    )),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Future<void> sendOTPRequest(BuildContext context) async {
    try {
      String phone_no =
          _countryCode.substring(1) + // get rid off the "+" from start of phone
              _phoneController.text;
      Map<String, dynamic> params = {
        "phone_number": phone_no,
        "inst_no": _instNo,
        "is_driver_phone": "false",
      };
      var response = await HttpUtil.getHttpsRequest(
          "us-central1-safetransports-et.cloudfunctions.net",
          "/OTPEndpoint${_instNo}/api/v1/phone_auth",
          params);

      String OTP_ID = response["otp_id"];

      _otpSubscription?.cancel();
      _otpSubscription = FirebaseFirestore.instance
          .collection(FIRESTORE_PATHS.COL_OTP_REQUESTS)
          .doc(OTP_ID)
          .snapshots()
          .listen((snapshot) {
        SafeOTPRequest otpRequest = SafeOTPRequest.fromSnapshot(snapshot);

        switch (otpRequest.otp_status) {
          case SafeOTPRequest.SAFE_OTP_STATUS_OTP_SENT:
            _loginBtnController
                .reset(); // if we pop-back to this page, reset to allow re-submitting

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      VerifyOTP(otpID: OTP_ID, instNo: _instNo)),
            );
            break;
          case SafeOTPRequest.SAFE_OTP_STATUS_OTP_EXPIRED:
            _loginBtnController
                .reset(); // if we pop-back to this page, reset to allow re-submitting
            displayToastMessage('OTP Expired, Please Try Again', context);
            break;
        }
      });
    } catch (err) {
      _loginBtnController.reset();
      displayToastMessage('Error, please try again', context);
    }
  }
}
