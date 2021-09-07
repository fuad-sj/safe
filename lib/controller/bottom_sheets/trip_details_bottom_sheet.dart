import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/controller/ui_helpers.dart';
import 'package:safe/models/driver.dart';
import 'package:safe/models/ride_request.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class TripDetailsBottomSheet extends BaseBottomSheet {
  static const String KEY = 'TripDetailsBottomSheet';

  static const double HEIGHT_TRIP_DETAILS_PERCENT = 0.4;
  static const double TOP_CORNER_BORDER_RADIUS = 14.0;

  RideRequest? rideRequest;
  Driver? pickedDriver;

  LatLng? tripStartedLocation;
  Timer? tripCounterTimer;
  DateTime? tripStartTimestamp;

  Position? currentPosition;

  TripDetailsBottomSheet({
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback actionCallback,
    required this.tripStartedLocation,
    required this.tripCounterTimer,
    required this.tripStartTimestamp,
    required this.currentPosition,
    required this.rideRequest,
    required this.pickedDriver,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: showBottomSheet,
          onActionCallback: actionCallback,
        );

  @override
  double bottomSheetHeight(BuildContext context) {
    double sheetHeight =
        MediaQuery.of(context).size.height * HEIGHT_TRIP_DETAILS_PERCENT;
    return sheetHeight;
  }

  @override
  double topCornerRadius(BuildContext context) {
    return TOP_CORNER_BORDER_RADIUS;
  }

  @override
  State<StatefulWidget> buildState() {
    return new _TripDetailsBottomSheetState();
  }
}

class _TripDetailsBottomSheetState extends State<TripDetailsBottomSheet>
    implements BottomSheetWidgetBuilder {
  @override
  Widget buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.0),

          // Dropoff Location
          greyVerticalDivider(0.4),
          SizedBox(height: 10.0),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.orangeAccent),
              SizedBox(width: 15.0),
              Text(
                widget.rideRequest!.dropoff_address_name,
                style: TextStyle(fontSize: 14.0),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          greyVerticalDivider(0.4),

          // Trip Details(Km + Time)
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Km Covered
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${getKMCovered()} Km',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2.0),
                  Row(
                    children: [
                      Icon(Icons.directions, color: Colors.orangeAccent),
                      SizedBox(width: 10.0),
                      Text(
                        SafeLocalizations.of(context)!
                            .bottom_sheet_trip_details_distance_covered,
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                ],
              ),

              Expanded(child: Container(height: 1)),

              // Time details
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${AlphaNumericUtil.formatDuration(DateTime.now().difference(widget.tripStartTimestamp!))}',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2.0),
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.orangeAccent),
                      SizedBox(width: 10.0),
                      Text(
                        SafeLocalizations.of(context)!
                            .bottom_sheet_trip_details_ride_time,
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.0),
          greyVerticalDivider(0.4),
        ],
      ),
    );
  }

  String getKMCovered() {
    double kmCovered = Geolocator.distanceBetween(
          widget.tripStartedLocation!.latitude,
          widget.tripStartedLocation!.longitude,
          widget.currentPosition!.latitude,
          widget.currentPosition!.longitude,
        ) /
        1000.0;
    return AlphaNumericUtil.formatDouble(kmCovered, 1);
  }

  @override
  Widget build(BuildContext context) {
    return widget.wrapContent(context, buildContent);
  }
}
