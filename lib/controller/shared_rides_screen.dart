import 'dart:async';
import 'dart:collection';

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

class SharedRidesScreen extends StatefulWidget {
  static const String SHARED_RIDE_DATABASE_ROOT =
      "https://safetransports-et-2995d.firebaseio.com/";

  const SharedRidesScreen({Key? key}) : super(key: key);

  @override
  State<SharedRidesScreen> createState() => _SharedRidesScreenState();
}

class _SharedRidesScreenState extends State<SharedRidesScreen> {
  StreamSubscription<dynamic>? _geofireStream;
  StreamSubscription? _rideDetailsStream;

  bool _geoFireInitialized = false;

  Set<String> _validRideIDs = Set();
  Set<String> _loadedRideDetails = Set();

  Map<String, SharedRideLocation> _rideLocations = Map();
  Map<String, SharedRideBroadcast> _rideBroadcastDetails = Map();

  Map<String, SharedRidePlaceAggregate> _placeRideAggregate = Map();
  Map<String, String> _selectedAggregateRides = Map();

  StreamSubscription? _locationStreamSubscription;
  late Location liveLocation;

  bool _geofireLoadComplete = false;

  LatLng? current_location;

  List<MapEntry<String, SharedRidePlaceAggregate>> _destination_places = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      liveLocation = new Location();

      await Geofire.initialize(FIREBASE_DB_PATHS.SHARED_RIDE_LOCATIONS,
          is_default: false, root: SharedRidesScreen.SHARED_RIDE_DATABASE_ROOT);
      _geoFireInitialized = true;

      await attachGeofireQuery();
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

    _rideDetailsStream?.cancel();

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
     * Relaunch the geofire query if the user has moved "too much". the query is a static one
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

