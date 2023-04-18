import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/controller/shared_rides_screen.dart';
import 'package:safe/models/color_constants.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../dialogs/shared_trip_dialog.dart';
import '../shared_ride_where_to_go_screen.dart';
import '../way_to_driver_compass_screen.dart';

class WhereToBottomSheet extends BaseBottomSheet {
  static const String KEY = 'WhereToBottomSheet';

  static const double HEIGHT_WHERE_TO_RECOMMENDED_HEIGHT = 180;
  static const double HEIGHT_WHERE_TO_PERCENT = 0.35;
  static const double TOP_CORNER_BORDER_RADIUS = 25.0;

  bool enableButtonSelection;
  bool enabledBottomToggle;
  VoidCallback onDisabledCallback;
  String? referralCode;
  String? customerName;

  WhereToBottomSheet({
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback actionCallback,
    required callBackDestination,
    required this.enableButtonSelection,
    required this.onDisabledCallback,
    required this.enabledBottomToggle,
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
      padding: EdgeInsets.symmetric(horizontal: HSpace(0.07)),
      height: VSpace(0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: VSpace(0.02)),
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (widget.enabledBottomToggle) {
                  widget.onActionCallback();
                } else {
                  widget.onDisabledCallback();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Color(0xffDD0000)),
                margin: EdgeInsets.only(top: VSpace(0.005)),
                width: HSpace(0.12),
                height: VSpace(0.01),
              ),
            ),
          ),
          SizedBox(height: VSpace(0.016)),
          Container(
            child: Row(
              children: [
                Text(
                  SafeLocalizations.of(context)!
                          .bottom_sheet_where_to_hello_there +
                      (widget.customerName != null
                          ? ', ${widget.customerName!}'
                          : ''),
                  style: TextStyle(
                    fontSize: 25.0,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                    color: Color(0xff515151),
                  ),
                ),
                /*
                Spacer(),
                FloatingActionButton.small(
                    onPressed: () async {
                      await showDialog<String>(
                          barrierDismissible: false,
                          context: context,
                        /*
                        *  to do conditional dialog before and after launch
                        *  */
                        // builder: (_) => ShowSharedDialog()
                          builder: (_) => WayToDriverCompassDialog()

                      );
                    },
                  child: CircleAvatar(
                    backgroundColor: Color(0xffDD0000),
                    child: ImageIcon(AssetImage('images/people_gather.png'), color: Colors.white, size: 26.0),
                  ),

                ),

                 */
              ],
            ),
          ),
          SizedBox(height: VSpace(0.005)),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {

              /*
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SharedRidesScreen()),
              );
               */

              Navigator.push(context,
                MaterialPageRoute(builder: (context) => SharedRideWhereToGoScreen()),
              );

            },
            child: Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.085,
                child: Image(
                  image: AssetImage('images/yegna.png'),
                ),
              ),
            ),
          ),
          SizedBox(height: VSpace(0.020)),
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
              height: MediaQuery.of(context).size.height * 0.044,
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: VSpace(0.05), width: HSpace(0.03)),
                  Icon(Icons.search_sharp,
                      color: widget.enableButtonSelection
                          ? Color(0xffDD0000)
                          : Colors.grey.shade700),
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
                          Text('Your home location',
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
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {},
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Text('Work',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontFamily: 'Lato',
                                    color: Color.fromRGBO(221, 0, 0, 1))),
                            SizedBox(height: VSpace(0.001)),
                            Text('Your work location',
                                style: TextStyle(
                                    fontSize: 9.0,
                                    fontFamily: 'Lato',
                                    color: Color.fromRGBO(81, 81, 81, 1)))
                          ],
                        ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          await Clipboard.setData(
                              ClipboardData(text: widget.referralCode!));

                          Fluttertoast.showToast(
                            msg: "Referral Copied\n${widget.referralCode!}",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey.shade700,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: HSpace(0.015),
                              horizontal: HSpace(0.02)),
                          child: Icon(Icons.copy, color: Color(0xFFDE0000)),
                        ),
                      ),

                      Text(
                          (widget.referralCode != null
                              ? ' ${widget.referralCode!}'
                              : ''),
                          style: TextStyle(
                              fontSize: 25.0,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w900,
                              color: Color.fromRGBO(221, 0, 0, 1))),

                      //referal code copy
                      Container(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            try {
                              String? headerText = 'HI\n';
                              String? textBody =
                                  'Safe , you can enjoy a 5% cash back bonus whenever you make an order.\n'
                                  'Plus, you can also share the app with your friends and family so they can enjoy the same benefits - and for every person that signs up through your referral code, you’ll get an additional 2% from every trip They make!\n '
                                  'Now It’s easy to get paid. Just download the Safe app:- https://onelink.to/s9kbx2\n';
                              String? referralCode =
                                  'Use This referral Code :- ${widget.referralCode!} ';

                              Share.share(headerText + textBody + referralCode);
                            } catch (err) {}
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: HSpace(0.015),
                                horizontal: HSpace(0.02)),
                            child: Icon(Icons.share, color: Color(0xFFDE0000)),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: VSpace(0.002)),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.wrapContent(context, buildContent);
  }
}
