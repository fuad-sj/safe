import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/controller/ui_helpers.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/ride_request.dart';

class RideCancellationDialog extends StatefulWidget {
  static final String DIALOG_RESULT_YES_PRESSED = 'dialog_result_yes_pressed';
  static final String DIALOG_RESULT_CANCEL_PRESSED =
      'dialog_result_cancel_pressed';

  final RideRequest rideRequest;

  const RideCancellationDialog({required this.rideRequest});

  @override
  _RideCancellationDialogState createState() => _RideCancellationDialogState();
}

class _RideCancellationDialogState extends State<RideCancellationDialog> {
  final List<_CancellationReason> _reasonsList = [
    _CancellationReason(reasonCode: 1, reasonDescription: 'Waited too long'),
    _CancellationReason(
        reasonCode: 2, reasonDescription: 'Driver too far away'),
    _CancellationReason(reasonCode: 2, reasonDescription: 'Changed my mind'),
  ];

  void setCancellationReason(BuildContext context, int reasonIndex) async {
    showDialog(
        context: context,
        builder: (_) => CustomProgressDialog(
            message: 'Cancelling Request, Please Wait...'));

    Map<String, dynamic> updateFields = new Map();

    updateFields[RideRequest.FIELD_CLIENT_TRIGGERED_EVENT] = true;
    updateFields[RideRequest.FIELD_CANCEL_SOURCE] =
        RideRequest.CANCEL_SOURCE_CUSTOMER;
    updateFields[RideRequest.FIELD_CANCEL_SOURCE_TRIGGER_SOURCE_ID] =
        FirebaseAuth.instance.currentUser!.uid;
    updateFields[RideRequest.FIELD_CANCEL_CODE] =
        _reasonsList[reasonIndex].reasonCode;
    updateFields[RideRequest.FIELD_CANCEL_REASON] =
        _reasonsList[reasonIndex].reasonDescription;

    await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_RIDES)
        .doc(widget.rideRequest.documentID)
        .set(updateFields, SetOptions(merge: true));
    // dismiss progress dialog
    Navigator.pop(context);

    dismissCurrentDialog(context);
  }

  void dismissCurrentDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop(0);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double edgePadding = screenWidth * 0.10 / 2.0; // 10% of screen width

    double HORIZONTAL_PADDING = 15.0;

    return Dialog(
      elevation: 2.0,
      insetPadding: EdgeInsets.symmetric(horizontal: edgePadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dialog Header
          Container(
            color: Colors.teal.shade600,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'Cancelling Request?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _reasonsList.length,
              separatorBuilder: (_, __) => greyVerticalDivider(0.5),
              itemBuilder: (context, index) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setCancellationReason(context, index);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 25.0),
                    child: Text(
                      _reasonsList[index].reasonDescription,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 5.0),

          // Dismiss Btn
          Container(
            padding: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
                backgroundColor: Colors.grey.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35.0),
                ),
              ),
              onPressed: () {
                dismissCurrentDialog(context);
              },
              child: Container(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Dismiss',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Open Sans',
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5.0),
        ],
      ),
    );
  }
}

class _CancellationReason {
  String reasonDescription;
  int reasonCode;

  _CancellationReason(
      {required this.reasonDescription, required this.reasonCode});
}
