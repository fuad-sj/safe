import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
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
  final picker = ImagePicker();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  late ImageProvider _defaultProfileImage;

  Gender _character = Gender.female;
  File? _profileFile;
  FileImage? _profileImage;

  bool _enableRegisterBtn = false;

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
    _enableRegisterBtn = _nameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        isValidEmail(_emailController.text.trim()) &&
        (_profileFile != null && _profileImage != null);
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Color(0xffDE0000), Color(0xff990000)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
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
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.127,
                    left: MediaQuery.of(context).size.width * 0.1,
                    child: Text('Welcome to Safe',
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()..shader = linearGradient)),
                  ),
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
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.383,
                    left: MediaQuery.of(context).size.width * 0.11,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Color(0xffE1E0DF)),
                            child: TextFormField(
                              style: TextStyle(color: Colors.black),
                              // keyboardType: TextInputType.text,
                              controller: _nameController,
                              validator: (name) {
                                return (name!.isEmpty)
                                    ? SafeLocalizations.of(context)!
                                        .registration_customer_name_empty
                                    : null;
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 13.0, horizontal: 20.7),
                                  hintText: SafeLocalizations.of(context)!
                                      .registration_customer_name_hint,
                                  hintStyle: TextStyle(color: Colors.black),
                                  fillColor: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.02),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Color(0xffE1E0DF)),
                              child: TextFormField(
                                style: TextStyle(color: Colors.black),
                                // keyboardType: TextInputType.text,
                                controller: _lastNameController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 13.0, horizontal: 20.7),
                                    hintText: 'Last Name',
                                    hintStyle: TextStyle(color: Colors.black),
                                    fillColor: Colors.white),
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.03,
                                  bottom: MediaQuery.of(context).size.height *
                                      0.01),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Text('Gender',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Lato',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800)),
                              )),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Expanded(
                                  child: RadioListTile<Gender>(
                                    title: const Text('Female',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                        )),
                                    value: Gender.female,
                                    activeColor: Color(0xffDE0000),
                                    groupValue: _character,
                                    onChanged: (Gender? value) {
                                      setState(() {
                                        _character = value!;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                    child: RadioListTile<Gender>(
                                  title: const Text('Male',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400)),
                                  value: Gender.male,
                                  activeColor: Color(0xffDE0000),
                                  groupValue: _character,
                                  onChanged: (Gender? value) {
                                    setState(() {
                                      _character = value!;
                                    });
                                  },
                                )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.02,
                                bottom:
                                    MediaQuery.of(context).size.height * 0.02),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Color(0xffE1E0DF)),
                              child: TextFormField(
                                style: TextStyle(color: Colors.black),
                                // keyboardType: TextInputType.text,
                                controller: _emailController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 13.0, horizontal: 20.7),
                                    hintText: 'Email',
                                    hintStyle: TextStyle(color: Colors.black),
                                    fillColor: Colors.white),
                              ),
                            ),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.042,
                                          child: IgnorePointer(
                                            ignoring: !_enableRegisterBtn,
                                            child: RoundedLoadingButton(
                                              child: Text('Sign Up',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              controller:
                                                  _CustomerLoadingBtnController,
                                              onPressed: () {
                                                if (_enableRegisterBtn) {
                                                  registerNewUser(context);
                                                } else if (_profileImage ==
                                                        null ||
                                                    _profileFile == null) {
                                                  displayToastMessage(
                                                      SafeLocalizations.of(
                                                              context)!
                                                          .registration_customer_profile_image_needed,
                                                      context);
                                                }
                                              },
                                              color: _enableRegisterBtn
                                                  ? Color(0xffDD0000)
                                                  : Color(0xff990000),
                                            ),
                                          ))),
                                  Expanded(
                                      child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                  )),
                                ],
                              ))
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
          Positioned(
              top: MediaQuery.of(context).size.height * 0.92,
              right: MediaQuery.of(context).size.width * 0.1,
              child: GestureDetector(
                onTap: () async {
                        MaterialPageRoute(
                          builder: (context) => MainScreenCustomer() );
                  },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ))
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
        String profileURL = await taskSnapshot.ref.getDownloadURL();

        Map<String, dynamic> customerFields = new Map();

        customerFields[Customer.FIELD_USER_NAME] = _nameController.text.trim();
        customerFields[Customer.FIELD_USER_LAST_NAME] =
            _lastNameController.text.trim();
        customerFields[Customer.FIELD_GENDER] = _character == Gender.female
            ? Customer.GENDER_FEMALE
            : Customer.GENDER_MALE;
        customerFields[Customer.FIELD_EMAIL] = _emailController.text.trim();
        customerFields[Customer.FIELD_PHONE_NUMBER] = firebaseUser.phoneNumber!;
        customerFields[Customer.FIELD_LINK_IMG_PROFILE] = profileURL;
        customerFields[Customer.FIELD_IS_ACTIVE] = false;
        customerFields[Customer.FIELD_IS_LOGGED_IN] = true;
        customerFields[Customer.FIELD_DATE_CREATED] =
            FieldValue.serverTimestamp();

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
