import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/controller/ui_helpers.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/color_constants.dart';
import 'package:safe/models/driver.dart';
import 'package:safe/models/ride_request.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TripCompletionDialog extends StatefulWidget {
  static final String DIALOG_RESULT_OKAY_PRESSED = "dialog_result_okay_pressed";

  final RideRequest rideRequest;

  const TripCompletionDialog({required this.rideRequest});

  @override
  _TripCompletionDialogState createState() => _TripCompletionDialogState();
}

class _TripCompletionDialogState extends State<TripCompletionDialog> {
  TextEditingController _commentController = TextEditingController();

  double _driverRating = 5.0;
  late String _dropOffLocation;
  late String _startLocation;

  bool get hasStudentDiscount {
    return (widget.rideRequest.has_student_discount ?? false) == true;
  }

  double get actualPaidAmount {
    return hasStudentDiscount
        ? widget.rideRequest.adjusted_trip_fare!
        : widget.rideRequest.actual_trip_fare!;
  }

  Widget _getTripSummaryWidget(BuildContext context) {

    if (widget.rideRequest.pickup_location != null ) {
      _startLocation= widget.rideRequest.pickup_location as String;
    }
    else {
      _startLocation = "";
    }


    if (widget.rideRequest.dropoff_location != null ) {
      _dropOffLocation = widget.rideRequest.dropoff_location as String;
    }
    else {
      _dropOffLocation = "";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.0),

        // Total fare price
        Center(
            child: Text(
                SafeLocalizations.of(context)!.dialog_trip_summary_total,
                style: TextStyle(fontSize: 18.0))),
        SizedBox(height: 10.0),
        Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AlphaNumericUtil.formatDouble(actualPaidAmount, 2),
                style: TextStyle(fontSize: 30.0),
              ),
              SizedBox(width: 5.0),
              Text(
                SafeLocalizations.of(context)!.dialog_trip_summary_birr,
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Pickup location
        SizedBox(height: 5.0),
        greyVerticalDivider(0.4),
        SizedBox(height: 10.0),
        Row(
          children: [
            Icon(Icons.location_on, color: ColorConstants.appThemeColor),
            SizedBox(width: 15.0),
            Text(
              _startLocation,
              style: TextStyle(fontSize: 14.0),
            ),
          ],
        ),
        SizedBox(height: 10.0),

        // Dropoff location
        greyVerticalDivider(0.4),
        SizedBox(height: 10.0),
        Row(
          children: [
            Icon(Icons.location_on, color: ColorConstants.appThemeColor),
            SizedBox(width: 15.0),
            Text(
              _dropOffLocation,
              style: TextStyle(fontSize: 14.0),
            ),
          ],
        ),
        SizedBox(height: 10.0),

        // Base Fare
        greyVerticalDivider(0.4),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              SafeLocalizations.of(context)!.dialog_trip_summary_base_fare,
              style: TextStyle(fontSize: 12.0),
            ),
            Expanded(child: Container()),
            Text(
              AlphaNumericUtil.formatDouble(widget.rideRequest.base_fare!, 2),
              style: TextStyle(fontSize: 12.0),
            ),
          ],
        ),
        SizedBox(height: 10.0),

        // Distance travelled
        greyVerticalDivider(0.4),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.location_on, color: ColorConstants.appThemeColor),
            SizedBox(width: 5.0),
            Text(
              SafeLocalizations.of(context)!
                  .dialog_trip_summary_distance_travelled,
              style: TextStyle(fontSize: 12.0),
            ),
            Expanded(child: Container()),
            Text(
              '${AlphaNumericUtil.formatDouble(widget.rideRequest.actual_trip_kilometers!, 1)} km',
              style: TextStyle(fontSize: 12.0),
            ),
          ],
        ),
        SizedBox(height: 10.0),

        // Ride Time
        greyVerticalDivider(0.4),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.timer, color: ColorConstants.appThemeColor),
            SizedBox(width: 5.0),
            Text(
              SafeLocalizations.of(context)!.dialog_trip_summary_ride_time,
              style: TextStyle(fontSize: 12.0),
            ),
            Expanded(child: Container()),
            Text(
              '${AlphaNumericUtil.formatDouble(widget.rideRequest.actual_trip_minutes!, 0)} minutes',
              style: TextStyle(fontSize: 12.0),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        greyVerticalDivider(0.4),

        // Total Trip Fare
        greyVerticalDivider(0.4),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.attach_money_outlined, color: ColorConstants.appThemeColor),
            SizedBox(width: 5.0),
            Text(
              SafeLocalizations.of(context)!
                  .dialog_trip_summary_total_trip_fare,
              style: TextStyle(fontSize: 12.0),
            ),
            Expanded(child: Container()),
            Text(
              '${AlphaNumericUtil.formatDouble(widget.rideRequest.actual_trip_fare!, 2)} ' +
                  SafeLocalizations.of(context)!.dialog_trip_summary_birr,
              style: TextStyle(fontSize: 12.0),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        greyVerticalDivider(0.4),

        if (hasStudentDiscount) ...[
          // Student Discount
          greyVerticalDivider(0.4),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.attach_money_outlined,
                  color: ColorConstants.appThemeColor),
              SizedBox(width: 5.0),
              Text(
                SafeLocalizations.of(context)!
                    .dialog_trip_summary_student_discount,
                style: TextStyle(fontSize: 12.0),
              ),
              Expanded(child: Container()),
              Text(
                '${AlphaNumericUtil.formatDouble(widget.rideRequest.student_discount!, 2)} birr',
                style: TextStyle(fontSize: 12.0),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          greyVerticalDivider(0.4),

          // Discounted Price
          greyVerticalDivider(0.4),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.attach_money_outlined,
                  color: ColorConstants.appThemeColor),
              SizedBox(width: 5.0),
              Text(
                SafeLocalizations.of(context)!
                    .dialog_trip_summary_discounted_trip_fare,
                style: TextStyle(fontSize: 12.0),
              ),
              Expanded(child: Container()),
              Text(
                '${AlphaNumericUtil.formatDouble(widget.rideRequest.adjusted_trip_fare!, 2)} birr',
                style: TextStyle(fontSize: 12.0),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          greyVerticalDivider(0.4),
        ],

        greyVerticalDivider(0.4),
        SizedBox(height: 10.0),
        Text(
          SafeLocalizations.of(context)!.dialog_trip_summary_rate_your_driver,
          style: TextStyle(fontSize: 12.0),
        ),

        // TODO: populate stars
        greyVerticalDivider(0.4),
        SizedBox(height: 10.0),
        Center(
          child: RatingBar.builder(
            initialRating: 5,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (double rating) {
              _driverRating = rating;
            },
          ),
        ),
        SizedBox(height: 10.0),
        greyVerticalDivider(0.4),

        // Comment
        greyVerticalDivider(0.4),
        SizedBox(height: 10.0),
        TextField(
          keyboardType: TextInputType.text,
          controller: _commentController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white, width: 2.0),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            labelText: SafeLocalizations.of(context)!
                .dialog_trip_summary_leave_comment,
            //labelStyle: TextStyle(color: Colors.white),
            hintText: SafeLocalizations.of(context)!
                .dialog_trip_summary_leave_comment_hint,
            //hintStyle: TextStyle(color: Colors.grey),
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 10.0),
        greyVerticalDivider(0.4),
      ],
    );
  }

  Future<void> updateRatingAndComment() async {
    Driver driver = Driver.fromSnapshot(
      await FirebaseFirestore.instance
          .collection(FIRESTORE_PATHS.COL_DRIVERS)
          .doc(widget.rideRequest.driver_id)
          .get(),
    );

    double previous_rating = driver.driver_rating ?? 0;
    int num_ratings = driver.num_rating ?? 0;

    double new_computed_rating =
        (previous_rating * (num_ratings + 0.0) + _driverRating) /
            (num_ratings + 1.0);

    num_ratings++;

    Map<String, dynamic> driverFields = Map();

    driverFields[Driver.FIELD_DRIVER_RATING] = new_computed_rating;
    driverFields[Driver.FIELD_NUM_RATING] = num_ratings;

    await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_DRIVERS)
        .doc(widget.rideRequest.driver_id)
        .set(driverFields, SetOptions(merge: true));

    String comment = _commentController.text.trim();
    Map<String, dynamic> rideFields = Map();

    rideFields[RideRequest.FIELD_CLIENT_TRIGGERED_EVENT] = false;
    rideFields[RideRequest.FIELD_CUSTOMER_COMMENT] = comment;

    await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_RIDES)
        .doc(widget.rideRequest.documentID)
        .set(rideFields, SetOptions(merge: true));
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
            color: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                SafeLocalizations.of(context)!
                    .dialog_trip_summary_trip_completed,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
            child: _getTripSummaryWidget(context),
          ),
          SizedBox(height: 5.0),

          // Done Trip
          Container(
            padding: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => CustomProgressDialog(
                            message: "Please wait..."),
                      );

                      await updateRatingAndComment();

                      // pop off progress dialog
                      Navigator.pop(context);

                      // pop off container trip summary dialog
                      Navigator.pop(context,
                          TripCompletionDialog.DIALOG_RESULT_OKAY_PRESSED);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: ColorConstants.appThemeColor),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      width: double.infinity,
                      child: Center(
                        child: Text(
                            SafeLocalizations.of(context)!
                                .dialog_trip_summary_done,
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
