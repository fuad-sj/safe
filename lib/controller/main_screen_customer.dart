import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safe/controller/bottom_sheets/driver_picked_bottom_sheet.dart';
import 'package:safe/controller/bottom_sheets/driver_to_pickup_bottom_sheet.dart';
import 'package:safe/controller/bottom_sheets/searching_for_driver_bottom_sheet.dart';
import 'package:safe/controller/bottom_sheets/confirm_ride_details_bottom_sheet.dart';
import 'package:safe/controller/bottom_sheets/destination_picker_bottom_sheet.dart';
import 'package:safe/controller/bottom_sheets/select_dropoff_pin.dart';
import 'package:safe/controller/bottom_sheets/trip_details_bottom_sheet.dart';
import 'package:safe/controller/bottom_sheets/where_to_bottom_sheet.dart';
import 'package:safe/controller/customer_order_history.dart';
import 'package:safe/controller/dialogs/ride_cancellation_dialog.dart';
import 'package:safe/controller/dialogs/trip_summary_dialog.dart';
import 'package:safe/controller/login_page.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe/controller/ui_helpers.dart';
import 'package:safe/language_selector_dialog.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/models/driver.dart';
import 'package:safe/models/google_place_description.dart';
import 'package:safe/models/ride_request.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
import 'package:safe/utils/dummy_driver_generator.dart';
import 'package:safe/utils/google_api_util.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:safe/models/address.dart';
import 'package:safe/models/route_details.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:safe/models/driver_location.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:safe/utils/map_style.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:vector_math/vector_math.dart' as vectors;
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class MainScreenCustomer extends StatefulWidget {
  static const String idScreen = "mainScreenRider";

  @override
  _MainScreenCustomerState createState() => _MainScreenCustomerState();
}

