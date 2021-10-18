import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/models/color_constants.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class WhereToBottomSheet extends BaseBottomSheet {
  static const String KEY = 'WhereToBottomSheet';

  static const double HEIGHT_WHERE_TO_RECOMMENDED_HEIGHT = 180;
  static const double HEIGHT_WHERE_TO_PERCENT = 0.28;
  static const double TOP_CORNER_BORDER_RADIUS = 8.0;

  bool enableButtonSelection;
  VoidCallback onDisabledCallback;
  String? customerName;

  WhereToBottomSheet({
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback actionCallback,
    required this.enableButtonSelection,
    required this.onDisabledCallback,
    this.customerName,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: showBottomSheet,
          onActionCallback: actionCallback,
        );

  @override
  double bottomSheetHeight(BuildContext context) {
    double sheetHeight =
        MediaQuery.of(context).size.height * HEIGHT_WHERE_TO_PERCENT;

    return sheetHeight;
  }

  @override
  double topCornerRadius(BuildContext context) {
    return TOP_CORNER_BORDER_RADIUS;
  }

  @override
  State<StatefulWidget> buildState() {
    return new _WhereToBottomSheetState();
  }
}

class _WhereToBottomSheetState extends State<WhereToBottomSheet>
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
      padding: EdgeInsets.symmetric(horizontal: HSpace(0.04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Container(
                  margin: EdgeInsets.only(top: VSpace(0.005)),
                  width: 30.0,
                  height: 2.0,
                  color: Colors.grey.shade700)),

          SizedBox(height: VSpace(0.024)),

          //
          Text(
              SafeLocalizations.of(context)!.bottom_sheet_where_to_hello_there +
                  (widget.customerName != null
                      ? ', ${widget.customerName!}'
                      : ''),
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              )),

          SizedBox(height: VSpace(0.015)),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (widget.enableButtonSelection) {
                widget.onActionCallback();
              } else {
                widget.onDisabledCallback();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 1.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.1, 0.7),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: VSpace(0.05), width: HSpace(0.03)),
                  Icon(Icons.search,
                      color: widget.enableButtonSelection
                          ? ColorConstants.lyftColor
                          : Colors.grey.shade700),
                  SizedBox(width: HSpace(0.05)),
                  Text(SafeLocalizations.of(context)!
                      .bottom_sheet_where_to_where_are_you_going),
                ],
              ),
            ),
          ),

          SizedBox(height: VSpace(0.02)),

          Row(
            children: [
              SizedBox(width: HSpace(0.03)),
              Icon(Icons.location_pin,
                  color: widget.enableButtonSelection
                      ? ColorConstants.lyftColor
                      : Colors.grey.shade700),
              SizedBox(width: HSpace(0.05)),
              Text(Provider.of<PickUpAndDropOffLocations>(context)
                      .pickUpLocation
                      ?.placeName ??
                  SafeLocalizations.of(context)!
                      .bottom_sheet_where_to_current_location),
            ],
          ),

          SizedBox(height: VSpace(0.02)),

          Row(
            children: [
              SizedBox(width: HSpace(0.03)),
              Icon(Icons.work,
                  color: widget.enableButtonSelection
                      ? ColorConstants.lyftColor
                      : Colors.grey.shade700),
              SizedBox(width: HSpace(0.05)),
              Text("Work"),
            ],
          ),

          // Add home address
          /*
          SizedBox(height: 15.0),
          Text(Provider.of<PickUpAndDropOffLocations>(context)
                  .pickUpLocation
                  ?.placeName ??
              SafeLocalizations.of(context)!
                  .bottom_sheet_where_to_current_location),
          SizedBox(height: 25.0),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
              backgroundColor: widget.enableButtonSelection
                  ? ColorConstants.lyftColor
                  : Colors.grey.shade700,
              textStyle: const TextStyle(fontSize: 20, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35.0),
              ),
            ),
            onPressed: () {
              if (widget.enableButtonSelection) {
                widget.onActionCallback();
              } else {
                widget.onDisabledCallback();
              }
            },
            child: Text(
              SafeLocalizations.of(context)!
                  .bottom_sheet_where_to_enter_destination,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Open Sans',
              ),
            ),
          )
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
