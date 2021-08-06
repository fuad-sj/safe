import 'package:flutter/material.dart';
import 'package:safe/controller/ui_helpers.dart';
import 'package:safe/models/ride_request.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';

class TripCompletionDialog extends StatefulWidget {
  static final String DIALOG_RESULT_OKAY_PRESSED = "dialog_result_okay_pressed";

  final RideRequest rideRequest;

  const TripCompletionDialog({required this.rideRequest});

  @override
  _TripCompletionDialogState createState() => _TripCompletionDialogState();
}

class _TripCompletionDialogState extends State<TripCompletionDialog> {
  Widget _getTripSummaryWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.0),

        // Total fare price
        Center(child: Text('Total', style: TextStyle(fontSize: 18.0))),
        SizedBox(height: 10.0),
        Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AlphaNumericUtil.formatDouble(
                    widget.rideRequest.actual_trip_fare!, 2),
                style: TextStyle(fontSize: 30.0),
              ),
              SizedBox(width: 5.0),
              Text(
                'Birr',
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
            Icon(Icons.location_on, color: Colors.orangeAccent),
            SizedBox(width: 15.0),
            Text(
              widget.rideRequest.pickup_address_name,
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
            Icon(Icons.location_on, color: Colors.orangeAccent),
            SizedBox(width: 15.0),
            Text(
              widget.rideRequest.dropoff_address_name,
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
              'Base Fare',
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
            Icon(Icons.location_on, color: Colors.orangeAccent),
            SizedBox(width: 5.0),
            Text(
              'Distance Travelled',
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
            Icon(Icons.timer, color: Colors.orangeAccent),
            SizedBox(width: 5.0),
            Text(
              'Ride Time',
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
            Icon(Icons.attach_money_outlined, color: Colors.orangeAccent),
            SizedBox(width: 5.0),
            Text(
              'Total Trip Fare',
              style: TextStyle(fontSize: 12.0),
            ),
            Expanded(child: Container()),
            Text(
              '${AlphaNumericUtil.formatDouble(widget.rideRequest.actual_trip_fare!, 2)} birr',
              style: TextStyle(fontSize: 12.0),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        greyVerticalDivider(0.4),
      ],
    );
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
                'Trip Completed',
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
            child: _getTripSummaryWidget(),
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
                      // pop off the dialog
                      Navigator.pop(context,
                          TripCompletionDialog.DIALOG_RESULT_OKAY_PRESSED);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrangeAccent),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      width: double.infinity,
                      child: Center(
                        child: Text('DONE',
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
