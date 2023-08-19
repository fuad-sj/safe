import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/controller/otp_text_field/otp_field.dart';
import 'package:safe/controller/otp_text_field/otp_field_style.dart';
import 'package:safe/controller/otp_text_field/style.dart';
import 'package:safe/controller/toggle_switch.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:path/path.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:widget_mask/widget_mask.dart';

class RegistrationScreen extends StatefulWidget {
  static const String idScreen = "register";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

enum Gender { female, male }

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const REGISTER_BTN_STATE_MISSING_FIELD = 1;
  static const REGISTER_BTN_STATE_WRONG_REFERRAL = 2;
  static const REGISTER_BTN_STATE_CORRECT_DATA = 3;
  static const REGISTER_BTN_STATE_CORRECT_REFERRAL = 4;

  // final picker = ImagePicker();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  late ImageProvider _defaultProfileImage;

  Gender _character = Gender.male;
  File? _profileFile;
  FileImage? _profileImage;

  int _registerBtnState = REGISTER_BTN_STATE_MISSING_FIELD;

  String _referralCode = "";

  final RoundedLoadingButtonController _CustomerLoadingBtnController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();

    _defaultProfileImage = AssetImage('images/mask1.png');

    var callback = () {
      final FormState form = _formKey.currentState!;
      form.validate();

      setState(() {
        updateEnableBtnState();
      });
    };

