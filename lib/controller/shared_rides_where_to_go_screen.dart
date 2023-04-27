import 'dart:async';

import 'package:dartx/dartx_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:safe/controller/way_to_driver_compass_screen.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/shared_ride_broadcast.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  Map<String, SharedRideBroadcast> _rideBroadcasts = Map();

  Map<String, SharedRidePlaceAggregate> _placeRideAggregate = Map();

  StreamSubscription? _locationStreamSubscription;
  late Location liveLocation;

  LatLng? currentLocation;

  List<MapEntry<String, SharedRidePlaceAggregate>> _destinationPlaces = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      liveLocation = new Location();

      await Geofire.initialize(FIREBASE_DB_PATHS.SHARED_RIDE_BROADCASTS,
          is_default: false,
          root: SharedRidesWhereToGoScreen.SHARED_RIDE_DATABASE_ROOT);

      setupNearbyOrdersQuery();
    });
  }

  @override
  void dispose() {
    Future.delayed(Duration.zero, () async {
      await Geofire.stopListener();
    });

    _geofireStream?.cancel();

    _locationStreamSubscription?.cancel();

    super.dispose();
  }

  Future<void> setupNearbyOrdersQuery() async {
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
    });

    /**
     * TODO: Relaunch the geofire query if the user has moved "too much". the query is a static one
     * i.e: it doesn't accommodate for changes in the user's live position
     */
    _geofireStream =
        Geofire.queryAtLocation(locData.latitude!, locData.longitude!, 10.0)
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

              updatePlaceRideAggregate(rideId);

              if (mounted) {
                setState(() {
                  _destinationPlaces = sortedPlaces();
                });
              }
              break;

            case Geofire.onKeyExited:
              updatePlaceRideAggregate(rideId, isRemoveOperation: true);
              _rideBroadcasts.remove(rideId);
              // TODO: update if ride has moved out of search radius

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

  int _compareRidesForSorting(String rideIdA, String rideIdB) {
    // TODO: check which sorting is being used, nearest distance or timestamp
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

  void pickSharedRideForPlaceAndSeater(String placeId, bool isFourSeater) {
    SharedRidePlaceAggregate aggregate = _placeRideAggregate[placeId]!;

    List<String> nearbyRides = isFourSeater
        ? aggregate.nearby_four_seater_rides
        : aggregate.nearby_six_seater_rides;

    String selectedRide = nearbyRides.first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WayToDriverCompassScreen(selectedRideId: selectedRide),
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
}
