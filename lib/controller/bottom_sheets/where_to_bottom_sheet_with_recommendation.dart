import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/models/color_constants.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class WhereToBottomSheetWithRecommendation extends BaseBottomSheet {
  static const String KEY = 'WhereToBottomSheet';

  static const double HEIGHT_WHERE_TO_RECOMMENDED_HEIGHT = 180;
  static const double HEIGHT_WHERE_TO_PERCENT = 0.35;
  static const double TOP_CORNER_BORDER_RADIUS = 25.0;

  String? referralCode;
  String? customerName;
  VoidCallback onWhereRecommendationToSelected;

  WhereToBottomSheetWithRecommendation({
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback actionCallback,
    required this.onWhereRecommendationToSelected,
    this.referralCode,
    this.customerName,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: showBottomSheet,
          onActionCallback: actionCallback,
        );

  @override
  double bottomSheetHeight(BuildContext context) {
    double sheetHeight = MediaQuery.of(context).size.height * 0.35;

    return sheetHeight;
  }

  @override
  double topCornerRadius(BuildContext context) {
    return TOP_CORNER_BORDER_RADIUS;
  }

  @override
  State<StatefulWidget> buildState() {
    return new _WhereToBottomSheetWithRecommendationState();
  }
}

class _WhereToBottomSheetWithRecommendationState extends State<WhereToBottomSheetWithRecommendation>
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
      padding: EdgeInsets.symmetric(horizontal: HSpace(0.07)),
      height: VSpace(0.65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: VSpace(0.02)),
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {

              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color:Color(0xffDD0000)),
                margin: EdgeInsets.only(
                  top: VSpace(0.005),
                ),
                width: HSpace(0.12),
                height: VSpace(0.01),
              ),
            ),
          ),

          SizedBox(height: VSpace(0.036)),

          Text(
              SafeLocalizations.of(context)!.bottom_sheet_where_to_hello_there +
                  (widget.customerName != null
                      ? ', ${widget.customerName!}'
                      : ''),
              style: TextStyle(
                  fontSize: 25.0,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold,
                  color: Color(0xff515151))),

          SizedBox(height: VSpace(0.030)),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Container(
              height: MediaQuery.of(context).size.height * 0.044,
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: VSpace(0.05), width: HSpace(0.03)),
                  Icon(Icons.search_sharp, color : Color(0xffDD0000)),
                  SizedBox(width: HSpace(0.05)),
                  Text(
                      SafeLocalizations.of(context)!
                          .bottom_sheet_where_to_where_are_you_going,
                      style: TextStyle(fontFamily: 'Lato')),
                ],
              ),
            ),
          ),
          SizedBox(height: VSpace(0.038)),
          Container(
              height: VSpace(0.056),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Text('Home',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: 'Lato',
                                  color: Color.fromRGBO(221, 0, 0, 1))),
                          SizedBox(height: VSpace(0.001)),
                          Text('your home location',
                              style: TextStyle(
                                  fontSize: 9.0,
                                  fontFamily: 'Lato',
                                  color: Color.fromRGBO(81, 81, 81, 1)))
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 2.0,
                    color: Color.fromRGBO(151, 151, 151, 0.3),
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Text('Work',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: 'Lato',
                                  color: Color.fromRGBO(221, 0, 0, 1))),
                          SizedBox(height: VSpace(0.001)),
                          Text('your Work location',
                              style: TextStyle(
                                  fontSize: 9.0,
                                  fontFamily: 'Lato',
                                  color: Color.fromRGBO(81, 81, 81, 1)))
                        ],
                      ),
                    ),
                  )
                ],
              )),

          SizedBox(height: VSpace(0.023)),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: HSpace(0.03)),
              child: Column(
                children: <Widget>[
                  Text(
                      (widget.referralCode != null
                          ? ' ${widget.referralCode!}'
                          : ''),
                      style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Lato',
                          color: Color.fromRGBO(221, 0, 0, 1))),
                  SizedBox(height: VSpace(0.001)),
                  Text(
                    'Invite your friends with this referral code and make money.',
                    style: TextStyle(
                        fontSize: 8.0,
                        fontFamily: 'Lato',
                        color: Color.fromRGBO(81, 81, 81, 1)),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: VSpace(0.01)),
          Container(
            width: HSpace(0.9),
            height: VSpace(0.002),
            color: Color.fromRGBO(229, 229, 229, 1),
          )

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