    _nameController.addListener(callback);
    _lastNameController.addListener(callback);
    _emailController.addListener(callback);
  }

  bool isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  void updateEnableBtnState() {
    _registerBtnState = (_nameController.text.trim().isNotEmpty &&
            _lastNameController.text.trim().isNotEmpty)
        ? REGISTER_BTN_STATE_CORRECT_DATA
        : REGISTER_BTN_STATE_MISSING_FIELD;

    _referralCode = _referralCode.replaceAll(' ', '');

    if (_registerBtnState == REGISTER_BTN_STATE_CORRECT_DATA) {
      if (_referralCode.length == 10) {
        if (Customer.isReferralCodeValid(_referralCode)) {
          _registerBtnState = REGISTER_BTN_STATE_CORRECT_REFERRAL;
        } else {
          _registerBtnState = REGISTER_BTN_STATE_WRONG_REFERRAL;
        }
      }
    }
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Color(0xffDE0000), Color(0xff990000)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    String registerBtnText;
    Color registerBtnColor;

    switch (_registerBtnState) {
      case REGISTER_BTN_STATE_WRONG_REFERRAL:
        registerBtnText = "የተሳሳተ ሪፈራል";
        registerBtnColor = Color(0xffDE0000);
        break;
      case REGISTER_BTN_STATE_CORRECT_DATA:
        registerBtnText = "ይመዝገቡ";
        registerBtnColor = Colors.green.shade800;
        break;
      case REGISTER_BTN_STATE_CORRECT_REFERRAL:
        registerBtnText = "ትክክል ሪፈራል, ይመዝገቡ";
        registerBtnColor = Colors.blue.shade800;
        break;
      case REGISTER_BTN_STATE_MISSING_FIELD:
      default:
        registerBtnText = "ስም ያስገቡ";
        registerBtnColor = Colors.grey.shade700;
        break;
    }
    return Scaffold(
        body: SingleChildScrollView(
      child: new Stack(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                      image: AssetImage('images/safeLogo.png'),
                      fit: BoxFit.cover)),
              child: Stack(
                children: <Widget>[
                  /*
                  GestureDetector(
                    onTap: () async {
                      XFile? pickedXFile =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (pickedXFile != null) {
                        _profileFile = File(pickedXFile.path);
                        _profileImage = FileImage(_profileFile!);
                      } else {
                        _profileFile = null;
                        _profileImage = null;
                      }
                      setState(() {
                        updateEnableBtnState();
                      });
                    },
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.223,
                          left: MediaQuery.of(context).size.width * 0.1,
                          child: Container(
                            //     width: MediaQuery.of(context).size.width,
                            // height: MediaQuery.of(context).size.height * 0.15,
                            child: WidgetMask(
                              blendMode: BlendMode.srcATop,
                              childSaveLayer: true,
                              mask: Image(
                                  image: (_profileImage != null)
                                      ? _profileImage!
                                      : _defaultProfileImage,
                                  fit: BoxFit.fill),
                              child: Image.asset(
                                'images/mask1.png',
                                width: MediaQuery.of(context).size.width * 0.20,
                                height:
                                    MediaQuery.of(context).size.height * 0.10,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.29,
                          left: MediaQuery.of(context).size.width * 0.21,
                          child: Image.asset(
                            'images/input.png',
                            height: MediaQuery.of(context).size.height * 0.03,
                            width: MediaQuery.of(context).size.width * 0.064,
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.33,
                          left: MediaQuery.of(context).size.width * 0.11,
                          child: Text(
                            'Profile Picture',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                 */
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.127,
                    left: MediaQuery.of(context).size.width * 0.05,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Text('እንኳን ወደ ሴፍ መጡ',
                                style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                    foreground: Paint()
                                      ..shader = linearGradient)),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.02),
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Color(0xffE1E0DF)),
                            child: TextFormField(
                              style: TextStyle(color: Colors.black),
                              // keyboardType: TextInputType.text,
                              controller: _nameController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 13.0, horizontal: 20.7),
                                  hintText: "ስም",
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade500),
                                  fillColor: Colors.white),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.01),
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Color(0xffE1E0DF),
                            ),
                            child: TextFormField(
                              style: TextStyle(color: Colors.black),
                              // keyboardType: TextInputType.text,
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 13.0, horizontal: 20.7),
                                  hintText: 'የአባት ስም',
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade500),
                                  fillColor: Colors.white),
                            ),
                          ),
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height *
                                      0.01),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('ፆታ : ',
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontFamily: 'Lato',
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800)),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.05),
                                  Container(
                                    //width: MediaQuery.of(context).size.width * 0.8,
                                    child: ToggleSwitch(
                                      minWidth:
                                          MediaQuery.of(context).size.width *
                                              0.20,
                                      cornerRadius: 20.0,
                                      activeBgColors: [
                                        [Colors.blue[900]!],
                                        [Color(0xFFFC2085)],
                                      ],
                                      activeFgColor: Colors.white,
                                      inactiveBgColor: Colors.grey,
                                      inactiveFgColor: Colors.white,
                                      initialLabelIndex:
                                          _character == Gender.male ? 0 : 1,
                                      totalSwitches: 2,
                                      labels: ['ወንድ', 'ሴት'],
                                      animate: true,
                                      animationDuration: 200,
                                      customTextStyles: [
                                        TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.0)
                                      ],
                                      radiusStyle: true,
                                      onToggle: (index) {
                                        _character = (index == 0)
                                            ? Gender.male
                                            : Gender.female;
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.01),
                            child: FocusScope(
                              child: Focus(
                                child: OTPTextField(
                                  length: 10,
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  textFieldAlignment:
                                      MainAxisAlignment.spaceAround,
                                  fieldWidth: 28,
                                  fieldStyle: FieldStyle.box,
                                  outlineBorderRadius: 10,
                                  otpFieldStyle: OtpFieldStyle(
                                    borderColor: Colors.green.shade600,
                                    focusBorderColor: Colors.grey.shade500,
                                    enabledBorderColor: Color(0xff990000),
                                  ),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                  keyboardType: TextInputType.text,
                                  onChanged: (val) {
                                    setState(() {
                                      _referralCode = val;
                                      updateEnableBtnState();
                                    });
                                  },
                                  onCompleted: (val) {
                                    setState(() {
                                      _referralCode = val;
                                      updateEnableBtnState();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Text('ሪፈራል ኮድ (optional)',
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontFamily: 'Lato',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w200)),
                          Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.04),
                            width: MediaQuery.of(context).size.width * 0.65,
                            height: MediaQuery.of(context).size.height * 0.052,
                            child: ElevatedButton(
                              child: Text(registerBtnText,
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                if (_registerBtnState ==
                                        REGISTER_BTN_STATE_CORRECT_DATA ||
                                    _registerBtnState ==
                                        REGISTER_BTN_STATE_CORRECT_REFERRAL) {
                                  registerNewUser(context);
                                } else if (_nameController.text
                                    .trim()
                                    .isEmpty) {
                                  displayToastMessage('የራሶን ስም ያስገቡ', context);
                                } else if (_lastNameController.text
                                    .trim()
                                    .isEmpty) {
                                  displayToastMessage('የአባቶን ስም ያስገቡ', context);
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      registerBtnColor),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.88,
              left: MediaQuery.of(context).size.width * 0.1,
              child: Image.asset(
                ('images/whiteSafeLogo.png'),
                height: MediaQuery.of(context).size.height * 0.09,
              )),
        ],
      ),
    ));
  }

  void registerNewUser(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CustomProgressDialog(
            message: SafeLocalizations.of(context)!
                .registration_registration_progress),
      );

      final User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        String? profileURL;
        if (_profileFile != null) {
          String fileName = basename(_profileFile!.path);
          String fileExtension =
              AlphaNumericUtil.extractFileExtensionFromName(fileName);

          String convertedFilePath = Customer.convertStoragePathToCustomerPath(
              firebaseUser.uid, Customer.FIELD_LINK_IMG_PROFILE, fileExtension);

          firebase_storage.Reference firebaseStorageRef = firebase_storage
              .FirebaseStorage.instance
              .ref()
              .child(convertedFilePath);
          firebase_storage.UploadTask uploadTask =
              firebaseStorageRef.putFile(_profileFile!);
          firebase_storage.TaskSnapshot taskSnapshot =
              await uploadTask.whenComplete(() => null);
          profileURL = await taskSnapshot.ref.getDownloadURL();
        }

        Map<String, dynamic> customerFields = new Map();

        customerFields[Customer.FIELD_USER_NAME] = _nameController.text.trim();
        customerFields[Customer.FIELD_USER_LAST_NAME] =
            _lastNameController.text.trim();
        customerFields[Customer.FIELD_GENDER] = _character == Gender.female
            ? Customer.GENDER_FEMALE
            : Customer.GENDER_MALE;
        customerFields[Customer.FIELD_EMAIL] = _emailController.text.trim();
        customerFields[Customer.FIELD_PHONE_NUMBER] =
            PrefUtil.getCurrentUserPhone();
        if (profileURL != null) {
          customerFields[Customer.FIELD_LINK_IMG_PROFILE] = profileURL;
        }
        customerFields[Customer.FIELD_IS_ACTIVE] = true;
        customerFields[Customer.FIELD_IS_LOGGED_IN] = true;
        customerFields[Customer.FIELD_DATE_CREATED] =
            FieldValue.serverTimestamp();

        if (_registerBtnState == REGISTER_BTN_STATE_CORRECT_REFERRAL) {
          customerFields[Customer.FIELD_WAS_REFERRED] = true;
          customerFields[Customer.FIELD_REFERRED_BY] =
              _referralCode.toUpperCase();
        }

        await FirebaseFirestore.instance
            .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
            .doc(firebaseUser.uid)
            .set(customerFields, SetOptions(merge: true));

        await PrefUtil.setLoginStatus(PrefUtil.LOGIN_STATUS_LOGIN_JUST_NOW);

        displayToastMessage(
            SafeLocalizations.of(context)!
                .registration_registration_congratulations,
            context);

        Navigator.pushNamedAndRemoveUntil(
            context, MainScreenCustomer.idScreen, (route) => false);
      } else {
        // this dismisses the progress dialog
        Navigator.pop(context);

        displayToastMessage(
            SafeLocalizations.of(context)!
                .registration_registration_new_customer_has_been_created,
            context);
      }
    } catch (err) {
      // this dismisses the progress dialog
      Navigator.pop(context);

      displayToastMessage('Error: ${err.toString()}', context);
    }
  }
}
