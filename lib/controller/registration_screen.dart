import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/controller/login_page.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class RegistrationScreen extends StatefulWidget {
  static const String idScreen = "register";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String _customerName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.55,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('images/safe.png'),
                    //  height: MediaQuery.of(context).size.height * 0.30,
                    width: 150.0,
                  ),

                  // Customer Name
                  SizedBox(height: 20.0),
                  Container(
                    width: double.infinity,
                    padding:
                    EdgeInsets.only(top: 10.0, left: 30.0, right: 30.0),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.white, width: 2.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          labelText: SafeLocalizations.of(context)!.registration_customer_name,
                          labelStyle: TextStyle(color: Colors.white),
                          hintText: SafeLocalizations.of(context)!.
                          registration_customer_name_hint,
                          hintStyle: TextStyle(color: Colors.grey),
                          fillColor: Colors.white),
                      onChanged: (val) {
                        _customerName = val;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),

            // Done Button
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0.5,
                    blurRadius: 9,
                    offset: Offset(3, 1),
                  ),
                ],
              ),
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.5,
              child: ElevatedButton(
                  onPressed: () {
                    // don't accept values when either of the values are empty
                    if (_customerName
                        .trim()
                        .isEmpty) {
                      return;
                    }
                    registerNewUser(context);
                  },
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Color(0xffE63830)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ))),
                  child: Text(
                    SafeLocalizations.of(context)!.
                    registration_register_customer,
                    style: TextStyle(
                        color: Color(0xfffefefe),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Open Sans'),
                  )),
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
        builder: (context) =>
            CustomProgressDialog(message: SafeLocalizations.of(context)!.
                registration_registration_progress),
      );


      final User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        Map<String, dynamic> customerFields = new Map();

        customerFields[Customer.FIELD_USER_NAME] = _customerName.trim();
        customerFields[Customer.FIELD_PHONE_NUMBER] = firebaseUser.phoneNumber!;
        customerFields[Customer.FIELD_IS_ACTIVE] = true;
        customerFields[Customer.FIELD_IS_LOGGED_IN] = true;
        customerFields[Customer.FIELD_DATE_CREATED] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
            .doc(firebaseUser.uid)
            .set(customerFields);

        await PrefUtil.setLoginStatus(PrefUtil.LOGIN_STATUS_LOGIN_JUST_NOW);

        displayToastMessage(
            SafeLocalizations.of(context)!.
            registration_registration_congratulations, context);

        Navigator.pushNamedAndRemoveUntil(
            context, MainScreenCustomer.idScreen, (route) => false);
      } else {
        // this dismisses the progress dialog
        Navigator.pop(context);

        displayToastMessage(SafeLocalizations.of(context)!.
            registration_registration_new_customer_has_been_created, context);
      }
    } catch (err) {
      // this dismisses the progress dialog
      Navigator.pop(context);

      displayToastMessage('Error: ${err.toString()}', context);
    }
  }
}
