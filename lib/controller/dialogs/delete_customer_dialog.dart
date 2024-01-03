import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:safe/controller/login_page.dart';

import '../../models/FIREBASE_PATHS.dart';
import '../../utils/phone_call.dart';

class DeleteDialog extends StatefulWidget {
  const DeleteDialog({Key? key}) : super(key: key);

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double edgePadding = screenWidth * 0.10 / 2.0; // 10% of screen width

    double HORIZONTAL_PADDING = 15.0;

    return Dialog(
      elevation: 2.0,
      insetPadding: EdgeInsets.symmetric(horizontal: edgePadding),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dialog Header
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xffDE0000),
                    Color(0xff990000),
                  ],
                ),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0))),
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                ' Delete Account',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    fontFamily: 'Lato'),
              ),
            ),
          ),
          SizedBox(height: 15.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
            width: (screenWidth - 2 * HORIZONTAL_PADDING),
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  try {
                    String phoneNumber = '9981';
                    PhoneCaller.callPhone(phoneNumber);
                  } catch (err) {}
                },
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10.0),
                      Text(
                        'Are You Sure You Want To Delete An Account ?',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1),
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15.0),

          // Done Trip
          Container(
            padding: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // pop off the dialog
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(primary: Color(0xffDD0000)),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      width: double.infinity,
                      child: Center(
                        child: Text('NO',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await deleteCustomerAccount();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(primary: Color(0xff013a00)),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      width: double.infinity,
                      child: Center(
                        child: Text('Delete',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.0),
        ],
      ),
    );
  }
}

deleteCustomerAccount() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final userRef = FirebaseFirestore.instance
      .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
      .doc(uid);
  await userRef.delete();
  await FirebaseAuth.instance.currentUser?.delete();
}
