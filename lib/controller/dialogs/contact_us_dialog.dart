import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

import '../../utils/phone_call.dart';

class ContactUsDialog extends StatefulWidget {
  const ContactUsDialog({Key? key}) : super(key: key);

  @override
  _ContactUsDialogState createState() => _ContactUsDialogState();
}

class _ContactUsDialogState extends State<ContactUsDialog> {
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
                ' Contact Us',
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
                      String phoneNumber =  '9981';
                      PhoneCaller.callPhone(phoneNumber);
                    }
                    catch (err) {}
                  },
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone,
                        color: Colors.black,
                        size: 40.0,
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        '9981',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 40.0,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1),
                      ),
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
                    style: ElevatedButton.styleFrom(primary: Colors.black),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      width: double.infinity,
                      child: Center(
                        child: Text(
                            SafeLocalizations.of(context)!
                                .dialog_driver_not_found_dismiss,
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
