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
    String placeAddress = Provider.of<PickUpAndDropOffLocations>(context)
            .pickUpLocation
            ?.placeName ??
        '';

    _pickupTextController.text = placeAddress;

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pickup and DropOff container(top section)
          // Pickup Location
          SizedBox(height: 10.0),
          Container(
            child: Text('',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0)),
          ),
          SizedBox(height: 20.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              children: [
                Image.asset('images/dot_blue.png', height: 16.0, width: 16.0),
                SizedBox(width: 18.0),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(3.0),
                      child: IgnorePointer(
                        ignoring: true,
                        child: TextFormField(
                          controller: _pickupTextController,
                          decoration: InputDecoration(
                            hintText: SafeLocalizations.of(context)!
                                .bottom_sheet_destination_picker_pickup_location,
                            fillColor: Color.fromARGB(255, 195, 80, 152)
                                .withOpacity(0.3),
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

          // Dropoff Location
          Container(
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Image.asset('images/separator.png', height: 10.0)),
                Expanded(child: Container())
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              children: [
                Image.asset('images/dot_red.png', height: 16.0, width: 16.0),
                SizedBox(width: 18.0),
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
                                color: ColorConstants.appThemeColor, width: 2.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),

          Container(
              margin: EdgeInsets.symmetric(horizontal: 25.0),
              height: 1.0,
              color: ColorConstants.appThemeColor),

          if (_placePredictionList != null) ...[
            //     greyVerticalDivider(0.5),
          ],

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
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 24.0),
                child: Row(
                  children: [
                    Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40.0),
                        color:
                            Color.fromARGB(255, 195, 80, 152).withOpacity(0.2),
                      ),
                      padding: EdgeInsets.all(10.0),
                      child:
                          Image.asset('images/pin_location.png', height: 30.0),
                    ),
                    SizedBox(width: 18.0),
                    Text(
                      SafeLocalizations.of(context)!
                          .bottom_sheet_destination_picker_pin_your_location,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color.fromARGB(255, 195, 80, 152),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //   lightGreyVerticalDivider(6),
          ],

          // Search Results
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: ListView.separated(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              separatorBuilder: (_, __) => darkGreyVerticalDivider(0.0),
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

class _SearchedPlaceTile extends StatelessWidget {
  final GooglePlaceDescription place;
  final Function(GooglePlaceDescription) clickCallback;

  _SearchedPlaceTile({
    required this.place,
    required this.clickCallback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => clickCallback(place),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(Icons.add_location),
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
                  style: TextStyle(fontSize: 18.0, color: Colors.grey.shade800),
                ),
                SizedBox(height: 2.0),
                Text(
                  place.detailed_name,
                  // prevent overflow
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.0, color: Colors.grey.shade300),
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
