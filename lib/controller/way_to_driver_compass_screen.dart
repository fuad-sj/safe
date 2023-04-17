import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:safe/controller/shared_rides_screen.dart';
import 'package:safe/driver_location/compass_ui.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/shared_ride_broadcast.dart';
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

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      liveLocation = new Location();
      await attachRideStreams();
    });

    arrowImage = AssetImage("images/arrow.png");
  }

  @override
  void dispose() {
    _rideDetailStreamSubscription?.cancel();
    _rideLocationStreamSubscription?.cancel();

    _currentLocStreamSubscription?.cancel();

    super.dispose();
  }

  Future<void> attachRideStreams() async {
    _rideLocationStreamSubscription = FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL: SharedRidesScreen.SHARED_RIDE_DATABASE_ROOT)
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
            databaseURL: SharedRidesScreen.SHARED_RIDE_DATABASE_ROOT)
        .ref()
        .child(FIREBASE_DB_PATHS.SHARED_RIDE_DETAILS)
        .child(widget.selectedRideId)
        .onValue
        .listen((event) async {
      _rideDetails = SharedRideBroadcast.fromSnapshot(event.snapshot);
      if (_rideDetails?.ride_id == null) return;

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
    //await liveLocation.requestPermission();
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
        });
  }

  @override
  Widget build(BuildContext context) {
    const double TOP_MAP_PADDING = 40;

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

              setState(() {
                // once location is acquired, add a bottom padding to the map
              });
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                end: Alignment.bottomRight,
                begin: Alignment.topRight,
                colors: [
                  Color(0xCFD30808),
                  Color(0xdddc0000),
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
                                'FINDING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "SAFE'S DRIVER",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.bold),
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
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.384,
                  left: MediaQuery.of(context).size.width * 0.082,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.60,
                  child: SmoothCompass(
                    compassBuilder: (context, snapshot, child) {
                      left_n_rgt = double.parse(
                          snapshot?.data?.angle.toStringAsFixed(2) ?? '0');

                      if (left_n_rgt <= 180) {
                        isLeftTrue = true;
                      }

                      double turns = 0.0;
                      if (_rideLocation != null && _currentLocation != null) {
                        double bearing = Geolocator.bearingBetween(
                            _currentLocation!.latitude,
                            _currentLocation!.longitude,
                            _rideLocation!.latitude!,
                            _rideLocation!.longitude!);

                        turns = bearing / 360.0;
                      }

                      return Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.19,
                              child: Center(
                                child: AnimatedRotation(
                                  //turns: snapshot?.data?.turns ?? 0,
                                  turns: turns,
                                  duration: Duration(milliseconds: 100),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    height: MediaQuery.of(context).size.height *
                                        0.10,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: arrowImage, fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.19),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.82,
                              child: Row(
                                children: [
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "15 m",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 41,
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          isLeftTrue!
                                              ? 'to your Left '
                                              : 'to your right',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
