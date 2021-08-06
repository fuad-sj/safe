import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/utils/pref_util.dart';

class AuthService {
  static Future<bool> signInWithLoginCredential(
    BuildContext context,
    String loggedInPath,
    String signupPath,
    AuthCredential authCredential,
  ) async {
    UserCredential credential =
        await FirebaseAuth.instance.signInWithCredential(authCredential);

    final User? firebaseUser = credential.user;
    if (firebaseUser == null) {
      return false;
    }

    await PrefUtil.setLoginStatus(PrefUtil.LOGIN_STATUS_LOGIN_JUST_NOW);

    Customer customer = Customer.fromSnapshot(
      await FirebaseFirestore.instance
          .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
          .doc(firebaseUser.uid)
          .get(),
    );

    Navigator.pushNamedAndRemoveUntil(
        context,
        customer.documentExists() ? loggedInPath : signupPath,
        (route) => false);

    return true;
  }

  static Future<bool> signInWithSMSVerificationCode(
    BuildContext context,
    String loggedInPath,
    String signupPath,
    String smsCode,
    String verificationId,
  ) async {
    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    return signInWithLoginCredential(
        context, loggedInPath, signupPath, credential);
  }
}
