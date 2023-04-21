import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:safe/controller/shared_rides_where_to_go_screen.dart';
import 'package:safe/controller/slider_button/slider.dart';
import 'package:safe/driver_location/smooth_compass.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/shared_ride_broadcast.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
import 'package:safe/utils/phone_call.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/map_style.dart';

class WayToDriverCompassScreen extends StatefulWidget {
  final String selectedRideId;

  const WayToDriverCompassScreen({Key? key, required this.selectedRideId})
      : super(key: key);

  @override
  State<WayToDriverCompassScreen> createState() =>
      _WayToDriverCompassScreenState();
}

class _WayToDriverCompassScreenState extends State<WayToDriverCompassScreen> {
  static const CameraPosition ADDIS_ABABA_CENTER_LOCATION = CameraPosition(
      target: LatLng(9.00464643580664, 38.767820855962), zoom: 17.0);

  Set<Polyline> _mapPolyLines = Set();
  Set<Marker> _mapMarkers = Set();

  StreamSubscription? _rideDetailStreamSubscription;
  StreamSubscription? _rideLocationStreamSubscription;

  SharedRideLocation? _rideLocation;
  SharedRideBroadcast? _rideDetails;

  GoogleMapController? _mapController;

  StreamSubscription? _currentLocStreamSubscription;
  LatLng? _currentLocation;
  late Location liveLocation;

  double left_n_rgt = 0.0;

  bool isLeftTrue = false;

  static const double DEFAULT_SEARCH_RADIUS = 3.0;

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

    Future.delayed(Duration.zero, () async {
      _selfPhone = await PrefUtil.getCurrentUserPhone();

      liveLocation = new Location();
      await attachRideStreams();

      isCompassAvailable = await Compass().isCompassAvailable();
      if (isCompassAvailable) {
        _compassStreamSub = Compass()
            .compassUpdates(
                interval: const Duration(
                  milliseconds: 200,
                ),
                azimuthFix: 0.0,
                currentLoc: MyLoc(
                    latitude: _currentLocation?.latitude ?? 0,
                    longitude: _currentLocation?.longitude ?? 0))
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
    });

    arrowImage = AssetImage("images/arrow.png");
    compassImage = AssetImage("images/compass_base.png");
  }

  @override
  void dispose() {
    _rideDetailStreamSubscription?.cancel();
    _rideLocationStreamSubscription?.cancel();

    _currentLocStreamSubscription?.cancel();

    _compassStreamSub?.cancel();

    super.dispose();
  }

  Future<void> attachRideStreams() async {
    _rideLocationStreamSubscription = FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL: SharedRidesWhereToGoScreen.SHARED_RIDE_DATABASE_ROOT)
        .ref()
        .child(FIREBASE_DB_PATHS.SHARED_RIDE_LOCATIONS)
        .child(widget.selectedRideId)
        .onValue
        .listen((event) async {
      _rideLocation = SharedRideLocation.fromSnapshot(event.snapshot);
      if (_rideLocation?.ride_id == null) return;

      if (mounted) {
        setState(() {});
      }
    });

