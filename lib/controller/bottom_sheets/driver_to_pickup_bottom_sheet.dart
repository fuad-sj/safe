import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/models/driver.dart';
import 'package:safe/models/ride_request.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:safe/utils/phone_call.dart';

class DriverToPickupBottomSheet extends BaseBottomSheet {
  static const String KEY = 'DriverToPickupBottomSheet';

  static const double HEIGHT_DRIVER_ON_WAY_TO_PICKUP = 100.0;
  static const double TOP_CORNER_BORDER_RADIUS = 14.0;

  RideRequest? rideRequest;
  Driver? pickedDriver;

  DriverToPickupBottomSheet({
    Key? key,
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback actionCallback,
    required this.rideRequest,
    required this.pickedDriver,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: showBottomSheet,
          onActionCallback: actionCallback,
        );

  @override
  double bottomSheetHeight(BuildContext context) {
    return HEIGHT_DRIVER_ON_WAY_TO_PICKUP;
  }

  @override
  double topCornerRadius() {
    return TOP_CORNER_BORDER_RADIUS;
  }

  @override
  State<StatefulWidget> buildState() {
    return new _DriverToPickupBottomSheetState();
  }
}

class _DriverToPickupBottomSheetState extends State<DriverToPickupBottomSheet>
    implements BottomSheetWidgetBuilder {
  @override
  Widget buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset('images/car_side.png', height: 70.0, width: 80.0),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${widget.pickedDriver!.user_name!}, ${widget.pickedDriver!.phone_number!}'),
                  SizedBox(height: 4.0),
                  Text(
                      '${widget.pickedDriver!.car_color} ${widget.pickedDriver!.car_model}',
                      style: TextStyle(color: Colors.black54, fontSize: 12.0)),
                ],
              ),
              Expanded(child: Container()),
              Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      try {
                        PhoneCaller.callPhone(
                            widget.pickedDriver!.phone_number!);
                      } catch (err) {}
                    },
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(Icons.phone, color: Colors.blue.shade900),
                    ),
                  ),
                  Text(
                    widget.rideRequest!.driver_to_pickup_duration_str!,
                    style: TextStyle(
                      fontFamily: 'Brand-Bold',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.0),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.wrapContent(context, buildContent);
  }
}