        if (callBack == Geofire.onGeoQueryReady) {
          if (!_geofireLoadComplete) {
            _geofireLoadComplete = true;
            //attachFirebaseListener();
          }
        } else {
          String ride_id = obj[FIELD_KEY];

          switch (callBack) {
            case Geofire.onKeyEntered:
            case Geofire.onKeyMoved:
              _rideLocations[ride_id] = SharedRideLocation(
                ride_id: ride_id,
                latitude: obj[FIELD_LATITUDE],
                longitude: obj[FIELD_LONGITUDE],
              );
              updateDistanceToBroadcast(ride_id);
              aggregateByPlace(ride_id);
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

              if (_selectedAggregateRides.containsKey(ride_id)) {
                String place_id = _selectedAggregateRides[ride_id]!;
                _placeRideAggregate[place_id]!.selected_ride_id =
                    null; // reset to null as this is no longer the selected ride
                _selectedAggregateRides.remove(ride_id);
              }
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

    attachFirebaseListener();
  }

  Future<void> attachFirebaseListener() async {
    var data = await FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL: SharedRidesScreen.SHARED_RIDE_DATABASE_ROOT)
        .ref()
        .child(FIREBASE_DB_PATHS.SHARED_RIDE_DETAILS)
        .once();

    LinkedHashMap<Object?, Object?> rideBroadcasts =
        data.snapshot.value as LinkedHashMap;

    rideBroadcasts.forEach((key, value) {
      SharedRideBroadcast broadcast =
          SharedRideBroadcast.fromMap(value as Map, key as String);
      if (broadcast.ride_id == null) return;

      _rideBroadcastDetails[broadcast.ride_id!] = broadcast;

      updateDistanceToBroadcast(broadcast.ride_id!);
      aggregateByPlace(broadcast.ride_id!);

      if (mounted && rideBroadcasts.length == _rideBroadcastDetails.length) {
        _destination_places = sortedPlaces();
        setState(() {});
      }
    });

    _rideDetailsStream = FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL: SharedRidesScreen.SHARED_RIDE_DATABASE_ROOT)
        .ref()
        .child(FIREBASE_DB_PATHS.SHARED_RIDE_DETAILS)
        .onChildChanged
        .listen((event) async {
      SharedRideBroadcast broadcast =
          SharedRideBroadcast.fromSnapshot(event.snapshot);
      if (broadcast.ride_id == null) return;

      _rideBroadcastDetails[broadcast.ride_id!] = broadcast;

      updateDistanceToBroadcast(broadcast.ride_id!);
      aggregateByPlace(broadcast.ride_id!);

      if (mounted) {
        setState(() {
          _destination_places = sortedPlaces();
        });
      }
    });
  }

  Future<void> updateDistanceToBroadcast(String ride_id) async {
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
    /**
     * TODO: checking if the ride_id has been logged in our location set is the quickest way to rule out rides
     * that occurred in other places. as we haven't yet updated geofire, ALL places are included here, also ones
     * that aren't in our vicinity
     */
    if (!_rideLocations.containsKey(ride_id) ||
        !_rideBroadcastDetails.containsKey(ride_id)) return;

    SharedRideBroadcast broadcast = _rideBroadcastDetails[ride_id]!;
    String place_id = broadcast.dest_id!;

    if (!_placeRideAggregate.containsKey(place_id)) {
      _placeRideAggregate[place_id] = SharedRidePlaceAggregate(
        place_id: place_id,
        place_name: broadcast.dest_name!,
        est_price: broadcast.est_price!,
        place_rides: Set(),
      );
    }

    SharedRidePlaceAggregate placeAggregate = _placeRideAggregate[place_id]!;
    placeAggregate.place_rides.add(ride_id);
    if (placeAggregate.selected_ride_id == null ||
        // the selected place timestamp is larger, i.e: it is a newer broadcast. so an older version exists in the queue, so use that
        (placeAggregate.selected_ride_timestamp ?? -1) > broadcast.timestamp!) {
      placeAggregate.selected_ride_id = ride_id;
      placeAggregate.selected_ride_timestamp = broadcast.timestamp!;
      placeAggregate.selected_ride_distance = broadcast.distance_to_broadcast!;

      _selectedAggregateRides[ride_id] = place_id;
    }
  }

  List<MapEntry<String, SharedRidePlaceAggregate>> sortedPlaces() {
    return _placeRideAggregate.entries.toList()
      ..sort((a, b) => a.value.place_name.compareTo(b.value.place_name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        toolbarHeight: 50,
        backgroundColor: Color(0xffffffff),
        elevation: 0.0,
        leading: Transform.translate(
          offset: Offset(10, 1),
          child: new MaterialButton(
            elevation: 4.0,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xffDD0000),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Where do you wanna go?",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontFamily: 'Lato',
              fontSize: 21.0),
        ),
        actions: <Widget>[],
      ),
      body: ListView.builder(
        itemCount: _destination_places.length,
        itemBuilder: (context, index) {
          return _SharedPlaceListItem(
            placeId: _destination_places[index].key,
            placeAggregate: _destination_places[index].value,
            onPlaceSelected: (pickedPlace) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WayToDriverCompassScreen(
                      selectedRideId: pickSharedRideForPlace(pickedPlace)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /**
   * Apply appropriate logic to pick the ride from a set of rides for the place
   */
  String pickSharedRideForPlace(String placeId) {
    SharedRidePlaceAggregate placeAggregate = _placeRideAggregate[placeId]!;

    String selectedRideId = placeAggregate.selected_ride_id!;

    return selectedRideId;
  }
}

class _SharedPlaceListItem extends StatefulWidget {
  final String placeId;
  final SharedRidePlaceAggregate placeAggregate;
  final Function(String) onPlaceSelected;

  const _SharedPlaceListItem(
      {Key? key,
      required this.placeId,
      required this.placeAggregate,
      required this.onPlaceSelected})
      : super(key: key);

  @override
  State<_SharedPlaceListItem> createState() => _SharedPlaceListItemState();
}

class _SharedPlaceListItemState extends State<_SharedPlaceListItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onPlaceSelected(widget.placeId);
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                "${widget.placeAggregate.place_name} (${widget.placeAggregate.place_rides.length})",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    fontSize: 14.0)),
            Expanded(child: Container()),
            Icon(Icons.arrow_forward_ios_sharp),
          ],
        ),
      ),
    );
  }
}
