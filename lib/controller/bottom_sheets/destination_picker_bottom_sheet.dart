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

  static const double HEIGHT_DESTINATION_SELECTOR_PERCENT = 0.80;
  static const double TOP_CORNER_BORDER_RADIUS = 15.0;

  VoidCallback onSelectPinCalled;

  DestinationPickerBottomSheet({
    Key? key,
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback callback,
    required this.onSelectPinCalled,
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
  bool haveWrappedHeight(BuildContext context) {
    return false;
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

  bool _isSearchForPickup = false;

  bool _hasLoadedPickupText = false;
  String _initialPickupText = "";
  bool _hasPreviousChangedPickup = false;

  Timer? _autoCompleteTimer;

  late String _sessionId;
  String _pickupPlaceName = '';
  String _dropoffPlaceName = '';

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
    if (!_hasLoadedPickupText ||
        Provider.of<PickUpAndDropOffLocations>(context).resetPickupLocation) {
      _hasLoadedPickupText = true;

      Future.delayed(Duration.zero, () {
        Provider.of<PickUpAndDropOffLocations>(context, listen: false)
            .setResetPickupLocation(false);
      });

      String placeName = Provider.of<PickUpAndDropOffLocations>(context)
              .pickUpLocation
              ?.placeName ??
          '';
      if (placeName.trim() == "") placeName = _initialPickupText;
      _initialPickupText = placeName;
      _pickupTextController.text = _initialPickupText;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20.0),
          Text(
            'Your Safe Journey',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                fontFamily: 'Lato'),
          ),
          SizedBox(height: 20.0),
          Container(
            child: Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.022),
                Container(
                  child: Image.asset('images/location.png'),
                ),
                Expanded(
                  child: Column(
                    children: [
                      // pickup
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Focus(
                                    onFocusChange: (_) {
                                      if (!_hasPreviousChangedPickup) {
                                        _hasPreviousChangedPickup = true;
                                        _pickupTextController.value =
                                            TextEditingValue(
                                          text: _initialPickupText,
                                          selection: TextSelection.collapsed(
                                              offset:
                                                  _initialPickupText.length),
                                        );
                                      }
                                    },
                                    child: TextFormField(
                                      controller: _pickupTextController,
                                      onChanged: (newVal) {
                                        _isSearchForPickup = true;

                                        _pickupPlaceName = newVal.trim();
                                        _autoCompleteTimer?.cancel();
                                        if (_pickupPlaceName.isEmpty) {
                                          _placePredictionList = null;
                                          setState(() {});
                                          return;
                                        }

                                        _autoCompleteTimer = new Timer(
                                          Duration(milliseconds: 300),
                                          () async {
                                            try {
                                              _placePredictionList =
                                                  await GoogleApiUtils
                                                      .autoCompletePlaceName(
                                                          _pickupPlaceName,
                                                          _sessionId);
                                            } catch (err) {
                                              _placePredictionList = null;
                                            }
                                            setState(() {});
                                          },
                                        );
                                      },
                                      decoration: InputDecoration(
                                        hintText: SafeLocalizations.of(context)!
                                            .bottom_sheet_destination_picker_pickup_location,
                                        fillColor: Color.fromRGBO(0, 0, 0, 0.1),
                                        filled: true,
                                        border: InputBorder.none,
                                        isDense: true,
                                        suffixIcon: Icon(
                                          Icons.menu,
                                          color: Colors.black,
                                        ),
                                        contentPadding: EdgeInsets.only(
                                            left: 11.0, top: 15.0, bottom: 8.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: Colors.white, width: 0.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black, width: 2.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // dropoff
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: TextFormField(
                                    controller: _dropOffTextController,
                                    autofocus: true,
                                    onChanged: (newVal) {
                                      _isSearchForPickup = false;

                                      _dropoffPlaceName = newVal.trim();
                                      _autoCompleteTimer?.cancel();
                                      if (_dropoffPlaceName.isEmpty) {
                                        _placePredictionList = null;
                                        setState(() {});
                                        return;
                                      }

                                      _autoCompleteTimer = new Timer(
                                        Duration(milliseconds: 300),
                                        () async {
                                          try {
                                            _placePredictionList =
                                                await GoogleApiUtils
                                                    .autoCompletePlaceName(
                                                        _dropoffPlaceName,
                                                        _sessionId);
                                          } catch (err) {
                                            _placePredictionList = null;
                                          }
                                          setState(() {});
                                        },
                                      );
                                    },
                                    decoration: InputDecoration(
                                      hintText: SafeLocalizations.of(context)!
                                          .bottom_sheet_select_drop_off_select_dropoff,
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      suffixIcon: Icon(
                                        Icons.menu,
                                        color: Colors.black,
                                      ),
                                      contentPadding: EdgeInsets.only(
                                          left: 11.0, top: 15.0, bottom: 8.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.white, width: 0.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Color.fromRGBO(221, 0, 0, 1),
                                            width: 2.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // destination search end point
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              height: 2.0,
              color: ColorConstants.appThemeSecondaryColor),

          // Pin your location on the map
          if (_placePredictionList == null ||
              _placePredictionList?.length == 0) ...[
            //  lightGreyVerticalDivider(6),
            GestureDetector(
              onTap: () {
                widget.onSelectPinCalled();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 24.0),
                child: Row(
                  children: [
                    Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40.0),
                        color: Color.fromRGBO(221, 0, 0, 1),
                      ),
                      padding: EdgeInsets.all(5.0),
                      child:
                          Image.asset('images/white_logo_1.png', height: 30.0),
                    ),
                    SizedBox(width: 18.0),
                    Text(
                      SafeLocalizations.of(context)!
                          .bottom_sheet_destination_picker_pin_your_location,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(221, 0, 0, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //   lightGreyVerticalDivider(6),
          ],

          SizedBox(height: 10.0),

          // Search Results
          ...(_placePredictionList ?? []).map((place) {
            return _SearchedPlaceTile(
              clickCallback: (place) async {
                showDialog(
                    context: context,
                    builder: (_) => CustomProgressDialog(
                        message: _isSearchForPickup
                            ? "Updating Pickup"
                            : "Updating Dropoff"));
                try {
                  Address address = await GoogleApiUtils.getPlaceAddressDetails(
                      place.place_id, _sessionId);

                  Navigator.pop(context);

                  _placePredictionList?.clear();

                  if (_isSearchForPickup) {
                    Provider.of<PickUpAndDropOffLocations>(context,
                            listen: false)
                        .updatePickupLocationAddress(address);
                    Provider.of<PickUpAndDropOffLocations>(context,
                            listen: false)
                        .setResetPickupLocation(true);
                  } else {
                    Provider.of<PickUpAndDropOffLocations>(context,
                            listen: false)
                        .updateDropOffLocationAddress(address);

                    widget.onActionCallback();
                  }
                } catch (err) {
                  Navigator.pop(context);

                  displayToastMessage(err.toString(), context);
                }
              },
              place: place,
            );
          }),
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: GestureDetector(
        onTap: () => clickCallback(place),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Icon(Icons.location_on_rounded,
                color: Color.fromRGBO(221, 0, 0, 1)),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.0),
                  Text(
                    place.main_name,
                    // prevent overflow
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 18.0, color: Colors.grey.shade800),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    place.detailed_name,
                    // prevent overflow
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 14.0, color: Colors.grey.shade300),
                  ),
                  SizedBox(height: 8.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
