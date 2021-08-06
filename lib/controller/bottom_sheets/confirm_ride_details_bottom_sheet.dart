import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/models/route_details.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';

class ConfirmRideDetailsBottomSheet extends BaseBottomSheet {
  static const String KEY = 'ConfirmRideDetailsBottomSheet';

  static const double HEIGHT_RIDE_DETAILS = 220.0;
  static const double TOP_CORNER_BORDER_RADIUS = 14.0;

  RouteDetails? routeDetails;

  ConfirmRideDetailsBottomSheet({
    Key? key,
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback actionCallback,
    required this.routeDetails,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: showBottomSheet,
          onActionCallback: actionCallback,
        );

  @override
  double bottomSheetHeight() {
    return HEIGHT_RIDE_DETAILS;
  }

  @override
  double topCornerRadius() {
    return TOP_CORNER_BORDER_RADIUS;
  }

  @override
  State<StatefulWidget> buildState() {
    return new _ConfirmRideDetailsBottomSheetState();
  }
}

class _ConfirmRideDetailsBottomSheetState
    extends State<ConfirmRideDetailsBottomSheet>
    implements BottomSheetWidgetBuilder {
  @override
  Widget buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 17.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            color: Colors.grey.shade50,
            width: double.infinity,
            child: Row(
              children: [
                Image.asset('images/car_side.png', height: 70.0, width: 80.0),
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Car',
                        style: TextStyle(
                            fontSize: 18.0, fontFamily: 'Brand-Bold')),
                    Text(widget.routeDetails!.distanceText,
                        style: TextStyle(fontSize: 16.0, color: Colors.grey)),
                  ],
                ),
                Expanded(child: Container()),
                Text(
                  '~ ' +
                      AlphaNumericUtil.formatDouble(
                          widget.routeDetails!.estimatedFarePrice, 0) +
                      ' ETB',
                  style: TextStyle(
                    fontFamily: 'Brand-Bold',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Cash Option
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FontAwesomeIcons.moneyBill,
                  size: 18.0, color: Colors.black54),
              SizedBox(width: 16.0),
              Text('Cash'),
            ],
          ),

          // Request car
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
              backgroundColor: Colors.orange.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35.0),
              ),
            ),
            onPressed: () {
              widget.onActionCallback();
            },
            child: Container(
              width: double.infinity,
              child: Center(
                child: Text(
                  'Confirm Request',
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.wrapContent(context, buildContent);
  }
}
