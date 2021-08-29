import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/models/color_constants.dart';
import 'package:safe/models/driver.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:safe/utils/phone_call.dart';

class DriverPickedBottomSheet extends BaseBottomSheet {
  static const String KEY = 'DriverPickedBottomSheet';

  static const double HEIGHT_DRIVER_PICKED = 180.0;
  static const double TOP_CORNER_BORDER_RADIUS = 14.0;

  Driver? pickedDriver;

  DriverPickedBottomSheet({
    Key? key,
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback actionCallback,
    required this.pickedDriver,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: showBottomSheet,
          onActionCallback: actionCallback,
        );

  @override
  double bottomSheetHeight(BuildContext context) {
    return HEIGHT_DRIVER_PICKED;
  }

  @override
  double topCornerRadius() {
    return TOP_CORNER_BORDER_RADIUS;
  }

  @override
  State<StatefulWidget> buildState() {
    return new _DriverPickedBottomSheetState();
  }
}

class _DriverPickedBottomSheetState extends State<DriverPickedBottomSheet>
    implements BottomSheetWidgetBuilder {
  @override
  Widget buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 17.0, horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, color: Colors.redAccent),
              SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.pickedDriver!.user_name}, ${widget.pickedDriver!.phone_number}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                      '${widget.pickedDriver!.car_color} ${widget.pickedDriver!.car_model}',
                      style: TextStyle(color: Colors.black54, fontSize: 12.0)),
                ],
              ),
              Expanded(child: Container()),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  try {
                    PhoneCaller.callPhone(widget.pickedDriver!.phone_number!);
                  } catch (err) {}
                },
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(Icons.phone, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
              backgroundColor: ColorConstants.gucciColor,
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
                  SafeLocalizations.of(context)!
                      .bottom_sheet_driver_picked_cancel_ride,
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
