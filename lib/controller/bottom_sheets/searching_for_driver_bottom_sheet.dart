import 'package:flutter/material.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SearchingForDriverBottomSheet extends BaseBottomSheet {
  static const String KEY = 'SearchingForDriverBottomSheet';

  static const double HEIGHT_SEARCHING_FOR_DRIVER_PERCENT = 0.25;
  static const double TOP_CORNER_BORDER_RADIUS = 22.0;

  SearchingForDriverBottomSheet({
    Key? key,
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback actionCallback,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: showBottomSheet,
          onActionCallback: actionCallback,
        );

  @override
  double bottomSheetHeight(BuildContext context) {
    double sheetHeight = MediaQuery.of(context).size.height *
        HEIGHT_SEARCHING_FOR_DRIVER_PERCENT;

    return sheetHeight;
  }

  @override
  double topCornerRadius(BuildContext context) {
    return TOP_CORNER_BORDER_RADIUS;
  }

  @override
  State<StatefulWidget> buildState() {
    return new _SearchingForDriverBottomSheetState();
  }
}

class _SearchingForDriverBottomSheetState
    extends State<SearchingForDriverBottomSheet>
    implements BottomSheetWidgetBuilder {
  @override
  Widget buildContent(BuildContext context) {
    double HSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.width;
    }

    double VSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.height;
    }

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          SizedBox(height: 12.0),
          SizedBox(
              width: double.infinity,
              child: Text(
                  SafeLocalizations.of(context)!
                      .bottom_sheet_searching_for_driver_progress,
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))),
          SizedBox(height: 22.0),
          // Cancel Ride
          GestureDetector(
            onTap: () {
              widget.onActionCallback();
            },
            child: Container(
              child: SpinKitFadingCircle(itemBuilder: (_, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: index.isEven ? Color.fromRGBO(153, 0, 0, 1) : Color.fromRGBO(221, 0, 0, 1),
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: 10.0),

          Container(
            width: double.infinity,
            child: Text(
                SafeLocalizations.of(context)!
                    .bottom_sheet_searching_for_driver_cancel_ride,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.0)),
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
