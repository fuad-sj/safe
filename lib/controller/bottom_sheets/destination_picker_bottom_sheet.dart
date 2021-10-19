import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/controller/ui_helpers.dart';
import 'package:safe/models/address.dart';
import 'package:safe/models/color_constants.dart';
import 'package:safe/models/google_place_description.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:safe/utils/google_api_util.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:safe/utils/pref_util.dart';

class DestinationPickerBottomSheet extends BaseBottomSheet {
  static const String KEY = 'DestinationPickerBottomSheet';

  static const double HEIGHT_DESTINATION_SELECTOR_PERCENT = 1.0;
  static const double TOP_CORNER_BORDER_RADIUS = 0.1;

  VoidCallback onSelectPinCalled;
  VoidCallback onDismissDialog;

  DestinationPickerBottomSheet({
    Key? key,
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback callback,
    required this.onSelectPinCalled,
    required this.onDismissDialog,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: showBottomSheet,
          onActionCallback: callback,
          fixedToBottom: true,
        );

  @override
  double bottomSheetHeight(BuildContext context) {
    double sheetHeight = MediaQuery.of(context).size.height *
        HEIGHT_DESTINATION_SELECTOR_PERCENT;

    return sheetHeight;
  }

  @override
  double topCornerRadius(BuildContext context) {
    return TOP_CORNER_BORDER_RADIUS;
  }

  @override
  State<StatefulWidget> buildState() {
    return new _DestinationPickerBottomSheetState();
  }
}

class _DestinationPickerBottomSheetState
    extends State<DestinationPickerBottomSheet>
    implements BottomSheetWidgetBuilder {
  TextEditingController _pickupTextController = TextEditingController();
  TextEditingController _dropOffTextController = TextEditingController();

  List<GooglePlaceDescription>? _placePredictionList;

  Timer? _autoCompleteTimer;

  late String _sessionId;
  String _searchPlace = '';

  @override
  void initState() {
    super.initState();

    String formattedDate = DateFormat('dd_kk_mm_ss').format(DateTime.now());
    _sessionId = '${PrefUtil.getCurrentUserID()}_${formattedDate}';
  }

  @override
  void dispose() {
    _autoCompleteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    double HSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.width;
    }

    double VSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.height;
    }

    String placeAddress = Provider.of<PickUpAndDropOffLocations>(context)
            .pickUpLocation
            ?.placeName ??
        '';

    _pickupTextController.text = placeAddress;

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pickup and DropOff container(top section)
          // Pickup Location
          SizedBox(height: VSpace(0.06)),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: HSpace(0.06)),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.onDismissDialog();
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.close, size: 20.0),
                ),
              ),
              SizedBox(width: HSpace(0.04)),
              Text(
                SafeLocalizations.of(context)!
                    .bottom_sheet_destination_picker_trip,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: VSpace(0.02)),

          Container(
            margin: EdgeInsets.symmetric(horizontal: HSpace(0.038)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0)),
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
                SizedBox(width: HSpace(0.04), height: VSpace(0.048)),
                Image.asset('images/dot_red.png', height: 16.0, width: 16.0),
                SizedBox(width: HSpace(0.04)),
                IgnorePointer(
                  ignoring: true,
                  child: TextField(
                    controller: _pickupTextController,
                    decoration: InputDecoration(
                      hintText: SafeLocalizations.of(context)!
                          .bottom_sheet_destination_picker_pickup_location,
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.symmetric(horizontal: HSpace(0.038)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0)),
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
                SizedBox(width: HSpace(0.04), height: VSpace(0.048)),
                Image.asset('images/dot_blue.png', height: 16.0, width: 16.0),
                SizedBox(width: HSpace(0.04)),
                TextField(
                  controller: _dropOffTextController,
                  onChanged: (newVal) {
                    _searchPlace = newVal.trim();
                    _autoCompleteTimer?.cancel();
                    if (_searchPlace.isEmpty) {
                      _placePredictionList = null;
                      setState(() {});
                      return;
                    }

                    _autoCompleteTimer = new Timer(
                      Duration(milliseconds: 400),
                      () async {
                        try {
                          _placePredictionList =
                              await GoogleApiUtils.autoCompletePlaceName(
                                  _searchPlace, _sessionId);
                        } catch (err) {
                          _placePredictionList = null;
                        }
                        setState(() {});
                      },
                    );
                  },
                  decoration: InputDecoration(
                    hintText: SafeLocalizations.of(context)!
                        .bottom_sheet_destination_picker_destination_location,
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: VSpace(0.02)),

          if (_placePredictionList != null) ...[
            greyVerticalDivider(0.5),
          ],

          // Pin your location on the map
          if ((_placePredictionList?.length ?? 0) == 0) ...[
            lightGreyVerticalDivider(2),
            GestureDetector(
              onTap: () {
                widget.onSelectPinCalled();
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  SizedBox(width: HSpace(0.078), height: VSpace(0.048)),
                  Icon(Icons.location_on,
                      color: ColorConstants.lyftColor, size: 20.0),
                  SizedBox(width: HSpace(0.04)),
                  Text(
                    SafeLocalizations.of(context)!
                        .bottom_sheet_destination_picker_pin_your_location,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            lightGreyVerticalDivider(2),
          ],

          if ((_placePredictionList?.length ?? 0) != 0) ...[
            // Search Results
            ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: _placePredictionList?.length ?? 0,
              itemBuilder: (_, index) {
                return _SearchedPlaceTile(
                  clickCallback: (place) async {
                    showDialog(
                        context: context,
                        builder: (_) => CustomProgressDialog(
                            message: SafeLocalizations.of(context)!
                                .bottom_sheet_destination_picker_progress_dialog_waiting));

                    try {
                      Address address =
                          await GoogleApiUtils.getPlaceAddressDetails(
                              place.place_id, _sessionId);

                      Navigator.pop(context);

                      Provider.of<PickUpAndDropOffLocations>(context,
                              listen: false)
                          .updateDropOffLocationAddress(address);
                      _placePredictionList?.clear();

                      widget.onActionCallback();
                    } catch (err) {
                      Navigator.pop(context);

                      displayToastMessage(err.toString(), context);
                    }
                  },
                  place: _placePredictionList![index],
                );
              },
            )
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.wrapContent(context, buildContent);
  }
}

class _SearchedPlaceTile extends StatelessWidget {
  final GooglePlaceDescription place;
  final Function(GooglePlaceDescription) clickCallback;

  _SearchedPlaceTile({
    required this.place,
    required this.clickCallback,
  });

  @override
  Widget build(BuildContext context) {
    double HSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.width;
    }

    double VSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.height;
    }

    return GestureDetector(
      onTap: () => clickCallback(place),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          SizedBox(width: HSpace(0.078), height: VSpace(0.048)),
          Icon(Icons.location_on_sharp, color: ColorConstants.lyftColor),
          SizedBox(width: HSpace(0.04)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.0),
                Text(
                  place.main_name,
                  // prevent overflow
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16.0, color: Colors.grey.shade900),
                ),
                SizedBox(height: 2.0),
                Text(
                  place.detailed_name,
                  // prevent overflow
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.0, color: Colors.grey.shade500),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
