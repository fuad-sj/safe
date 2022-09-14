import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/controller/bottom_sheets/destination_picker_bottom_sheet.dart';
import 'package:safe/models/address.dart';
import 'package:safe/models/color_constants.dart';
import 'package:safe/models/google_place_description.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:safe/utils/google_api_util.dart';
import 'package:safe/utils/map_style.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class SelectDropOffPinBottomSheet extends BaseBottomSheet {
  static const double TOP_CORNER_BORDER_RADIUS = 22.0;
  static const double SIZE_CURRENT_PIN_IMAGE = 45.0;

  Position currentPosition;
  Image CURRENT_PIN_ICON;

  VoidCallback onBackSelected;

  SelectDropOffPinBottomSheet({
    Key? key,
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback callback,
    required this.CURRENT_PIN_ICON,
    required this.currentPosition,
    required this.onBackSelected,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: showBottomSheet,
          onActionCallback: callback,
          fixedToBottom: true,
        );

  @override
  double bottomSheetHeight(BuildContext context) {
    double sheetHeight = MediaQuery.of(context).size.height;

    return sheetHeight;
  }

  @override
  double topCornerRadius(BuildContext context) {
    return TOP_CORNER_BORDER_RADIUS;
  }

  int animationDuration() {
    return 40;
  }

  @override
  State<StatefulWidget> buildState() {
    return new _SelectDropOffPinBottomSheetState();
  }
}

class _SelectDropOffPinBottomSheetState
    extends State<SelectDropOffPinBottomSheet>
    implements BottomSheetWidgetBuilder {
  GoogleMapController? _mapController;

  Address? _destinationAddress;

  Timer? _locationGeocodeTimer;

  @override
  void initState() {
    super.initState();

    loadDestinationLocation();
  }

  void loadDestinationLocation() async {
    _destinationAddress =
        await GoogleApiUtils.searchCoordinateAddress(widget.currentPosition);
    setState(() {});
  }

  Widget _getBackBtnWidget() {
    return Positioned(
      top: 50.0,
      left: 20.0,
      child: GestureDetector(
        onTap: () {
          widget.onBackSelected();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 6.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back, color: Colors.grey.shade800),
            radius: 24.0,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationGeocodeTimer?.cancel();
    super.dispose();
  }

  void delayedSetState() {
    Future.delayed(Duration.zero, () async {
      setState(() {});
    },);
  }

  @override
  Widget buildContent(BuildContext context) {
    const double TOP_MAP_PADDING = 40;

    double mapWidth = MediaQuery.of(context).size.width;
    double mapHeight = MediaQuery.of(context).size.height;

    double pickerHeight = MediaQuery.of(context).size.height *
        _SetPickupBottomSheet.HEIGHT_SET_PICKUP_PERCENT;

    return Stack(
      children: [
        SizedBox(height: 50.0),

        GoogleMap(
          padding: EdgeInsets.only(
            top: TOP_MAP_PADDING,
            bottom: pickerHeight + 15,
          ),
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
              target: LatLng(widget.currentPosition.latitude,
                  widget.currentPosition.longitude),
              zoom: 16.0),
          zoomGesturesEnabled: true,
          onMapCreated: (GoogleMapController controller) async {
            _mapController = controller;
            controller.setMapStyle(GoogleMapStyle.mapStyles);
            delayedSetState();
          },
          onCameraMoveStarted: () {
            _locationGeocodeTimer?.cancel();
            _destinationAddress = null;
            delayedSetState();
          },
          onCameraMove: (CameraPosition newPosition) async {
            _locationGeocodeTimer?.cancel();
            _locationGeocodeTimer = new Timer(
              Duration(milliseconds: 100),
              () async {
                if (!mounted) return;

                try {
                  _destinationAddress =
                      await GoogleApiUtils.searchCoordinateLatLng(
                          newPosition.target);
                } catch (err) {
                  _destinationAddress = null;
                }
                delayedSetState();
              },
            );
          },
        ),

        //
        _getBackBtnWidget(),

        Positioned(
          top: (mapHeight -
                  (SelectDropOffPinBottomSheet.SIZE_CURRENT_PIN_IMAGE +
                      pickerHeight)) /
              2,
          left:
              (mapWidth - SelectDropOffPinBottomSheet.SIZE_CURRENT_PIN_IMAGE) /
                  2,
          child: widget.CURRENT_PIN_ICON,
        ),

        //
        _SetPickupBottomSheet(
          tickerProvider: widget.tickerProvider,
          actionCallback: widget.onActionCallback,
          onBackSelected: widget.onBackSelected,
          destinationAddress: _destinationAddress,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.wrapContent(context, buildContent);
  }
}

class _SetPickupBottomSheet extends BaseBottomSheet {
  static const String KEY = 'WhereToBottomSheet';

  static const double HEIGHT_SET_PICKUP_PERCENT = 0.28;
  static const double TOP_CORNER_BORDER_RADIUS = 22.0;

  VoidCallback onBackSelected;
  Address? destinationAddress;

  _SetPickupBottomSheet({
    required TickerProvider tickerProvider,
    required VoidCallback actionCallback,
    required this.destinationAddress,
    required this.onBackSelected,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: true,
          onActionCallback: actionCallback,
        ) {}

  @override
  double bottomSheetHeight(BuildContext context) {
    double sheetHeight =
        MediaQuery.of(context).size.height * HEIGHT_SET_PICKUP_PERCENT;

    return sheetHeight;
  }

  @override
  double topCornerRadius(BuildContext context) {
    return TOP_CORNER_BORDER_RADIUS;
  }

  @override
  State<StatefulWidget> buildState() {
    return new _SetPickupBottomSheetState();
  }
}

class _SetPickupBottomSheetState extends State<_SetPickupBottomSheet>
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
        //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
              child: Container(
                  margin: EdgeInsets.only(top: VSpace(0.005)),
                  width: 30.0,
                  height: 2.0,
                  color: Colors.grey.shade700)),
          SizedBox(height: VSpace(0.034)),
          Text(
              SafeLocalizations.of(context)!
                  .bottom_sheet_destination_picker_destination_location,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              )),
          SizedBox(height: VSpace(0.02)),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.onBackSelected();
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
                  Icon(Icons.search, color: ColorConstants.lyftColor),
                  SizedBox(width: HSpace(0.05)),
                  Expanded(
                    child: Text(
                      widget.destinationAddress?.placeName ?? '',
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: VSpace(0.02)),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 45.0, vertical: 20.0),
              backgroundColor: widget.destinationAddress != null
                  ? ColorConstants.lyftColor
                  : Colors.grey.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            onPressed: () {
              if (widget.destinationAddress == null) {
                return;
              }
              Provider.of<PickUpAndDropOffLocations>(context, listen: false)
                  .updateDropOffLocationAddress(widget.destinationAddress!);
              widget.onActionCallback();
            },
            child: Container(
              width: double.infinity,
              child: Center(
                child: Text(
                  SafeLocalizations.of(context)!
                      .bottom_sheet_select_drop_off_select_confirm,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Open Sans',
                  ),
                ),
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
