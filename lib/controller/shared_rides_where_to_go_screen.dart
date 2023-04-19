import 'dart:async';
import 'dart:collection';

import 'package:dartx/dartx_io.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:safe/controller/way_to_driver_compass_screen.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/shared_ride_broadcast.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';

class SharedRidesWhereToGoScreen extends StatefulWidget {
  static const String SHARED_RIDE_DATABASE_ROOT =
      "https://safetransports-et-2995d.firebaseio.com/";

  const SharedRidesWhereToGoScreen({Key? key}) : super(key: key);

  @override
  State<SharedRidesWhereToGoScreen> createState() =>
      _SharedRidesWhereToGoScreenState();
}

class _SharedRidesWhereToGoScreenState
    extends State<SharedRidesWhereToGoScreen> {
  StreamSubscription<dynamic>? _geofireStream;

  StreamSubscription? _rideAddedDetailsStream;
  StreamSubscription? _rideUpdatedDetailsStream;

  bool _geoFireInitialized = false;

  Set<String> _validRideIDs = Set();
  Set<String> _loadedRideDetails = Set();

  Map<String, SharedRideLocation> _rideLocations = Map();
  Map<String, SharedRideBroadcast> _rideBroadcastDetails = Map();

  Map<String, SharedRidePlaceAggregate> _placeRideAggregate = Map();

  StreamSubscription? _locationStreamSubscription;
  late Location liveLocation;

  LatLng? current_location;

  List<MapEntry<String, SharedRidePlaceAggregate>> _destination_places = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      liveLocation = new Location();

      await Geofire.initialize(FIREBASE_DB_PATHS.SHARED_RIDE_LOCATIONS,
          is_default: false,
          root: SharedRidesWhereToGoScreen.SHARED_RIDE_DATABASE_ROOT);
      _geoFireInitialized = true;

      attachGeofireQuery();
      attachFirebaseListener();
    });
  }

  @override
  void dispose() {
    if (_geoFireInitialized) {
      Geofire.stopListener();
    }

    _loadedRideDetails.clear();
    _validRideIDs.clear();

    _geofireStream?.cancel();

    _rideAddedDetailsStream?.cancel();
    _rideUpdatedDetailsStream?.cancel();

    _locationStreamSubscription?.cancel();

    super.dispose();
  }

  Future<void> attachGeofireQuery() async {
    final String FIELD_CALLBACK = 'callBack';
    final String FIELD_KEY = 'key';
    final String FIELD_LATITUDE = 'latitude';
    final String FIELD_LONGITUDE = 'longitude';

    PermissionStatus permissionStatus = await liveLocation.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await liveLocation.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }
    var locData = await liveLocation.getLocation();

    current_location = new LatLng(locData.latitude!, locData.longitude!);

    _locationStreamSubscription =
        liveLocation.onLocationChanged.listen((LocationData locData) async {
      current_location = new LatLng(locData.latitude!, locData.longitude!);
    });

    /**
     * TODO: Relaunch the geofire query if the user has moved "too much". the query is a static one
     * i.e: it doesn't accommodate for changes in the user's live position
     */
    _geofireStream =
        Geofire.queryAtLocation(locData.latitude!, locData.longitude!, 1.0)
            ?.listen(
      (obj) async {
        if (obj == null) {
          return;
        }

        var callBack = obj[FIELD_CALLBACK];

        if (callBack != Geofire.onGeoQueryReady) {
          String ride_id = obj[FIELD_KEY];

          switch (callBack) {
            case Geofire.onKeyEntered:
            case Geofire.onKeyMoved:
              _validRideIDs.add(ride_id);
              _rideLocations[ride_id] = SharedRideLocation(
                ride_id: ride_id,
                latitude: obj[FIELD_LATITUDE],
                longitude: obj[FIELD_LONGITUDE],
              );

              updateBroadCastDistanceAndAggregate(ride_id);
              if (mounted) {
                setState(() {
                  _destination_places = sortedPlaces();
                });
              }
              break;

            case Geofire.onKeyExited:
              _validRideIDs.remove(ride_id);
              _rideLocations.remove(ride_id);
              // TODO: update if ride has moved out of search radius

              break;
          }
        }

        if (mounted) {
          setState(() {
            _destination_places = sortedPlaces();
          });
        }
      },
    );
  }

  Future<void> attachFirebaseListener() async {
    var data = await FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL: SharedRidesWhereToGoScreen.SHARED_RIDE_DATABASE_ROOT)
        .ref()
        .child(FIREBASE_DB_PATHS.SHARED_RIDE_DETAILS)
        .get();

    // if there is no document, it is null
    if (data.value != null) {
      LinkedHashMap<Object?, Object?> rideBroadcasts =
          data.value as LinkedHashMap;

      rideBroadcasts.forEach((key, value) {
        SharedRideBroadcast broadcast =
            SharedRideBroadcast.fromMap(value as Map, key as String);

        _rideBroadcastDetails[broadcast.ride_id] = broadcast;

        updateBroadCastDistanceAndAggregate(broadcast.ride_id);

        // if all load finished, update ui
        if (rideBroadcasts.length == _rideBroadcastDetails.length) {
          if (mounted) {
            _destination_places = sortedPlaces();
            setState(() {});
          }
        }
      });
    }

    _rideAddedDetailsStream = FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL: SharedRidesWhereToGoScreen.SHARED_RIDE_DATABASE_ROOT)
        .ref()
        .child(FIREBASE_DB_PATHS.SHARED_RIDE_DETAILS)
        .onChildAdded
        .listen((event) async {
      SharedRideBroadcast broadcast =
          SharedRideBroadcast.fromSnapshot(event.snapshot);

      _rideBroadcastDetails[broadcast.ride_id] = broadcast;

      updateBroadCastDistanceAndAggregate(broadcast.ride_id);

      if (mounted) {
        setState(() {
          _destination_places = sortedPlaces();
        });
      }
    });

    _rideUpdatedDetailsStream = FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL: SharedRidesWhereToGoScreen.SHARED_RIDE_DATABASE_ROOT)
        .ref()
        .child(FIREBASE_DB_PATHS.SHARED_RIDE_DETAILS)
        .onChildChanged
        .listen((event) async {
      SharedRideBroadcast broadcast =
          SharedRideBroadcast.fromSnapshot(event.snapshot);

      _rideBroadcastDetails[broadcast.ride_id] = broadcast;

      updateBroadCastDistanceAndAggregate(broadcast.ride_id);

      if (mounted) {
        setState(() {
          _destination_places = sortedPlaces();
        });
      }
    });
  }

  Future<void> updateBroadCastDistanceAndAggregate(String ride_id) async {
    computeDistanceToBroadcast(ride_id);
    aggregateByPlace(ride_id);
  }

  Future<void> computeDistanceToBroadcast(String ride_id) async {
    if (!_rideBroadcastDetails.containsKey(ride_id) ||
        !_rideLocations.containsKey(ride_id) ||
        current_location == null) return;

    SharedRideBroadcast broadcast = _rideBroadcastDetails[ride_id]!;
    SharedRideLocation location = _rideLocations[ride_id]!;

    broadcast.distance_to_broadcast = Geolocator.distanceBetween(
        location.latitude!,
        location.longitude!,
        current_location!.latitude,
        current_location!.longitude);
  }

  Future<void> aggregateByPlace(String ride_id) async {
    if (!_rideBroadcastDetails.containsKey(ride_id)) return;

    SharedRideBroadcast broadcast = _rideBroadcastDetails[ride_id]!;
    String place_id = broadcast.place_id;

    if (!_placeRideAggregate.containsKey(place_id)) {
      _placeRideAggregate[place_id] = SharedRidePlaceAggregate(
        place_id: place_id,
        place_name: broadcast.place_name,
      );
    }

    bool loc_available = _rideLocations.containsKey(ride_id);

    SharedRidePlaceAggregate aggregate = _placeRideAggregate[place_id]!;
    if (broadcast.is_six_seater) {
      aggregate.six_seater_est_price = broadcast.est_price;
      aggregate.all_six_seater_rides.add(ride_id);

      if (loc_available) {
        aggregate.nearby_six_seater_rides
          ..add(ride_id)
          ..sort(_compareRidesForSorting);
      }
    } else {
      aggregate.four_seater_est_price = broadcast.est_price;
      aggregate.all_four_seater_rides.add(ride_id);

      if (loc_available) {
        aggregate.nearby_four_seater_rides.add(ride_id);
        aggregate.nearby_four_seater_rides.sort(_compareRidesForSorting);
      }
    }
  }

  int _compareRidesForSorting(String rideIdA, String rideIdB) {
    // TODO: check which sorting is being used, nearest distance or timestamp
    if (!_rideBroadcastDetails.containsKey(rideIdA) ||
        !_rideBroadcastDetails.containsKey(rideIdB)) {
      return -1;
    }
    SharedRideBroadcast ride_A = _rideBroadcastDetails[rideIdA]!;
    SharedRideBroadcast ride_B = _rideBroadcastDetails[rideIdB]!;

    return ride_A.timestamp.compareTo(ride_B.timestamp);
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

  @override
  Widget build(BuildContext context) {
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                index = index % 2;
                return _AvailableDriverListItem(
                  placeId: _destination_places[index].key,
                  placeAggregate: _destination_places[index].value,
                  onFourSeaterSelected: pickSharedRideForPlaceAndSeater,
                  onSixSeaterSelected: pickSharedRideForPlaceAndSeater,
                );
              },
              childCount: _destination_places.length,
            ),
          )
        ],
      ),
    );
  }

  void pickSharedRideForPlaceAndSeater(String placeId, bool isFourSeater) {
    SharedRidePlaceAggregate aggregate = _placeRideAggregate[placeId]!;

    List<String> nearby_rides = isFourSeater
        ? aggregate.nearby_four_seater_rides
        : aggregate.nearby_six_seater_rides;

    String selected_ride = nearby_rides.first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WayToDriverCompassScreen(selectedRideId: selected_ride),
      ),
    );
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
  Widget _getCarSeaterWidget(bool is_four_seater, double money_amount,
      double hWidth, double vHeight, double DPI) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (is_four_seater) {
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
                      'images/${is_four_seater ? "s_suzuki" : "s_avanza"}.png')),
            ),
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ባለ ${is_four_seater ? "4" : "6"} መቀመጫ',
                    style: TextStyle(
                      fontFamily: 'Nokia Pure Headline Bold',
                      fontSize: 40 / DPI,
                    ),
                  ),
                  Text(
                    '${AlphaNumericUtil.formatDouble(money_amount, 2)} ብር',
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
                  child: Text(widget.placeAggregate.place_name,
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
