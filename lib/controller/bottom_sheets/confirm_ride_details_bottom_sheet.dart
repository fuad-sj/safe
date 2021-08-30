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

  static const double HEIGHT_RIDE_DETAILS = 370.0;
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
  static const int CAR_TYPE_ANY = 1;
  static const int CAR_TYPE_MINIVAN = 2;
  static const int CAR_TYPE_MINIBUS = 3;

  bool _isStudent = false;

  int _selectedCarType = CAR_TYPE_ANY;

  @override
  void initState() {
    super.initState();

    Provider.of<PickUpAndDropOffLocations>(context, listen: false)
        .setIsStudent(false); // initially set it to false
  }

  @override
  Widget buildContent(BuildContext context) {
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
          carImage = 'images/minivan.png';
          typeDescription = SafeLocalizations.of(context)!
              .bottom_sheet_confirm_ride_details_minivan;
          break;
        case CAR_TYPE_MINIBUS:
          carImage = 'images/minibus.png';
          typeDescription = SafeLocalizations.of(context)!
              .bottom_sheet_confirm_ride_details_minibus;
          break;
        case CAR_TYPE_ANY:
        default:
          carImage = 'images/car_side.png';
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
          color: isSelected ? Colors.grey.shade100 : Colors.white,
          width: double.infinity,
          child: Row(
            children: [
              Image.asset(carImage, height: 70.0, width: 80.0),
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
                  Text(widget.routeDetails!.distanceText,
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
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 17.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...[CAR_TYPE_ANY, CAR_TYPE_MINIVAN, CAR_TYPE_MINIBUS]
              .map((e) => _getCarTypeWidget(e)),

          // Cash + Is Student
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(SafeLocalizations.of(context)!
                      .bottom_sheet_confirm_ride_details_cash),
                  SizedBox(width: 16.0),
                  Icon(FontAwesomeIcons.moneyBill,
                      size: 18.0, color: Colors.black54),
                ],
              ),
              Expanded(child: Container()),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(SafeLocalizations.of(context)!
                      .bottom_sheet_confirm_ride_details_is_student),
                  Checkbox(
                    checkColor: Colors.white,
                    fillColor:
                        MaterialStateProperty.resolveWith(_getCheckboxColor),
                    value: _isStudent,
                    onChanged: (bool? value) {
                      setState(() {
                        _isStudent = value!;

                        Provider.of<PickUpAndDropOffLocations>(context,
                                listen: false)
                            .setIsStudent(_isStudent);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),

          // Request car
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
              backgroundColor: _selectedCarType == CAR_TYPE_ANY
                  ? ColorConstants.gucciColor
                  : Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35.0),
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