class _MainScreenCustomerState extends State<MainScreenCustomer>
    with TickerProviderStateMixin {
  static const double DRIVER_RADIUS_KILOMETERS = 6.0;

  static const CameraPosition ADDIS_ABABA_CENTER_LOCATION = CameraPosition(
      target: LatLng(9.00464643580664, 38.767820855962), zoom: 12.0);

  static const int UI_STATE_NOTHING_STARTED = 1;
  static const int UI_STATE_WHERE_TO_SELECTED = 2;
  static const int UI_STATE_SELECT_PIN_SELECTED = 0;
  static const int UI_STATE_DROPOFF_SET = 3;
  static const int UI_STATE_SEARCHING_FOR_DRIVER = 4;
  static const int UI_STATE_DRIVER_PICKED = 5;
  static const int UI_STATE_DRIVER_CONFIRMED = 6;
  static const int UI_STATE_TRIP_STARTED = 8;
  static const int UI_STATE_TRIP_COMPLETED = 9;
  static const int UI_STATE_TRIP_SUMMARY_SHOWN = 10;

  final PolylinePoints _POLYLINE_POINTS_DECODER = PolylinePoints();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GoogleMapController? _mapController;

  bool _geoFireInitialized = false;

  int _UIState = UI_STATE_NOTHING_STARTED;

  List<DriverLocation> _nearByDrivers = [];

  bool _isHamburgerVisible = true;
  bool _isHamburgerDrawerMode = true;

  final double CAR_ICON_SIZE_RATIO = 0.22;
  final double PIN_ICON_SIZE_RATIO = 0.16;

  BitmapDescriptor? _CAR_ICON;
  BitmapDescriptor? _PICKUP_PIN_ICON;
  BitmapDescriptor? _DROPOFF_PIN_ICON;

  static const double SIZE_CURRENT_PIN_IMAGE = 45.0;
  Image? _CURRENT_PIN_ICON;

  Set<Polyline> _mapPolyLines = Set();
  Set<Marker> _mapMarkers = Set();

  Position? _currentPosition;

  double _mapBottomPadding = 0;

  LatLng? _tripStartedLocation;
  Timer? _tripCounterTimer;
  DateTime? _tripStartTimestamp;

  RouteDetails? _pickupToDropOffRouteDetail;

  bool _isNearbyDriverLoadingComplete = false;

  Customer? _currentCustomer;

  DocumentReference<Map<String, dynamic>>? _rideRequestRef;

  RideRequest? _currentRideRequest;

  StreamSubscription<dynamic>? _geofireLocationStream;

  Driver? _selectedDriver;
  DriverLocation? _selectedDriverCurrentLocation;
  StreamSubscription<dynamic>? _selectedDriverLocationStream;

  bool get isDriverSelected => _selectedDriver != null;

  bool get isDriverGoingToPickup => (_currentRideRequest != null &&
      _currentRideRequest!.ride_status == RideRequest.STATUS_DRIVER_CONFIRMED);

  bool get isTripStarted => (_currentRideRequest != null &&
      _currentRideRequest!.ride_status == RideRequest.STATUS_TRIP_STARTED);

  void setBottomMapPadding(double height) {
    const double MAP_BUFFER_HEIGHT = 5.0 + 15;
    _mapBottomPadding = height + MAP_BUFFER_HEIGHT;
  }

  @override
  initState() {
    super.initState();

    updateLoginCredentials();

    loadCurrentUserInfo();
    loadMapIcons();

    setBottomMapPadding(WhereToBottomSheet.HEIGHT_WHERE_TO);
  }

  void updateLoginCredentials() async {
    int loginStatus = PrefUtil.getLoginStatus();
    if (loginStatus == PrefUtil.LOGIN_STATUS_SIGNED_OUT) {
      return;
    } else if (loginStatus == PrefUtil.LOGIN_STATUS_LOGIN_JUST_NOW) {
      Map<String, dynamic> updatedFields = Map();

      updatedFields[Customer.FIELD_DATE_LAST_LOGIN] = DateTime.now();
      updatedFields[Customer.FIELD_PHONE_NUMBER] =
          PrefUtil.getCurrentUserPhone();
      updatedFields[Customer.FIELD_IS_LOGGED_IN] = true;

      await FirebaseFirestore.instance
          .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
          .doc(PrefUtil.getCurrentUserID())
          .set(updatedFields, SetOptions(merge: true));

      await PrefUtil.setLoginStatus(PrefUtil.LOGIN_STATUS_PREVIOUSLY_LOGGED_IN);
    }

    await saveDeviceRegistrationToken();
  }

  Future<void> saveDeviceRegistrationToken() async {
    String? newToken = await FirebaseMessaging.instance.getToken();
    if (newToken == null) {
      print('Error fetching FCM token');
      return;
    }

    var customerDoc = await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
        .doc(PrefUtil.getCurrentUserID())
        .get();

    Customer customer = Customer.fromSnapshot(customerDoc);
    if (!customer.documentExists()) {
      return;
    }

    List<String> deviceTokens = customer.device_registration_tokens ?? [];

    // token already exists, don't add
    if (deviceTokens.contains(newToken)) {
      return;
    }

    deviceTokens.add(newToken);

    Map<String, dynamic> updatedFields = {
      Customer.FIELD_DEVICE_REGISTRATION_TOKENS: deviceTokens,
    };

    await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
        .doc(PrefUtil.getCurrentUserID())
        .set(
          updatedFields,
          SetOptions(mergeFields: updatedFields.keys.toList()),
        );
  }

  void loadCurrentUserInfo() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      Customer customer = Customer.fromSnapshot(
        await FirebaseFirestore.instance
            .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
            .doc(userId)
            .get(),
      );
      if (customer.documentExists()) {
        _currentCustomer = customer;
      }
    }
  }

  void loadMapIcons() async {
    _CAR_ICON = await AlphaNumericUtil.getBytesFromAsset(
        context, 'images/car.png', CAR_ICON_SIZE_RATIO);

    _PICKUP_PIN_ICON = await AlphaNumericUtil.getBytesFromAsset(
        context, 'images/dot_red.png', PIN_ICON_SIZE_RATIO);
    _DROPOFF_PIN_ICON = await AlphaNumericUtil.getBytesFromAsset(
        context, 'images/dot_blue.png', PIN_ICON_SIZE_RATIO);

    _CURRENT_PIN_ICON = Image.asset(
      'images/pin_location.png',
      height: SIZE_CURRENT_PIN_IMAGE,
      width: SIZE_CURRENT_PIN_IMAGE,
    );
  }

  void resetTripDetails() {
    _UIState = UI_STATE_NOTHING_STARTED;
    _isHamburgerDrawerMode = true;

    setBottomMapPadding(WhereToBottomSheet.HEIGHT_WHERE_TO);

    _mapPolyLines.clear();
    _mapMarkers.clear();

    attachGeoFireListener();
    zoomCameraToCurrentPosition();

    _selectedDriver = null;
    _selectedDriverLocationStream?.cancel();
    _selectedDriverLocationStream = null;

    _pickupToDropOffRouteDetail = null;

    _isHamburgerVisible = true;

    _tripStartedLocation = null;
    _tripStartTimestamp = null;
    _tripCounterTimer?.cancel();
    _tripCounterTimer = null;

    _rideRequestRef = null;
    _currentRideRequest = null;

    setState(() {});
  }

  Widget _getNavigationItemWidget(
      BuildContext context,
      _MenuListItem item,
      double leftPadding,
      double verticalPadding,
      double betweenSpace,
      void Function(MenuOption) callback) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        callback(item.navOption);
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
            left: leftPadding, top: verticalPadding, bottom: verticalPadding),
        child: Row(
          children: [
            Icon(item.icon, color: item.iconColor),
            SizedBox(width: betweenSpace),
            Text(item.title),
          ],
        ),
      ),
    );
  }

  void navOptionSelected(MenuOption option) {
    switch (option) {
      case MenuOption.MENU_OPTION_MY_TRIPS:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CustomerOrderHistory()),
        );
        break;

      case MenuOption.MENU_OPTION_LANGUAGES:
        showDialog(
          context: context,
          builder: (_) => LanguageSelectorDialog(),
        );
        break;
    }
  }

  String _getCustomerPhone(BuildContext context) {
    String phone = PrefUtil.getCurrentUserPhone();
    if (phone.startsWith('+251')) {
      String prefix = phone.substring(4, 7);
      String suffix = phone.substring(10);
      String combined = prefix + '***' + suffix;
      return combined;
    }
    // TODO: get back to user's phone
    return '912***275';
    //return phone;
  }

  Widget _getDrawerLayout(BuildContext context) {
    double DRAWER_WIDTH_PERCENT = 0.76;
    double PROFILE_HEIGHT_PERCENT = 0.14;

    double HORIZONTAL_LEFT_PADDING_PERCENT = 0.1;
    double VERTICAL_PADDING_PERCENT = 0.018;
    double HORIZONTAL_BETWEEN_SPACE_PERCENT = 0.08;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double profileHeight = screenHeight * PROFILE_HEIGHT_PERCENT;
    double drawerWidth = DRAWER_WIDTH_PERCENT * screenWidth;

    double horizontalPadding = drawerWidth * HORIZONTAL_LEFT_PADDING_PERCENT;
    double verticalPadding = screenHeight * VERTICAL_PADDING_PERCENT;
    double horizontalSpace = drawerWidth * HORIZONTAL_BETWEEN_SPACE_PERCENT;

    List<_MenuListItem> primaryNavOptions = [
      _MenuListItem(
          Icons.history,
          SafeLocalizations.of(context)!.nav_option_my_trips,
          MenuOption.MENU_OPTION_MY_TRIPS,
          Colors.orange.shade600),
      _MenuListItem(
          Icons.attach_money,
          SafeLocalizations.of(context)!.nav_option_payment,
          MenuOption.MENU_OPTION_PAYMENT,
          Colors.teal.shade600),
      _MenuListItem(
          Icons.settings,
          SafeLocalizations.of(context)!.nav_option_settings,
          MenuOption.MENU_OPTION_SETTINGS,
          Colors.blue.shade600),
      _MenuListItem(
          Icons.language,
          SafeLocalizations.of(context)!.nav_option_languages,
          MenuOption.MENU_OPTION_LANGUAGES,
          Colors.grey.shade600),
    ];

    List<_MenuListItem> secondaryNavOptions = [
      _MenuListItem(
          Icons.phone,
          SafeLocalizations.of(context)!.nav_option_contact_us,
          MenuOption.MENU_OPTION_CONTACT_US,
          Colors.blueGrey.shade600),
      _MenuListItem(
          Icons.help,
          SafeLocalizations.of(context)!.nav_option_emergency,
          MenuOption.MENU_OPTION_EMERGENCY,
          Colors.red.shade600),
      _MenuListItem(
          Icons.logout,
          SafeLocalizations.of(context)!.nav_option_sign_out,
          MenuOption.MENU_OPTION_SIGNOUT,
          Colors.grey.shade600),
    ];

    return Container(
      width: drawerWidth,
      child: Drawer(
        child: ListView(
          children: [
            // Profile header
            Container(
              height: profileHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(22.0),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade300],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: horizontalPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getCustomerPhone(context),
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.grey.shade900,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Brand-Bold"),
                          ),
                          SizedBox(height: 6.0),
                          Text(
                              SafeLocalizations.of(context)!
                                  .nav_header_edit_profile,
                              style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: horizontalPadding),
                      child: Image.asset('images/user_icon.png',
                          height: 65.0, width: 65.0),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.0),

            ...primaryNavOptions.map(
              (item) => _getNavigationItemWidget(
                context,
                item,
                horizontalPadding,
                verticalPadding,
                horizontalSpace,
                navOptionSelected,
              ),
            ),

            greyVerticalDivider(0.5),

            ...secondaryNavOptions.map(
              (item) => _getNavigationItemWidget(
                context,
                item,
                horizontalPadding,
                verticalPadding,
                horizontalSpace,
                navOptionSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getHamburgerBtnWidget() {
    return Positioned(
      top: 55.0,
      left: 22.0,
      child: GestureDetector(
        onTap: () {
          // open drawer
          if (_isHamburgerDrawerMode) {
            _scaffoldKey.currentState!.openDrawer();
          } else {
            cancelCurrentRideRequest();
            resetTripDetails();
          }
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
            child: Icon(_isHamburgerDrawerMode ? Icons.menu : Icons.close,
                color: Colors.grey.shade800),
            radius: 24.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double TOP_MAP_PADDING = 40;

    if (_UIState == UI_STATE_TRIP_COMPLETED) {
      _UIState = UI_STATE_TRIP_SUMMARY_SHOWN;

      /**
       * !!! VERY IMPORTANT !!!
       * can't directly call [showDialog], schedule it for next cycle
       * checkout details: https://stackoverflow.com/a/52062540
       */
      Future.delayed(
        Duration.zero,
        () async {
          await showDialog(
            context: context,
            builder: (_) =>
                TripCompletionDialog(rideRequest: _currentRideRequest!),
          );

          resetTripDetails();
        },
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _getDrawerLayout(context),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(
              top: TOP_MAP_PADDING,
              bottom: _UIState == UI_STATE_SELECT_PIN_SELECTED
                  ? 0
                  : _mapBottomPadding,
            ),
            polylines: _mapPolyLines,
            mapType: MapType.normal,
            myLocationButtonEnabled: _UIState != UI_STATE_SELECT_PIN_SELECTED,
            initialCameraPosition: ADDIS_ABABA_CENTER_LOCATION,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: _UIState != UI_STATE_SELECT_PIN_SELECTED,
            markers: _mapMarkers,
            onMapCreated: (GoogleMapController controller) async {
              _mapController = controller;
              controller.setMapStyle(GoogleMapStyle.mapStyles);

              setState(() {
                // once location is acquired, add a bottom padding to the map
                setBottomMapPadding(WhereToBottomSheet.HEIGHT_WHERE_TO);
              });

              bool locationAcquired = await zoomCameraToCurrentPosition();

              // start listening to nearby drivers once location is acquired
              if (locationAcquired) {
                await initGeoFireListener();
              }
            },
          ),

          // Hamburger + Cancel Ride
          if (_isHamburgerVisible &&
              _UIState != UI_STATE_SELECT_PIN_SELECTED) ...[
            _getHamburgerBtnWidget(),
          ],

          //
          WhereToBottomSheet(
            tickerProvider: this,
            showBottomSheet: _UIState == UI_STATE_NOTHING_STARTED,
            actionCallback: () {
              _UIState = UI_STATE_WHERE_TO_SELECTED;

              setBottomMapPadding(
                  DestinationPickerBottomSheet.HEIGHT_DESTINATION_SELECTOR);

              _isHamburgerDrawerMode = false;

              setState(() {});
            },
          ),

          //
          DestinationPickerBottomSheet(
            tickerProvider: this,
            showBottomSheet: _UIState == UI_STATE_WHERE_TO_SELECTED,
            onSelectPinCalled: () {
              _UIState = UI_STATE_SELECT_PIN_SELECTED;
              setState(() {});
            },
            callback: () async {
              await getRouteDetails(context);
              _UIState = UI_STATE_DROPOFF_SET;

              _isHamburgerDrawerMode = false;
              setBottomMapPadding(
                  ConfirmRideDetailsBottomSheet.HEIGHT_RIDE_DETAILS);

              // stop showing nearby drivers
              stopGeofireListener();

              setState(() {});
            },
          ),

          if (_UIState == UI_STATE_SELECT_PIN_SELECTED &&
              _CURRENT_PIN_ICON != null) ...[
            SelectDropOffPinBottomSheet(
              tickerProvider: this,
              showBottomSheet: _UIState == UI_STATE_SELECT_PIN_SELECTED,
              CURRENT_PIN_ICON: _CURRENT_PIN_ICON!,
              currentPosition: _currentPosition!,
              onBackSelected: () {
                _UIState = UI_STATE_WHERE_TO_SELECTED;
                setState(() {});
              },
              callback: () async {
                await getRouteDetails(context);
                _UIState = UI_STATE_DROPOFF_SET;

                _isHamburgerDrawerMode = false;
                setBottomMapPadding(
                    ConfirmRideDetailsBottomSheet.HEIGHT_RIDE_DETAILS);

                // stop showing nearby drivers
                stopGeofireListener();

                setState(() {});
              },
            ),
          ],

          //
          ConfirmRideDetailsBottomSheet(
            tickerProvider: this,
            showBottomSheet: _UIState == UI_STATE_DROPOFF_SET,
            routeDetails: _pickupToDropOffRouteDetail,
            actionCallback: () async {
              // TODO: show progress while creating order
              await createNewRideRequest();

              // Will update UI when either driver is assigned OR trip is cancelled
              await listenToRideStatusUpdates();

              setBottomMapPadding(
                  SearchingForDriverBottomSheet.HEIGHT_SEARCHING_FOR_DRIVER);

              _isHamburgerDrawerMode = true;

              _UIState = UI_STATE_SEARCHING_FOR_DRIVER;
              setState(() {});
            },
          ),

          //
          SearchingForDriverBottomSheet(
            tickerProvider: this,
            showBottomSheet: _UIState == UI_STATE_SEARCHING_FOR_DRIVER,
            actionCallback: () async {
              await showDialog(
                context: context,
                builder: (_) =>
                    RideCancellationDialog(rideRequest: _currentRideRequest!),
              );
            },
          ),

          // Tentatively Picked Driver
          DriverPickedBottomSheet(
            tickerProvider: this,
            showBottomSheet: _UIState == UI_STATE_DRIVER_PICKED,
            pickedDriver: _selectedDriver,
            actionCallback: () async {
              await showDialog(
                context: context,
                builder: (_) =>
                    RideCancellationDialog(rideRequest: _currentRideRequest!),
              );
            },
          ),

          //
          DriverToPickupBottomSheet(
            tickerProvider: this,
            showBottomSheet: _UIState == UI_STATE_DRIVER_CONFIRMED,
            pickedDriver: _selectedDriver,
            rideRequest: _currentRideRequest,
            actionCallback: () {
              // TODO: nothing to do here, just sitting and waiting
            },
          ),

          //
          TripDetailsBottomSheet(
            tickerProvider: this,
            showBottomSheet: _UIState == UI_STATE_TRIP_STARTED,
            pickedDriver: _selectedDriver,
            rideRequest: _currentRideRequest,
            currentPosition: _currentPosition,
            tripStartedLocation: _tripStartedLocation,
            tripCounterTimer: _tripCounterTimer,
            tripStartTimestamp: _tripStartTimestamp,
            actionCallback: () {
              // TODO: nothing to do here, just sitting and waiting
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tripCounterTimer?.cancel();
    super.dispose();
  }

  Future<void> listenToRideStatusUpdates() async {
    _rideRequestRef?.snapshots().listen(
      (snapshot) async {
        _currentRideRequest = RideRequest.fromSnapshot(snapshot);

        int rideStatus = _currentRideRequest!.ride_status;

        // driver couldn't be found, or error happened.
        if (RideRequest.isRideRequestCancelled(rideStatus)) {
          resetTripDetails();

          return;
        } else if (!RideRequest.hasDriverBeenPicked(rideStatus)) {
          // the request was probably just created and got an event for that, ignore it
          return;
        }

        String driverId = _currentRideRequest!.driver_id!;

        bool isDriverPicked = rideStatus == RideRequest.STATUS_DRIVER_PICKED;
        bool isOnWayToPickup =
            rideStatus == RideRequest.STATUS_DRIVER_CONFIRMED;
        bool hasTripStarted = rideStatus == RideRequest.STATUS_TRIP_STARTED;

        if (rideStatus == RideRequest.STATUS_TRIP_COMPLETED) {
          // note: trip summary will be shown next build cycle
          _UIState = UI_STATE_TRIP_COMPLETED;
          setState(() {});
          return;
        }

        if (rideStatus == RideRequest.STATUS_DRIVER_PICKED) {
          _mapMarkers.clear();
        }

        _selectedDriver = Driver.fromSnapshot(
          await FirebaseFirestore.instance
              .collection(FIRESTORE_PATHS.COL_DRIVERS)
              .doc(driverId)
              .get(),
        );

        Color? pathColor;
        String? encodedPathRoute;
        int? lineWidth;

        if (isDriverPicked) {
          pathColor = Color(0xff299bfb);
          encodedPathRoute =
              _currentRideRequest!.driver_to_pickup_encoded_points!;
          lineWidth = 3;

          setBottomMapPadding(DriverPickedBottomSheet.HEIGHT_DRIVER_PICKED);
          _isHamburgerVisible = false;

          _UIState = UI_STATE_DRIVER_PICKED;
        } else if (isOnWayToPickup) {
          pathColor = Color(0xff299bfb);
          encodedPathRoute =
              _currentRideRequest!.driver_to_pickup_encoded_points!;
          lineWidth = 5;

          setBottomMapPadding(
              DriverToPickupBottomSheet.HEIGHT_DRIVER_ON_WAY_TO_PICKUP);

          _UIState = UI_STATE_DRIVER_CONFIRMED;
        } else if (hasTripStarted) {
          pathColor = Color(0xff299bfb);
          encodedPathRoute = _currentRideRequest!
              .actual_pickup_to_initial_dropoff_encoded_points!;
          lineWidth = 5;

          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.bestForNavigation);

          // This is the start location, not the pickup location
          _tripStartedLocation =
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

          // kill off previous timer
          _tripCounterTimer?.cancel();

          _tripStartTimestamp = DateTime.now();
          _tripCounterTimer = new Timer.periodic(
            const Duration(seconds: 1),
            (Timer timer) {
              setState(() {});
            },
          );

          setBottomMapPadding(TripDetailsBottomSheet.HEIGHT_TRIP_DETAILS);
          _UIState = UI_STATE_TRIP_STARTED;
        }

        if (encodedPathRoute != null) {
          _mapPolyLines = {
            Polyline(
              polylineId: PolylineId('driver line'),
              color: pathColor!,
              jointType: JointType.round,
              points: _POLYLINE_POINTS_DECODER
                  .decodePolyline(encodedPathRoute)
                  .map((loc) => LatLng(loc.latitude, loc.longitude))
                  .toList(),
              width: lineWidth!,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              geodesic: true,
            )
          };

          // TODO: add markers to customer's pickup/destination locations
        }

        // cancel any previous driver's location stream
        _selectedDriverCurrentLocation = null;
        _selectedDriverLocationStream?.cancel();
        _selectedDriverLocationStream = FirebaseDatabase.instance
            .reference()
            .child(FIREBASE_DB_PATHS.PATH_GEOFIRE_AVAILABLE_DRIVERS)
            .child(driverId)
            .onValue
            .listen(
          (locSnapshot) {
            bool firstTimeLocationAcquired =
                _selectedDriverCurrentLocation == null;
            _selectedDriverCurrentLocation =
                DriverLocation.fromSnapshot(locSnapshot.snapshot);

            if (firstTimeLocationAcquired) {
              bool has_trip_started = _currentRideRequest!.ride_status ==
                  RideRequest.STATUS_TRIP_STARTED;

              zoomCameraToWithinBounds(
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                has_trip_started
                    ? _currentRideRequest!.dropoff_location!
                    : _selectedDriverCurrentLocation!.getLocationLatLng,
              );
            }

            _mapMarkers = {
              Marker(
                markerId: MarkerId(
                    'driver${_selectedDriverCurrentLocation!.driverID}'),
                position: LatLng(_selectedDriverCurrentLocation!.latitude,
                    _selectedDriverCurrentLocation!.longitude),
                icon: _CAR_ICON ?? BitmapDescriptor.defaultMarker,
                rotation: 0,
              ),
            };

            setState(() {});
          },
        );

        setState(() {});
      },
    );
  }

  Future<bool> zoomCameraToCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _currentPosition = position;

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 14.0);

      _mapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      Address? address = await GoogleApiUtils.searchCoordinateAddress(position);

      if (address == null) {
        return false;
      }

      Provider.of<PickUpAndDropOffLocations>(context, listen: false)
          .updatePickupLocationAddress(address);
      return true;
    } catch (err) {}

    return false;
  }

  Future<void> createNewRideRequest() async {
    Address pickUpAddress =
        Provider.of<PickUpAndDropOffLocations>(context, listen: false)
            .pickUpLocation!;
    Address dropOffAddress =
        Provider.of<PickUpAndDropOffLocations>(context, listen: false)
            .dropOffLocation!;

    RideRequest ride = RideRequest();

    ride.ride_status = RideRequest.STATUS_PLACED;
    ride.customer_id = PrefUtil.getCurrentUserID();
    ride.customer_name = _currentCustomer!.user_name!;
    ride.customer_phone = _currentCustomer!.phone_number!;
    ride.customer_device_token = await FirebaseMessaging.instance.getToken();
    ride.pickup_location = pickUpAddress.location;
    ride.pickup_address_name = pickUpAddress.placeName;
    ride.dropoff_location = dropOffAddress.location;
    ride.dropoff_address_name = dropOffAddress.placeName;
    ride.date_ride_created = DateTime.now();

    _rideRequestRef = await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_RIDES)
        .add(ride.toJson());
  }

  Future<void> cancelCurrentRideRequest() async {
    // set order_status field to deleted
    Map<String, dynamic> updateFields = {
      RideRequest.FIELD_RIDE_STATUS: RideRequest.STATUS_DELETED,
    };

    await _rideRequestRef?.set(
      updateFields,
      SetOptions(merge: true),
    );
  }

  Future<void> getRouteDetails(BuildContext context) async {
    Address startLocation =
        Provider.of<PickUpAndDropOffLocations>(context, listen: false)
            .pickUpLocation!;
    Address destLocation =
        Provider.of<PickUpAndDropOffLocations>(context, listen: false)
            .dropOffLocation!;

    LatLng pickUpLoc = startLocation.location;
    LatLng dropOffLoc = destLocation.location;

    CustomProgressDialog.showProgressDialog(
        context: context,
        message: SafeLocalizations.of(context)!.progress_dialog_please_wait);

    _pickupToDropOffRouteDetail =
        await GoogleApiUtils.getRouteDetailsFromStartToDestination(
            pickUpLoc, dropOffLoc);

    Navigator.pop(context);

    _mapPolyLines = {
      Polyline(
        polylineId: PolylineId('route line id'),
        color: Color(0xff299bfb),
        jointType: JointType.round,
        points: _POLYLINE_POINTS_DECODER
            .decodePolyline(_pickupToDropOffRouteDetail!.encodedPoints)
            // convert from [PointLatLng] to [LatLng]
            .map((loc) => LatLng(loc.latitude, loc.longitude))
            .toList(),
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      )
    };

    // Start and destination marker pins
    _mapMarkers = {
      // pickup marker
      Marker(
        markerId: MarkerId('pickup id'),
        icon: _PICKUP_PIN_ICON ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: InfoWindow(
            title: startLocation.placeName,
            snippet:
                SafeLocalizations.of(context)!.customer_marker_info_pickup),
        position: pickUpLoc,
      ),
      // dropoff marker
      Marker(
        markerId: MarkerId('dropoff id'),
        icon: _DROPOFF_PIN_ICON ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
            title: destLocation.placeName,
            snippet:
                SafeLocalizations.of(context)!.customer_marker_info_dropoff),
        position: dropOffLoc,
      ),
    };

    zoomCameraToWithinBounds(_pickupToDropOffRouteDetail!.pickUpLoc,
        _pickupToDropOffRouteDetail!.dropOffLoc);
  }

  void zoomCameraToWithinBounds(LatLng startLoc, LatLng finalLoc) {
    LatLng south, north;
    if (startLoc.latitude > finalLoc.latitude &&
        startLoc.longitude > finalLoc.longitude) {
      south = finalLoc;
      north = startLoc;
    } else if (startLoc.longitude > finalLoc.longitude) {
      south = LatLng(startLoc.latitude, finalLoc.longitude);
      north = LatLng(finalLoc.latitude, startLoc.longitude);
    } else if (startLoc.latitude > finalLoc.latitude) {
      south = LatLng(finalLoc.latitude, startLoc.longitude);
      north = LatLng(startLoc.latitude, finalLoc.longitude);
    } else {
      south = startLoc;
      north = finalLoc;
    }

    LatLngBounds latLngBounds =
        LatLngBounds(southwest: south, northeast: north);
    _mapController!
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
  }

  Future<bool> initGeoFireListener() async {
    await Geofire.initialize(FIREBASE_DB_PATHS.PATH_GEOFIRE_AVAILABLE_DRIVERS);

    _geoFireInitialized = true;

    attachGeoFireListener();

    return true;
  }

  void attachGeoFireListener() {
    final String FIELD_CALLBACK = 'callBack';
    final String FIELD_KEY = 'key';
    final String FIELD_LATITUDE = 'latitude';
    final String FIELD_LONGITUDE = 'longitude';

    if (!_geoFireInitialized || _geofireLocationStream != null) return;

    _geofireLocationStream = Geofire.queryAtLocation(_currentPosition!.latitude,
            _currentPosition!.longitude, DRIVER_RADIUS_KILOMETERS)
        ?.listen(
      (map) {
        if (map != null) {
          var callBack = map[FIELD_CALLBACK];

          switch (callBack) {
            case Geofire.onKeyEntered:
              addOrUpdateDriverLocation(
                DriverLocation(
                  driverID: map[FIELD_KEY],
                  latitude: map[FIELD_LATITUDE],
                  longitude: map[FIELD_LONGITUDE],
                ),
              );
              if (_isNearbyDriverLoadingComplete) {
                updateAvailableDriversOnMap();
              }
              break;

            case Geofire.onKeyExited:
              String driver_ID = map[FIELD_KEY];
              _nearByDrivers
                  .removeWhere((driver) => (driver.driverID == driver_ID));
              updateAvailableDriversOnMap();
              break;

            case Geofire.onKeyMoved:
              addOrUpdateDriverLocation(
                DriverLocation(
                  driverID: map[FIELD_KEY],
                  latitude: map[FIELD_LATITUDE],
                  longitude: map[FIELD_LONGITUDE],
                ),
              );
              updateAvailableDriversOnMap();
              break;

            case Geofire.onGeoQueryReady:
              _isNearbyDriverLoadingComplete = true;
              updateAvailableDriversOnMap();

              break;
          }
        }

        setState(() {});
      },
    );
  }

  void stopGeofireListener() async {
    if (!_geoFireInitialized) return;

    await Geofire.stopListener();

    _geofireLocationStream?.cancel();
    _geofireLocationStream = null;
  }

  void updateAvailableDriversOnMap() {
    _mapMarkers = _nearByDrivers
        .map(
          (driver) => Marker(
            markerId: MarkerId('driver${driver.driverID}'),
            position: LatLng(driver.latitude, driver.longitude),
            icon: _CAR_ICON ?? BitmapDescriptor.defaultMarker,
            rotation: driver.orientation ?? 0,
          ),
        )
        .toSet();
  }

  void addOrUpdateDriverLocation(DriverLocation driverLoc) async {
    int prevIndex = _nearByDrivers
        .indexWhere((driver) => (driver.driverID == driverLoc.driverID));

    if (prevIndex != -1) {
      double prev_lat = _nearByDrivers[prevIndex].latitude;
      double prev_long = _nearByDrivers[prevIndex].longitude;

      double delta_lat = driverLoc.latitude - prev_lat;
      double delta_lng = driverLoc.longitude - prev_long;

      double bearing = vectors.degrees(atan(delta_lng / delta_lat)) + 90;

      if (prev_lat < driverLoc.latitude && prev_long < driverLoc.longitude) {
        // Do nothing;
      } else if (prev_lat >= driverLoc.latitude &&
          prev_long < driverLoc.longitude) {
        bearing = 180 - bearing;
      } else if (prev_lat >= driverLoc.latitude &&
          prev_long >= driverLoc.longitude) {
        bearing = bearing + 180;
      } else if (prev_lat < driverLoc.latitude &&
          prev_long >= driverLoc.longitude) {
        bearing = 360 - bearing;
      }

      _nearByDrivers[prevIndex].latitude = driverLoc.latitude;
      _nearByDrivers[prevIndex].longitude = driverLoc.longitude;
      _nearByDrivers[prevIndex].orientation = bearing;
    } else {
      driverLoc.orientation = 0; // start off as 0 degrees
      _nearByDrivers.add(driverLoc);
    }
  }
}

class _MenuListItem {
  String title;
  IconData icon;
  MenuOption navOption;
  Color iconColor;

  _MenuListItem(this.icon, this.title, this.navOption, this.iconColor);
}

enum MenuOption {
  MENU_OPTION_MY_TRIPS,
  MENU_OPTION_PAYMENT,
  MENU_OPTION_SETTINGS,
  MENU_OPTION_LANGUAGES,
  MENU_OPTION_CONTACT_US,
  MENU_OPTION_EMERGENCY,
  MENU_OPTION_SIGNOUT,
}
