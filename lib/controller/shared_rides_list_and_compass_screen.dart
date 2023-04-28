import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dartx/dartx_io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:safe/driver_location/smooth_compass.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/shared_ride_broadcast.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:safe/utils/map_style.dart';
import 'package:safe/utils/phone_call.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:safe/controller/slider_button/slider.dart';

class SharedRidesListAndCompassScreen extends StatefulWidget {
  const SharedRidesListAndCompassScreen({Key? key}) : super(key: key);

  @override
  State<SharedRidesListAndCompassScreen> createState() =>
      _SharedRidesListAndCompassScreenState();
}

class _SharedRidesListAndCompassScreenState
    extends State<SharedRidesListAndCompassScreen> {
  static const SEARCH_NOT_FOUND_ID = "search_not_found_id";

  static const double DEFAULT_SEARCH_RADIUS_KMS = 10.5;
  static const double COMPASS_POINTER_DISAPPEAR_METERS = 0.001;

  StreamSubscription<dynamic>? _geofireStream;

  Map<String, SharedRideBroadcast> _rideBroadcasts = Map();

  Map<String, SharedRidePlaceAggregate> _placeRideAggregate = Map();

  StreamSubscription? _locationStreamSubscription;
  late Location liveLocation;

  LatLng? currentLocation;

  List<MapEntry<String, SharedRidePlaceAggregate>> _destinationPlaces = [];

  /// Fields **ABOVE** are for listing destinations.
  ///
  /// Fields **BELOW** are for compass details.
  static const CameraPosition ADDIS_ABABA_CENTER_LOCATION = CameraPosition(
      target: LatLng(9.00464643580664, 38.767820855962), zoom: 17.0);

  String? _selectedRideId;
  StreamSubscription? _selectedRideSubscription;
  SharedRideBroadcast? _selectedRideBroadcast;

  Set<Polyline> _mapPolyLines = Set();
  Set<Marker> _mapMarkers = Set();

  GoogleMapController? _mapController;

  late ImageProvider arrowImage;
  late ImageProvider compassImage;

  StreamSubscription? _compassStreamSub;

  double _lastReadCompassTurns = 0.0;
  double _lastReadCompassAngels = 0.0;

  double _computedOffsetHeading = 0.0;

  bool loadingFinished = false;
  bool isCompassAvailable = false;

  double metersToCar = -1;
  double fontSizeMultiplier = 1.0;

  bool isCustomerArrivedAtPickup = false;

  bool customerSwipedToEnter = false;
  bool customerAcceptedIntoCar = false;

  bool isTripStarted = false;
  bool isTripCompleted = false;

  double zoomLevel = 1.0;

  String _selfPhone = "";

  bool get isCorrectHeading => _computedOffsetHeading.abs() < 0.06;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(onBackBtnHandler);

    Future.delayed(Duration.zero, () async {
      liveLocation = new Location();
      _selfPhone = PrefUtil.getCurrentUserPhone();

      await Geofire.initialize(FIREBASE_DB_PATHS.SHARED_RIDE_BROADCASTS,
          is_default: false,
          root: SharedRideBroadcast.SHARED_RIDE_DATABASE_ROOT);

      setupNearbyBroadcastsQuery();
    });

    arrowImage = AssetImage("images/arrow.png");
    compassImage = AssetImage("images/compass_base.png");
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(onBackBtnHandler);

    Future.delayed(Duration.zero, () async {
      await Geofire.stopListener();
    });

    _geofireStream?.cancel();

    _locationStreamSubscription?.cancel();

    _compassStreamSub?.cancel();

    _selectedRideSubscription?.cancel();

    super.dispose();
  }

  Future<bool> onBackBtnHandler(
      bool stopDefaultButtonEvent, RouteInfo routeInfo) async {
    if (_selectedRideId == null) {
      return false;
    }

    await resetCompassState();
    return true;
  }

  Future<void> resetCompassState() async {
    _selectedRideId = null;
    await _selectedRideSubscription?.cancel();
    _selectedRideSubscription = null;

    /// get back to getting updates
    _geofireStream?.resume();
  }

  Future<void> setupNearbyBroadcastsQuery() async {
    final String fieldCallback = 'callBack';
    final String fieldKey = 'key';
    final String fieldVal = 'val';

    PermissionStatus permissionStatus = await liveLocation.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await liveLocation.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }
    var locData = await liveLocation.getLocation();

    currentLocation = new LatLng(locData.latitude!, locData.longitude!);

    _locationStreamSubscription =
        liveLocation.onLocationChanged.listen((LocationData locData) async {
      currentLocation = new LatLng(locData.latitude!, locData.longitude!);

      if (_selectedRideBroadcast != null) {
        metersToCar = Geolocator.distanceBetween(
            currentLocation!.latitude,
            currentLocation!.longitude,
            _selectedRideBroadcast!.broadcast_loc!.latitude,
            _selectedRideBroadcast!.broadcast_loc!.longitude);
        isCustomerArrivedAtPickup =
            metersToCar < COMPASS_POINTER_DISAPPEAR_METERS;
        fontSizeMultiplier = isCustomerArrivedAtPickup ? 2.0 : 1.0;

        if (mounted) {
          setState(() {});
        }
      }
    });

    // once location is acquired, setup compass. having location makes compass more accurate
    setupCompassCallback();

    /**
     * TODO: Relaunch the geofire query if the user has moved "too much". the query is a static one
     * i.e: it doesn't accommodate for changes in the user's live position
     */
    _geofireStream = Geofire.queryAtLocation(
            locData.latitude!, locData.longitude!, DEFAULT_SEARCH_RADIUS_KMS)
        ?.listen(
      (obj) async {
        if (obj == null) {
          return;
        }

        var callBack = obj[fieldCallback];

        if (callBack != Geofire.onGeoQueryReady) {
          String rideId = obj[fieldKey];

          switch (callBack) {
            case Geofire.onKeyEntered:
            case Geofire.onKeyMoved:
            case Geofire.onKeyChanged:
              Map body = obj[fieldVal] as Map;

              SharedRideBroadcast broadcast =
                  SharedRideBroadcast.fromMap(body, rideId);

              broadcast.distance_to_broadcast = Geolocator.distanceBetween(
                  broadcast.broadcast_loc!.latitude,
                  broadcast.broadcast_loc!.longitude,
                  currentLocation!.latitude,
                  currentLocation!.longitude);

              _rideBroadcasts[rideId] = broadcast;

              updatePlaceRideAggregate(rideId,
                  isRemoveOperation: !broadcast.isValidOrderToConsider());

              if (mounted) {
                setState(() {
                  _destinationPlaces = sortedPlaces();
                });
              }
              break;

            case Geofire.onKeyExited:
              updatePlaceRideAggregate(rideId, isRemoveOperation: true);
              _rideBroadcasts.remove(rideId);

              break;
          }
        }

        if (mounted) {
          setState(() {
            _destinationPlaces = sortedPlaces();
          });
        }
      },
    );
  }

  Future<void> setupCompassCallback() async {
    isCompassAvailable = await Compass().isCompassAvailable();
    if (isCompassAvailable) {
      _compassStreamSub = Compass()
          .compassUpdates(
              interval: const Duration(
                milliseconds: 150,
              ),
              azimuthFix: 0.0,
              currentLoc: MyLoc(
                  latitude: currentLocation?.latitude ?? 0,
                  longitude: currentLocation?.longitude ?? 0))
          .listen((snapshot) {
        loadingFinished = true;
        if (mounted) {
          setState(() {
            _lastReadCompassTurns = snapshot.turns;
            _lastReadCompassAngels = snapshot.angle;
          });
        }
      });
    }
  }

  /// Aggregate destinations based on place, so multiple broadcasts to the same place appear as one in a list
  void updatePlaceRideAggregate(String rideId,
      {bool isRemoveOperation = false}) {
    SharedRideBroadcast broadcast = _rideBroadcasts[rideId]!;
    String placeId = broadcast.ride_details!.place_id!;

    if (isRemoveOperation) {
      // if the an aggregate already doesn't exist for a place, good riddance
      if (!_placeRideAggregate.containsKey(placeId)) {
        return;
      }

      SharedRidePlaceAggregate aggregate = _placeRideAggregate[placeId]!;

      aggregate.all_rides_to_place.remove(rideId);
      // if the ride was the only one to that place, remove place aggregate altogether
      if (aggregate.all_rides_to_place.isEmpty) {
        _placeRideAggregate.remove(placeId);
        return;
      }

      if (broadcast.ride_details!.is_six_seater!) {
        aggregate.all_six_seater_rides.remove(rideId);
        aggregate.prev_seen_nearby_six_seater_rides.remove(rideId);
        // no need to update sort, as removing preserves order of the remaining fields
        aggregate.nearby_six_seater_rides.remove(rideId);
      } else {
        aggregate.all_four_seater_rides.remove(rideId);
        aggregate.prev_seen_nearby_four_seater_rides.remove(rideId);
        // no need to update sort, as removing preserves order of the remaining fields
        aggregate.nearby_four_seater_rides.remove(rideId);
      }
    } else {
      if (!_placeRideAggregate.containsKey(placeId)) {
        _placeRideAggregate[placeId] = SharedRidePlaceAggregate(
          place_id: placeId,
          place_name: broadcast.ride_details!.place_name!,
        );
      }

      SharedRidePlaceAggregate aggregate = _placeRideAggregate[placeId]!;
      aggregate.all_rides_to_place.add(rideId);

      if (broadcast.ride_details!.is_six_seater!) {
        aggregate.six_seater_est_price = broadcast.ride_details!.est_price;
        aggregate.all_six_seater_rides.add(rideId);

        if (!aggregate.prev_seen_nearby_six_seater_rides.contains(rideId)) {
          aggregate.prev_seen_nearby_six_seater_rides.add(rideId);
          aggregate.nearby_six_seater_rides.add(rideId);
        }
        aggregate.nearby_six_seater_rides.sort(_compareRidesForSorting);
      } else {
        aggregate.four_seater_est_price = broadcast.ride_details!.est_price;
        aggregate.all_four_seater_rides.add(rideId);

        if (!aggregate.prev_seen_nearby_four_seater_rides.contains(rideId)) {
          aggregate.prev_seen_nearby_four_seater_rides.add(rideId);
          aggregate.nearby_four_seater_rides.add(rideId);
        }
        aggregate.nearby_four_seater_rides.sort(_compareRidesForSorting);
      }
    }
  }

  /// Uses a time based sort to check which ride was created first, thus creating a queue
  int _compareRidesForSorting(String rideIdA, String rideIdB) {
    if (!_rideBroadcasts.containsKey(rideIdA) ||
        !_rideBroadcasts.containsKey(rideIdB)) {
      return -1;
    }
    SharedRideBroadcast rideA = _rideBroadcasts[rideIdA]!;
    SharedRideBroadcast rideB = _rideBroadcasts[rideIdB]!;

    return (rideA.ride_details?.created_timestamp ?? -1)
        .compareTo(rideB.ride_details?.created_timestamp ?? -1);
  }

  List<MapEntry<String, SharedRidePlaceAggregate>> sortedPlaces() {
    /**
     * Picks place aggregates where either 4 or 6 seaters is available.
     * Then sorts that based on the place name
     */
    return _placeRideAggregate
        .filter((e) =>
            e.value.nearby_four_seater_rides.isNotEmpty ||
            e.value.nearby_six_seater_rides.isNotEmpty)
        .entries
        .toList()
      ..sort((a, b) => a.value.place_name.compareTo(b.value.place_name));
  }

  Widget buildRideListScreen(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 160.0,
            flexibleSpace: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'images/back_pic.png',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'ወዴት መሄድ ይፈልጋሉ ?',
                                    style: TextStyle(
                                      fontSize: 25.0,
                                      color: Color.fromRGBO(255, 255, 255, 1.0),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Nokia Pure Headline Bold",
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 15,
            ),
          ),
          if (_destinationPlaces.isEmpty) ...[
            SliverToBoxAdapter(
              child: SpinKitFadingCircle(
                itemBuilder: (_, int index) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: index.isEven
                          ? Color.fromRGBO(131, 1, 1, 1.0)
                          : Color.fromRGBO(255, 0, 0, 1.0),
                    ),
                  );
                },
              ),
            ),
          ],
          if (_destinationPlaces.isNotEmpty) ...[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return _AvailableDriverListItem(
                    placeId: _destinationPlaces[index].key,
                    placeAggregate: _destinationPlaces[index].value,
                    onFourSeaterSelected: pickSharedRideForPlaceAndSeater,
                    onSixSeaterSelected: pickSharedRideForPlaceAndSeater,
                  );
                },
                childCount: _destinationPlaces.length,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildCompassScreen(BuildContext context) {
    const double TOP_MAP_PADDING = 40;
    const driverDetailTextStyle = TextStyle(
      fontSize: 12.0,
      letterSpacing: 1.0,
      color: Color.fromRGBO(255, 255, 255, 1.0),
      fontFamily: "Nokia Pure Headline Bold",
    );

    const driverDetailTextStyleBig = TextStyle(
      fontSize: 20.0,
      letterSpacing: 1.0,
      color: Color.fromRGBO(255, 255, 255, 1.0),
      fontFamily: "Nokia Pure Headline Bold",
    );
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(
              top: TOP_MAP_PADDING,
              bottom: 0,
            ),
            polylines: _mapPolyLines,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: ADDIS_ABABA_CENTER_LOCATION,
            myLocationEnabled: false,
            zoomGesturesEnabled: false,
            zoomControlsEnabled: false,
            markers: _mapMarkers,
            onMapCreated: (GoogleMapController controller) async {
              _mapController = controller;
              controller.setMapStyle(GoogleMapStyle.mapStyles);

              if (isTripStarted) {
                final LatLng startLocation = LatLng(9.003511, 38.781497);
                final LatLng endLocation = LatLng(9.020452, 38.878872);

                final List<LatLng> polylinePoints = [
                  startLocation,
                  endLocation
                ];
                final Polyline polyline = Polyline(
                  polylineId: PolylineId('myPolyline'),
                  color: Colors.white,
                  width: 15,
                  points: polylinePoints,
                );
                setState(() {
                  _mapPolyLines.add(polyline);
                });
              }
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                end: Alignment.bottomRight,
                begin: Alignment.topRight,
                colors: [
                  Color(0xC7DC0000),
                  Color(0xd3dc0000),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.025,
                  left: MediaQuery.of(context).size.width * 0.070,
                  child: IconButton(
                    onPressed: () async {
                      await resetCompassState();

                      if (mounted) {
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),
                    iconSize: 28.0,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.1,
                  left: MediaQuery.of(context).size.width * 0.082,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.078,
                    width: MediaQuery.of(context).size.width * 0.82,
                    child: Row(
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "መለያዎ :-  ${formatPhone(_selfPhone)}",
                                style: TextStyle(
                                  fontSize: 24.0,
                                  color: Color.fromRGBO(255, 255, 255, 1.0),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Nokia Pure Headline Bold",
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Image(image: AssetImage('images/safe_gray.png')),
                      ],
                    ),
                  ),
                ),

                if (!isCustomerArrivedAtPickup && !customerSwipedToEnter) ...[
                  // Car details upto
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.15,
                    left: MediaQuery.of(context).size.width * 0.082,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.82,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ሹፌሮ ስም : ${_selectedRideBroadcast?.ride_details?.driver_name ?? ''}',
                            style: driverDetailTextStyle,
                          ),
                          Text(
                            'ሹፌሮ ስልክ : ${formatPhone(_selectedRideBroadcast?.ride_details?.driver_phone ?? '')}',
                            style: driverDetailTextStyle,
                          ),
                          Text(
                            'መኪና ታርጋ : ${_selectedRideBroadcast?.ride_details?.car_plate ?? ''}',
                            style: driverDetailTextStyle,
                          ),
                          Text(
                            'መኪና : ${_selectedRideBroadcast?.ride_details?.car_details ?? ""}',
                            style: driverDetailTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Arrow Pointer
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.414,
                    left: MediaQuery.of(context).size.width * 0.090,
                    width: MediaQuery.of(context).size.width * 0.8,
                    //height: MediaQuery.of(context).size.height * 0.60,
                    child: Container(
                      color: Colors.transparent,
                      child: Container(
                        //height: MediaQuery.of(context).size.height * 0.19,
                        child: Center(
                          child: AnimatedRotation(
                            turns: getAdjustedTurn(),
                            duration: Duration(milliseconds: 400),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.23,
                              height: MediaQuery.of(context).size.width * 0.30,
                              child: Image(
                                image: arrowImage,
                                color: isCorrectHeading
                                    ? Colors.amber.shade400
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Compass
                  if (loadingFinished && isCompassAvailable) ...[
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.30,
                      left: MediaQuery.of(context).size.width * 0.10,
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      child: Container(
                        color: Colors.transparent,
                        child: Container(
                          child: Center(
                            child: AnimatedRotation(
                              turns: _lastReadCompassTurns,
                              duration: Duration(milliseconds: 400),
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: compassImage, fit: BoxFit.fill),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // To your left or right
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.06,
                    left: MediaQuery.of(context).size.width * 0.082,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.82,
                      child: Row(
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  distanceToCar(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 41,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  isCorrectHeading
                                      ? ""
                                      : (_computedOffsetHeading < 0
                                          ? 'በስተ ግራ'
                                          : 'በስተ ቀኝ'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: "Nokia Pure Headline Bold",
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (isCustomerArrivedAtPickup) ...[
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.35,
                    left: MediaQuery.of(context).size.width * 0.08,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'አሽከርካሪዎት ጋር ደርሰዋል!',
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(255, 255, 255, 1.0),
                              fontFamily: "lato",
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'የአሽከርካሪው ስም : ${_selectedRideBroadcast?.ride_details?.driver_name ?? ""}',
                            style: driverDetailTextStyleBig,
                          ),
                          Row(
                            children: [
                              Text(
                                'የአሽከርካሪው ስልክ: ${formatPhone(_selectedRideBroadcast?.ride_details?.driver_phone ?? "")}',
                                style: driverDetailTextStyleBig,
                              ),
                              SizedBox(width: 10.0),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  try {
                                    PhoneCaller.callPhone(formatPhone(
                                        _selectedRideBroadcast
                                                ?.ride_details?.driver_phone ??
                                            ""));
                                  } catch (err) {}
                                },
                                child: Container(
                                  padding: EdgeInsets.all(5.0),
                                  child: Icon(Icons.phone,
                                      size: 26.0, color: Colors.blue.shade900),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'የመኪናው ታርጋ ቁጥር : ${_selectedRideBroadcast?.ride_details?.car_plate ?? ""}',
                            style: driverDetailTextStyleBig,
                          ),
                          Text(
                            'መኪናው : ${_selectedRideBroadcast?.ride_details?.car_details ?? ""}',
                            style: driverDetailTextStyleBig,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Swipe to start
                  if (!customerSwipedToEnter &&
                      _selectedRideBroadcast != null &&
                      _selectedRideBroadcast?.ride_details != null) ...[
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.28,
                      left: MediaQuery.of(context).size.width * 0.2,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.60,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: SliderButton(
                          sliderKey: 'Arrived at Pickup',
                          action: () async {
                            customerSwipedToEnter = true;

                            String self_id =
                                FirebaseAuth.instance.currentUser!.uid;
                            String self_phone = formatPhone(_selfPhone);

                            Map<String, dynamic> rideDetails = new Map();

                            List<SharedRideReachOutCustomer> prev_reached_out =
                                _selectedRideBroadcast!
                                        .ride_details!.reached_out_customers ??
                                    [];
                            SharedRideReachOutCustomer occurrence =
                                prev_reached_out.firstWhere(
                                    (customer) =>
                                        customer.customer_id == self_id,
                                    orElse: () => SharedRideReachOutCustomer()
                                      ..customer_id = SEARCH_NOT_FOUND_ID);

                            // current customer existed before, can't do anything about it
                            if (occurrence.customer_id == SEARCH_NOT_FOUND_ID) {
                              prev_reached_out.add(SharedRideReachOutCustomer()
                                ..customer_id = self_id
                                ..customer_phone = self_phone);
                              rideDetails[SharedRideDetails
                                      .FIELD_REACHED_OUT_CUSTOMERS] =
                                  SharedRideReachOutCustomer.List_ToJson(
                                      prev_reached_out);

                              await FirebaseDatabase.instanceFor(
                                      app: Firebase.app(),
                                      databaseURL: SharedRideBroadcast
                                          .SHARED_RIDE_DATABASE_ROOT)
                                  .ref()
                                  .child(
                                      FIREBASE_DB_PATHS.SHARED_RIDE_BROADCASTS)
                                  .child(_selectedRideId!)
                                  .child(SharedRideBroadcast.KEY_DETAILS)
                                  .update(rideDetails);
                            }

                            setState(() {});
                          },
                          boxShadow: BoxShadow(
                            color: Colors.grey.shade500,
                            blurRadius: 8.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          ),
                          label: Text(
                            'ገብተዋል ?',
                            style: TextStyle(
                              color: Color.fromRGBO(231, 0, 0, 1),
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                            ),
                          ),
                          icon: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 25.0,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image(
                                  image: AssetImage('images/swip_logo.png'),
                                ),
                              ),
                            ),
                          ),
                          width: double.infinity,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    )
                  ],
                ],

                if (customerSwipedToEnter && !customerAcceptedIntoCar) ...[
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.20,
                    left: MediaQuery.of(context).size.width * 0.2,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SpinKitFadingCircle(
                              itemBuilder: (_, int index) {
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: index.isEven
                                        ? Color.fromRGBO(131, 1, 1, 1.0)
                                        : Color.fromRGBO(255, 0, 0, 1.0),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              'የሹፌር ምላሽ እየጠበቀ ነው',
                              style: TextStyle(
                                fontSize: 30.0,
                                letterSpacing: 1.0,
                                color: Color.fromRGBO(255, 255, 255, 1.0),
                                fontFamily: "Nokia Pure Headline Bold",
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                if (metersToCar != -1 &&
                    _selectedRideBroadcast != null &&
                    _selectedRideBroadcast?.ride_details != null &&
                    !customerSwipedToEnter) ...[
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.18,
                    left: MediaQuery.of(context).size.width * 0.2,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Center(
                        child: Text(
                          '${_selectedRideBroadcast?.ride_details?.seats_remaining ?? 4} ሰው የቀረው ...',
                          style: TextStyle(
                            fontSize: 30.0,
                            letterSpacing: 1.0,
                            color: Color.fromRGBO(255, 255, 255, 1.0),
                            fontFamily: "Nokia Pure Headline Bold",
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                // on trip UI must be started after the swipe is approved by driver and trip started
                if (customerAcceptedIntoCar) ...[
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.25,
                    left: MediaQuery.of(context).size.width * 0.28,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.36,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: Colors.white,
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10.0, right: 10.0),
                            width: MediaQuery.of(context).size.width * 0.081,
                            height: MediaQuery.of(context).size.height * 0.04,
                            color: Color(0xffd20001),
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'መነሻ',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.black87,
                                    letterSpacing: 2.0,
                                    fontFamily: "Nokia Pure Headline Bold",
                                  ),
                                ),
                                Text(
                                  "Location",
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.67,
                    left: MediaQuery.of(context).size.width * 0.37,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.36,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: Colors.white,
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10.0, right: 10.0),
                            width: MediaQuery.of(context).size.width * 0.081,
                            height: MediaQuery.of(context).size.height * 0.04,
                            color: Color(0xffd20001),
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'መዳረሻ',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.black87,
                                    letterSpacing: 2.0,
                                    fontFamily: "Nokia Pure Headline Bold",
                                  ),
                                ),
                                Text(
                                  _selectedRideBroadcast
                                          ?.ride_details?.place_name ??
                                      "",
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (isTripCompleted) ...[
                  /**
                   * TODO: update finished trip details with actual values
                   */
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.35,
                    left: MediaQuery.of(context).size.width * 0.16,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ጉዞው ተጠናቅዋል!',
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(255, 255, 255, 1.0),
                              fontFamily: "lato",
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'ድምር ዋጋ : 65 ብር',
                            style: driverDetailTextStyleBig,
                          ),
                          Text(
                            'ርቀት: 10 ኪ ሜ',
                            style: driverDetailTextStyleBig,
                          ),
                          Text(
                            'የፈጀው ሰዓት : 30 ደቂቃ ',
                            style: driverDetailTextStyleBig,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedRideId == null) {
      return buildRideListScreen(context);
    } else {
      return buildCompassScreen(context);
    }
  }

  void pickSharedRideForPlaceAndSeater(String placeId, bool isFourSeater) {
    SharedRidePlaceAggregate aggregate = _placeRideAggregate[placeId]!;

    List<String> nearbyRides = isFourSeater
        ? aggregate.nearby_four_seater_rides
        : aggregate.nearby_six_seater_rides;

    _selectedRideId = nearbyRides.first;

    setupSelectedRideSubscription();

    /// stop receiving updates about other rides, as they're not relevant while one ride is being analyzed
    _geofireStream?.pause();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> setupSelectedRideSubscription() async {
    if (_selectedRideId == null) return;

    _selectedRideSubscription = FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL: SharedRideBroadcast.SHARED_RIDE_DATABASE_ROOT)
        .ref()
        .child(FIREBASE_DB_PATHS.SHARED_RIDE_BROADCASTS)
        .child(_selectedRideId!)
        .onValue
        .listen((event) async {
      _selectedRideBroadcast = SharedRideBroadcast.fromSnapshot(event.snapshot);
      if (_selectedRideBroadcast?.ride_id == null) {
        _selectedRideBroadcast = null;
        _selectedRideId = null;
        _selectedRideSubscription?.cancel();
        _selectedRideSubscription = null;
        if (mounted) {
          setState(() {});
        }
        return;
      }

      if (_selectedRideBroadcast!.ride_details?.accepted_customers != null) {
        String self_id = FirebaseAuth.instance.currentUser!.uid;
        SharedRideAcceptedCustomer? occurrence = _selectedRideBroadcast!
            .ride_details?.accepted_customers
            ?.firstWhere((customer) => customer.customer_id == self_id,
                orElse: () => SharedRideAcceptedCustomer()
                  ..customer_id = SEARCH_NOT_FOUND_ID);

        // we've been selected into accepted customer list
        if (occurrence != null &&
            occurrence.customer_id != SEARCH_NOT_FOUND_ID) {
          customerAcceptedIntoCar = true;
        } else {
          customerAcceptedIntoCar = false;
        }
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  double getAdjustedTurn() {
    double bearing = 0.0;
    if (_selectedRideBroadcast != null &&
        _selectedRideBroadcast?.broadcast_loc != null &&
        currentLocation != null) {
      bearing = Geolocator.bearingBetween(
          currentLocation!.latitude,
          currentLocation!.longitude,
          _selectedRideBroadcast!.broadcast_loc!.latitude,
          _selectedRideBroadcast!.broadcast_loc!.longitude);
    }

    double adjustedBearing = (bearing - _lastReadCompassAngels + 360) % 360;
    double finalBearing =
        (adjustedBearing < 180.0) ? adjustedBearing : (adjustedBearing - 360.0);
    _computedOffsetHeading = finalBearing / 360.0;

    return _computedOffsetHeading;
  }

  String distanceToCar() {
    if (_selectedRideBroadcast == null ||
        _selectedRideBroadcast?.broadcast_loc == null ||
        currentLocation == null ||
        metersToCar == -1) {
      isCustomerArrivedAtPickup = false;
      return "";
    }

    return "${AlphaNumericUtil.formatDouble(metersToCar, 0)} ሜትር";
  }

  String formatPhone(String phone) {
    if (phone.startsWith('+251')) {
      return "0" + phone.substring(4);
    } else {
      return phone;
    }
  }
}

class _AvailableDriverListItem extends StatefulWidget {
  final String placeId;
  final SharedRidePlaceAggregate placeAggregate;
  final Function(String placeId, bool isFourSeater) onFourSeaterSelected;
  final Function(String placeId, bool isFourSeater) onSixSeaterSelected;

  const _AvailableDriverListItem({
    Key? key,
    required this.placeId,
    required this.placeAggregate,
    required this.onFourSeaterSelected,
    required this.onSixSeaterSelected,
  }) : super(key: key);

  @override
  State<_AvailableDriverListItem> createState() => _AvailableRideListState();
}

class _AvailableRideListState extends State<_AvailableDriverListItem> {
  Widget _getCarSeaterWidget(bool isFourSeater, double moneyAmount,
      double hWidth, double vHeight, double DPI) {
    double perPersonPrice = moneyAmount / (isFourSeater ? 4.0 : 6.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (isFourSeater) {
          widget.onFourSeaterSelected(widget.placeId, true);
        } else {
          widget.onSixSeaterSelected(widget.placeId, false);
        }
      },
      child: Container(
        child: Row(
          children: [
            Container(
              width: hWidth * 0.135,
              height: vHeight * 0.035,
              child: Image(
                  image: AssetImage(
                      'images/${isFourSeater ? "s_suzuki" : "s_avanza"}.png')),
            ),
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ባለ ${isFourSeater ? "4" : "6"} መቀመጫ',
                    style: TextStyle(
                      fontFamily: 'Nokia Pure Headline Bold',
                      fontSize: 40 / DPI,
                    ),
                  ),
                  Text(
                    '${AlphaNumericUtil.formatDouble(perPersonPrice, 1)} ብር',
                    style: TextStyle(
                        fontFamily: 'Nokia Pure Headline Bold',
                        fontSize: 40 / DPI,
                        color: Color.fromRGBO(215, 0, 0, 1.0)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double vHeight = MediaQuery.of(context).size.height;
    double hWidth = MediaQuery.of(context).size.width;

    double devicePixelDensity = MediaQuery.of(context).devicePixelRatio;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        /**
         * if the list item has both a 4 AND a 6 seater, the actual seater option should be clicked
         * i.e: we can't know for sure which option was selected from the outside
         */
        if (widget.placeAggregate.nearby_four_seater_rides.isNotEmpty &&
            widget.placeAggregate.nearby_six_seater_rides.isNotEmpty) {
          return;
        }

        if (widget.placeAggregate.nearby_four_seater_rides.isNotEmpty) {
          widget.onFourSeaterSelected(widget.placeId, true);
        } else {
          widget.onSixSeaterSelected(widget.placeId, false);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: hWidth * 0.014,
          right: hWidth * 0.014,
          bottom: vHeight * 0.01,
        ),
        child: Container(
          decoration: BoxDecoration(
              color: Color.fromRGBO(245, 242, 242, 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 2.0,
                  spreadRadius: 0.0,
                  offset: Offset(2.0, 2.0),
                )
              ]),
          width: hWidth * 0.97,
          child: Column(
            children: [
              Container(
                height: vHeight * 0.050,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                      Color(0xFFDC0000),
                      Color(0xff8f0909),
                    ])),
                child: Center(
                  child: Text(
                      '${widget.placeAggregate.placeNameWithNumRides()}',
                      style: TextStyle(
                          fontSize: 45.0 / devicePixelDensity,
                          fontFamily: 'Nokia Pure Headline Bold',
                          color: Color.fromRGBO(255, 255, 255, 1.0))),
                ),
              ),
              Container(
                height: vHeight * 0.090,
                padding: EdgeInsets.symmetric(vertical: vHeight * 0.012),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Color(0xFFC2C1C1),
                      width: 0.3,
                    ),
                    bottom: BorderSide(
                      color: Color(0xFFC2C1C1),
                      width: 1.0,
                    ),
                    right: BorderSide(
                      color: Color(0xFFC2C1C1),
                      width: 0.3,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.placeAggregate.nearby_four_seater_rides
                        .isNotEmpty) ...[
                      _getCarSeaterWidget(
                          true,
                          widget.placeAggregate.four_seater_est_price!,
                          hWidth,
                          vHeight,
                          devicePixelDensity),
                    ],
                    if (widget.placeAggregate.nearby_four_seater_rides
                            .isNotEmpty &&
                        widget.placeAggregate.nearby_six_seater_rides
                            .isNotEmpty) ...[
                      VerticalDivider(
                        width: 1.0,
                        thickness: 1,
                        endIndent: 0,
                        color: Color.fromRGBO(203, 203, 203, 1.0),
                      ),
                    ],
                    if (widget
                        .placeAggregate.nearby_six_seater_rides.isNotEmpty) ...[
                      _getCarSeaterWidget(
                          false,
                          widget.placeAggregate.six_seater_est_price!,
                          hWidth,
                          vHeight,
                          devicePixelDensity),
                    ],
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SharedRidePlaceAggregate {
  String place_id;
  String place_name;

  double? four_seater_est_price;
  double? six_seater_est_price;

  // a quick cache to check/update when rides being added/removed from place
  Set<String> all_rides_to_place;

  Set<String> all_four_seater_rides;
  Set<String> all_six_seater_rides;

  List<String> nearby_four_seater_rides;
  List<String> nearby_six_seater_rides;

  Set<String> prev_seen_nearby_four_seater_rides;
  Set<String> prev_seen_nearby_six_seater_rides;

  SharedRidePlaceAggregate({
    required this.place_id,
    required this.place_name,
  })  : all_rides_to_place = Set(),
        all_four_seater_rides = Set(),
        all_six_seater_rides = Set(),
        prev_seen_nearby_four_seater_rides = Set(),
        prev_seen_nearby_six_seater_rides = Set(),
        nearby_four_seater_rides = [],
        nearby_six_seater_rides = [];

  String placeNameWithNumRides() {
    String count = (all_rides_to_place.length <= 1)
        ? ""
        : " (${all_rides_to_place.length})";
    return "$place_name$count";
  }
}