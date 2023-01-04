import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe/controller/login_page.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/registration_screen.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/models/driver.dart';
import 'package:safe/utils/pref_util.dart';

class WelcomeScreen extends StatefulWidget {
  static const String idScreen = 'WelcomeScreen';

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Timer? _splashTimer;

  bool _timerFinished = true;

  bool _customerCheckingFinished = false;
  bool _authExists = false;
  bool _customerRegistered = false;

  @override
  void initState() {
    super.initState();

    loadCurrentDriverDetails();
  }

  @override
  void didUpdateWidget(covariant WelcomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    loadCurrentDriverDetails();
  }

  void loadCurrentDriverDetails() async {
    _customerCheckingFinished = false;
    _timerFinished = false;
    _authExists = false;
    _customerRegistered = false;

    Future.delayed(Duration.zero).then(
      (_) async {
        int loginStatus = PrefUtil.getLoginStatus();
        _splashTimer?.cancel();
        _splashTimer = new Timer(
            Duration(
                seconds:
                    loginStatus == PrefUtil.LOGIN_STATUS_PREVIOUSLY_LOGGED_IN
                        ? 0
                        : 1), () {
          if (mounted) {
            setState(() {
              _timerFinished = true;
            });
          }
        });

        if (FirebaseAuth.instance.currentUser == null) {
          _customerCheckingFinished = true;
          if (mounted) {
            setState(() {});
          }
          return;
        }
        _authExists = true;

        Customer currentCustomer = Customer.fromSnapshot(
          await FirebaseFirestore.instance
              .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
        );

        _customerRegistered = currentCustomer.documentExists() &&
            currentCustomer.accountFullyCreated();
        _customerCheckingFinished = true;
        if (mounted) {
          setState(() {});
        }
        return;
      },
    );
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timerFinished && _customerCheckingFinished) {
      Future.delayed(Duration.zero).then((_) async {
        Navigator.pushNamedAndRemoveUntil(
            context,
            _customerRegistered
                ? MainScreenCustomer.idScreen
                : (_authExists
                    ? RegistrationScreen.idScreen
                    : LoginPage.idScreen),
            (route) => false);
      });
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.075),
          Center(
            child: Image(
              image: AssetImage('images/logo.png'),
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black))
        ],
      ),
    );
  }
}