    _rideDetailStreamSubscription = FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL: SharedRidesWhereToGoScreen.SHARED_RIDE_DATABASE_ROOT)
        .ref()
        .child(FIREBASE_DB_PATHS.SHARED_RIDE_DETAILS)
        .child(widget.selectedRideId)
        .onValue
        .listen((event) async {
      _rideDetails = SharedRideBroadcast.fromSnapshot(event.snapshot);
      if (_rideDetails?.ride_id == null) return;

      if (_rideDetails?.accepted_customers != null) {
        String self_id = FirebaseAuth.instance.currentUser!.uid;
        SharedRideAcceptedCustomer? occurrence = _rideDetails
            ?.accepted_customers
            ?.firstWhere((customer) => customer.customer_id == self_id,
                orElse: () =>
                    SharedRideAcceptedCustomer()..customer_id = "none");

        // we've been selected into accepted customer list
        if (occurrence != null && occurrence.customer_id != "none") {
          customerAcceptedIntoCar = true;
        } else {
          customerAcceptedIntoCar = false;
        }
      }

      if (mounted) {
        setState(() {});
      }
    });

    PermissionStatus permissionStatus = await liveLocation.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await liveLocation.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }
    var locData;
    try {
      locData = await liveLocation.getLocation();
    } catch (e) {
      print(e);
      return;
    }

    _currentLocation = new LatLng(locData.latitude!, locData.longitude!);

    _currentLocStreamSubscription =
        liveLocation.onLocationChanged.listen((LocationData locData) async {
      _currentLocation = new LatLng(locData.latitude!, locData.longitude!);
      if (_rideLocation != null) {
        metersToCar = Geolocator.distanceBetween(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
            _rideLocation!.latitude!,
            _rideLocation!.longitude!);
        isCustomerArrivedAtPickup = metersToCar < 100.0;
        fontSizeMultiplier = isCustomerArrivedAtPickup ? 2.0 : 1.0;
      }

      if (mounted) {
        setState(() {});
      }
    });

    if (mounted) {
      setState(() {});
    }
  }

  double getAdjustedTurn() {
    double bearing = 0.0;
    if (_rideLocation != null && _currentLocation != null) {
      bearing = Geolocator.bearingBetween(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          _rideLocation!.latitude!,
          _rideLocation!.longitude!);
    }

    double adjustedBearing = (bearing - _lastReadCompassAngels + 360) % 360;
    double finalBearing =
        (adjustedBearing < 180.0) ? adjustedBearing : (adjustedBearing - 360.0);
    _computedOffsetHeading = finalBearing / 360.0;

    return _computedOffsetHeading;
  }

  String distanceToCar() {
    if (_rideLocation == null ||
        _currentLocation == null ||
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

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () {
                      Navigator.pop(context);
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
                            'ሹፌሮ ስም : ${_rideDetails?.driver_name ?? ''}',
                            style: driverDetailTextStyle,
                          ),
                          Text(
                            'ሹፌሮ ስልክ : ${formatPhone(_rideDetails?.driver_phone ?? '')}',
                            style: driverDetailTextStyle,
                          ),
                          Text(
                            'መኪና ታርጋ : ${_rideDetails?.car_plate ?? ''}',
                            style: driverDetailTextStyle,
                          ),
                          Text(
                            'መኪና : ${_rideDetails?.car_details ?? ""}',
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
                            'የአሽከርካሪው ስም : ${_rideDetails?.driver_name ?? ""}',
                            style: driverDetailTextStyleBig,
                          ),
                          Row(
                            children: [
                              Text(
                                'የአሽከርካሪው ስልክ: ${formatPhone(_rideDetails?.driver_phone ?? "")}',
                                style: driverDetailTextStyleBig,
                              ),
                              SizedBox(width: 10.0),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  try {
                                    PhoneCaller.callPhone(formatPhone(
                                        _rideDetails!.driver_phone!));
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
                            'የመኪናው ታርጋ ቁጥር : ${_rideDetails?.car_plate ?? ""}',
                            style: driverDetailTextStyleBig,
                          ),
                          Text(
                            'መኪናው : ${_rideDetails?.car_details ?? ""}',
                            style: driverDetailTextStyleBig,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Swipe to start
                  if (!customerSwipedToEnter && _rideDetails != null) ...[
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
                                _rideDetails?.reached_out_customers ?? [];
                            SharedRideReachOutCustomer occurrence =
                                prev_reached_out.firstWhere(
                                    (customer) =>
                                        customer.customer_id == self_id,
                                    orElse: () => SharedRideReachOutCustomer()
                                      ..customer_id = "none");

                            // current customer existed before, can't do anything about it
                            if (occurrence.customer_id == "none") {
                              prev_reached_out.add(SharedRideReachOutCustomer()
                                ..customer_id = self_id
                                ..customer_phone = self_phone);
                              rideDetails[SharedRideBroadcast
                                      .FIELD_REACHED_OUT_CUSTOMERS] =
                                  SharedRideBroadcast
                                      .SharedRideReachOutCustomers_ToJson(
                                          prev_reached_out);

                              await FirebaseDatabase.instanceFor(
                                      app: Firebase.app(),
                                      databaseURL: SharedRideBroadcast
                                          .SHARED_RIDE_DATABASE_ROOT)
                                  .ref()
                                  .child(FIREBASE_DB_PATHS.SHARED_RIDE_DETAILS)
                                  .child(widget.selectedRideId)
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
                    _rideDetails != null &&
                    !customerSwipedToEnter) ...[
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.18,
                    left: MediaQuery.of(context).size.width * 0.2,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Center(
                        child: Text(
                          '${_rideDetails?.seats_remaining ?? 4} ሰው የቀረው ...',
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
                                  _rideDetails?.place_name ?? "",
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
}
