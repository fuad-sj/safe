import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/models/color_constants.dart';
import 'package:safe/models/route_details.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class ConfirmRideDetailsBottomSheet extends BaseBottomSheet {
  static const String KEY = 'ConfirmRideDetailsBottomSheet';

  static const double HEIGHT_RIDE_DETAILS_PERCENT = 0.43;
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
  double bottomSheetHeight(BuildContext context) {
    double sheetHeight =
        MediaQuery.of(context).size.height * HEIGHT_RIDE_DETAILS_PERCENT;

    return sheetHeight;
  }

  @override
  double topCornerRadius(BuildContext context) {
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
  static const int CAR_TYPE_ANY = 1;
  static const int CAR_TYPE_MINIVAN = 2;
  static const int CAR_TYPE_MINIBUS = 3;

  int _selectedCarType = CAR_TYPE_ANY;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildContent(BuildContext context) {
    double HSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.width;
    }

    double VSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.height;
    }

    Color _getCheckboxColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return ColorConstants.gucciColor;
    }

    Widget _getCarTypeWidget(int carType) {
      String carImage, typeDescription;

      switch (carType) {
        case CAR_TYPE_MINIVAN:
          carImage = 'images/minivan_safe.png';
          typeDescription = SafeLocalizations.of(context)!
              .bottom_sheet_confirm_ride_details_minivan;
          break;
        case CAR_TYPE_MINIBUS:
          carImage = 'images/minbus_safe.png';
          typeDescription = SafeLocalizations.of(context)!
              .bottom_sheet_confirm_ride_details_minibus;
          break;
        case CAR_TYPE_ANY:
        default:
          carImage = 'images/economy.png';
          typeDescription = SafeLocalizations.of(context)!
              .bottom_sheet_confirm_ride_details_car;
          break;
      }

      bool isSelected = carType == _selectedCarType;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedCarType = carType;
          });
        },
        child: Container(
          color: isSelected
              ? ColorConstants.lyftColor.withOpacity(0.1)
              : Colors.white,
          width: double.infinity,
          child: Row(
            children: [
              Container(
                width: HSpace(0.015),
                height: VSpace(0.07),
                color: isSelected ? ColorConstants.lyftColor : Colors.white,
              ),
              SizedBox(width: 16.0),
              Image.asset(carImage, height: VSpace(0.05), width: 80.0),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(typeDescription,
                      style: TextStyle(
                          fontSize: 18.0,
                          fontFamily: 'Brand-Bold',
                          fontWeight: (isSelected
                              ? FontWeight.bold
                              : FontWeight.normal))),
                  Text(
                      widget.routeDetails!.distanceText +
                          ' in ' +
                          widget.routeDetails!.durationText,
                      style: TextStyle(fontSize: 16.0, color: Colors.grey)),
                ],
              ),
              Expanded(child: Container()),
              Text(
                '~ ' +
                    AlphaNumericUtil.formatDouble(
                        widget.routeDetails!.estimatedFarePrice *
                            (carType == CAR_TYPE_MINIVAN
                                ? 1.1
                                : (carType == CAR_TYPE_MINIBUS ? 1.03 : 1)),
                        0) +
                    ' ' +
                    SafeLocalizations.of(context)!
                        .bottom_sheet_confirm_ride_details_etb,
                style: TextStyle(
                  fontFamily: 'Brand-Bold',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: HSpace(0.05))
            ],
          ),
        ),
      );
    }

    return Container(
      // padding: EdgeInsets.symmetric(horizontal: HSpace(0.00)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
              child: Container(
                  margin: EdgeInsets.only(top: VSpace(0.005)),
                  width: 100.0,
                  height: 4.0,
                  color: Colors.grey.shade700)),
          ...[CAR_TYPE_ANY, CAR_TYPE_MINIVAN, CAR_TYPE_MINIBUS]
              .map((e) => _getCarTypeWidget(e)),
          Row(
            children: [
              SizedBox(width: HSpace(0.05)),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 35.0, vertical: VSpace(0.02)),
                    backgroundColor: _selectedCarType == CAR_TYPE_ANY
                        ? ColorConstants.lyftColor
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  onPressed: () {
                    if (_selectedCarType == CAR_TYPE_ANY) {
                      widget.onActionCallback();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        SafeLocalizations.of(context)!
                            .bottom_sheet_confirm_ride_details_confirm_request,
                        overflow: TextOverflow.ellipsis,
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
              SizedBox(width: 20.0),
              /*


              GestureDetector(
                onTap: () {
                  DateTime now = DateTime.now();
                  showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: now,
                          // allow upto 30 days into the future
                          lastDate: now.add(Duration(days: 30)))
                      .then((pickedDate) {
                    if (pickedDate == null) {
                      Provider.of<PickUpAndDropOffLocations>(context,
                              listen: false)
                          .updateScheduledDuration(null);
                    } else {
                      showTimePicker(
                        context: context,
                        initialTime:
                            TimeOfDay(hour: now.hour, minute: now.minute),
                      ).then((pickedTime) {
                        if (pickedTime == null) {
                          Provider.of<PickUpAndDropOffLocations>(context,
                                  listen: false)
                              .updateScheduledDuration(null);
                        } else {
                          DateTime scheduledTime = new DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute);

                          Duration bookingDuration =
                              scheduledTime.difference(now);

                          Provider.of<PickUpAndDropOffLocations>(context,
                                  listen: false)
                              .updateScheduledDuration(
                                  bookingDuration.inSeconds < 0
                                      ? null
                                      : bookingDuration);
                        }
                      });
                    }
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: CircleAvatar(
                  backgroundColor:
                      Provider.of<PickUpAndDropOffLocations>(context)
                                  .scheduledDuration !=
                              null
                          ? Colors.pinkAccent
                          : Colors.grey.shade500,
                  child: Icon(Icons.date_range,
                      color: Colors.white, size: 26.0),
                  radius: 25.0,
                ),
              ),

               */

              //       SizedBox(width: HSpace(0.05)),
            ],
          ),
          SizedBox(height: VSpace(0.01)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.wrapContent(context, buildContent);
  }
}
