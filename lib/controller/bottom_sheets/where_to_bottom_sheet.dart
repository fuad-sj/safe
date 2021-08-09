import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class WhereToBottomSheet extends BaseBottomSheet {
  static const String KEY = 'WhereToBottomSheet';

  static const double HEIGHT_WHERE_TO = 190.0;
  static const double TOP_CORNER_BORDER_RADIUS = 22.0;

  WhereToBottomSheet({
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback actionCallback,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: showBottomSheet,
          onActionCallback: actionCallback,
        );

  @override
  double bottomSheetHeight() {
    return HEIGHT_WHERE_TO;
  }

  @override
  double topCornerRadius() {
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6.0),

          //
          Text(SafeLocalizations.of(context)!.bottom_sheet_where_to_where_to,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              )),

          // Add home address
          SizedBox(height: 15.0),
          Text(Provider.of<PickUpAndDropOffLocations>(context)
                  .pickUpLocation
                  ?.placeName ??
              SafeLocalizations.of(context)!.bottom_sheet_where_to_current_location),
          SizedBox(height: 25.0),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
              backgroundColor: Colors.orange.shade800,
              textStyle: const TextStyle(fontSize: 20, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35.0),
              ),
            ),
            onPressed: () {
              widget.onActionCallback();
            },
            child: Text(
              SafeLocalizations.of(context)!.bottom_sheet_where_to_enter_destination,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Open Sans',
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.wrapContent(context, buildContent);
  }
}
