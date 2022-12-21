import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/models/color_constants.dart';
import 'package:safe/models/driver.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:safe/utils/phone_call.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DriverPickedBottomSheet extends BaseBottomSheet {
  static const String KEY = 'DriverPickedBottomSheet';

  static const double HEIGHT_DRIVER_PICKED_PERCENT = 0.20;
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
    double sheetHeight =
        MediaQuery.of(context).size.height * HEIGHT_DRIVER_PICKED_PERCENT;

    return sheetHeight;
  }

  @override
  double topCornerRadius(BuildContext context) {
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
    double HSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.width;
    }

    double VSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.height;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 17.0, horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
              child: Container(
                  margin: EdgeInsets.only(top: VSpace(0.005)),
                  width: 30.0,
                  height: 2.0,
                  color: Colors.grey.shade700)),
          // SizedBox(height: VSpace(0.034)),

          Text('Waiting for Driver Respond...',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          SizedBox(height: 22.0),
          GestureDetector(
            onTap: () {
              widget.onActionCallback();
            },
            child: Container(
              child: SpinKitFadingCube(itemBuilder: (_, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? Color.fromRGBO(221, 0, 0, 1)
                        : Color.fromRGBO(153, 0, 0, 1),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 15.0),
          Container(
            width: double.infinity,
            child: Text(
                SafeLocalizations.of(context)!
                    .bottom_sheet_searching_for_driver_cancel_ride,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.0)),
          ),

          /*
          Row(
            children: [
              Image.asset('images/car_side.png', height: 70.0, width: 80.0),
              SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('${widget.pickedDriver!.car_model}',
                          style:
                              TextStyle(color: Colors.black54, fontSize: 12.0)),
                      SizedBox(width: 4.0),
                      Text('${widget.pickedDriver!.car_number}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 14.0)),
                    ],
                  ),
                ],
              ),
            ],
          ),

           */
          /*
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

           */
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.wrapContent(context, buildContent);
  }
}
