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

class RegistrationScreen extends StatefulWidget {
  static const String idScreen = "register";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final picker = ImagePicker();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  late ImageProvider _defaultProfileImage;

  File? _profileFile;
  FileImage? _profileImage;

  bool _enableRegisterBtn = false;

  final RoundedLoadingButtonController _CustomerLoadingBtnController = RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();

    _defaultProfileImage = AssetImage('images/user_icon.png');

    var callback = () {
      final FormState form = _formKey.currentState!;
      form.validate();

      setState(() {
        updateEnableBtnState();
      });
    };

    _nameController.addListener(callback);
    _emailController.addListener(callback);
  }

  bool isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  void updateEnableBtnState() {
    _enableRegisterBtn = _nameController.text.isNotEmpty &&
        isValidEmail(_emailController.text.trim()) &&
        (_profileFile != null && _profileImage != null);
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration textDecorator(String label, String hint) {
      return InputDecoration(
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
          ),
          errorStyle: TextStyle(color: Colors.white),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          fillColor: Colors.white);
    }

    return Scaffold(
      backgroundColor: Color(0xff7f072d),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xfff6f6f6),
                        Color(0xffababab),
                      ]),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100.0),
                      bottomRight: Radius.circular(100.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 9,
                      offset: Offset(1, 7), // changes position of shadow
                    ),
                  ],
                ),
                    child: Container(
                      margin: const EdgeInsets.only(top: 130.0),
                      child: GestureDetector(
                        onTap: () async {
                          XFile? pickedXFile = await picker.pickImage(
                              source: ImageSource.gallery);

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
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: (_profileImage != null)
                                  ? _profileImage!
                                  : _defaultProfileImage,
                              radius: 50.0,
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              SafeLocalizations.of(context)!
                                  .registration_customer_profile_image,
                              style: TextStyle(
                                  fontSize: 17.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
            Container(
              width: double.infinity,
                child: Container(
                  margin:  EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xfff6f6f6),
                          Color(0xffababab),
                        ]),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0),
                        bottomLeft: Radius.circular(25.0),
                        bottomRight: Radius.circular(25.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 9,
                        offset: Offset(1, 7), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Name
                      Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
                        child: TextFormField(
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.text,
                          controller: _nameController,
                          validator: (name) {
                            return (name!.isEmpty)
                                ? SafeLocalizations.of(context)!
                                    .registration_customer_name_empty
                                : null;
                          },
                          decoration: InputDecoration(
                          suffixIcon:  Icon (
                            Icons.perm_identity_rounded,
                            color: Colors.black,
                          ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.blueGrey, width: 2.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black, width: 2.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              labelText: SafeLocalizations.of(context)!
                                  .registration_customer_name,
                              labelStyle: TextStyle(color: Colors.black),
                              hintText:
                              SafeLocalizations.of(context)!
                                  .registration_customer_name_hint
                              ,
                              hintStyle: TextStyle(color: Colors.grey),
                              fillColor: Colors.white

                          ),
                        ),
                      ),

                      // Email
                      SizedBox(height: 10.0),
                      Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.only(top: 10.0, left: 30.0, right: 30.0, bottom: 20.0),

                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: (String? email) {
                            return (email!.isNotEmpty && !isValidEmail(email))
                                ? SafeLocalizations.of(context)!
                                    .registration_customer_email_empty
                                : null;
                          },
                          decoration: InputDecoration(
                              suffixIcon:  Icon (
                                Icons.email_outlined,
                                color: Colors.black,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.blueGrey, width: 2.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black, width: 2.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              labelText: SafeLocalizations.of(context)!
                                  .registration_customer_email,
                              labelStyle: TextStyle(color: Colors.black),
                              hintText:
                              SafeLocalizations.of(context)!
                                  .registration_customer_email_hint
                              ,
                              hintStyle: TextStyle(color: Colors.grey),
                              fillColor: Colors.white
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            // Done Button
            SizedBox(height: 10.0),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: IgnorePointer(
                ignoring: !_enableRegisterBtn,
                child: RoundedLoadingButton(
                    child: Text (
                      SafeLocalizations.of(context)!
                          .registration_register_customer,
                      style: TextStyle(color: Colors.white)),
                    controller: _CustomerLoadingBtnController,
                    onPressed: () {
                      if (_enableRegisterBtn) {
                        registerNewUser(context);
                      } else if (_profileImage == null || _profileFile == null) {
                        displayToastMessage(
                            SafeLocalizations.of(context)!
                                .registration_customer_profile_image_needed,
                            context);
                      }
                    },
                  color: _enableRegisterBtn? Color(0xff000202)
                      : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
