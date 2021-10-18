import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safe/controller/bottom_sheets/driver_picked_bottom_sheet.dart';
import 'package:safe/controller/bottom_sheets/driver_to_pickup_bottom_sheet.dart';
import 'package:safe/controller/bottom_sheets/searching_for_driver_bottom_sheet.dart';
import 'package:safe/controller/bottom_sheets/confirm_ride_details_bottom_sheet.dart';
import 'package:safe/controller/bottom_sheets/destination_picker_bottom_sheet.dart';
import 'package:safe/controller/bottom_sheets/select_dropoff_pin.dart';
import 'package:safe/controller/bottom_sheets/trip_details_bottom_sheet.dart';
import 'package:safe/controller/bottom_sheets/where_to_bottom_sheet.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/controller/customer_order_history.dart';
import 'package:safe/controller/customer_profile_screen.dart';
import 'package:safe/controller/dialogs/driver_not_found_dialog.dart';
import 'package:safe/controller/dialogs/ride_cancellation_dialog.dart';
import 'package:safe/controller/dialogs/trip_summary_dialog.dart';
import 'package:safe/controller/login_page.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe/controller/payment_screen.dart';
import 'package:safe/controller/settings_screen.dart';
import 'package:safe/controller/ui_helpers.dart';
import 'package:safe/language_selector_dialog.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/models/driver.dart';
import 'package:safe/models/firebase_document.dart';
import 'package:safe/models/google_place_description.dart';
import 'package:safe/models/ride_request.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
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
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';

class MainScreenCustomer extends StatefulWidget {
  static const String idScreen = "mainScreenRider";

  @override
  _MainScreenCustomerState createState() => _MainScreenCustomerState();
}

class _MainScreenCustomerState extends State<MainScreenCustomer>
    with TickerProviderStateMixin {
  static const double DRIVER_RADIUS_KILOMETERS = 10.0;

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
  static const int UI_STATE_DRIVER_NOT_FOUND = 10;
  static const int UI_STATE_NOTICE_DIALOG_SHOWN = 20;

  final PolylinePoints _POLYLINE_POINTS_DECODER = PolylinePoints();
  final Random _RANDOM_GENERATOR = new Random();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GoogleMapController? _mapController;

  bool _geoFireInitialized = false;
  bool _ignoreGeofireUpdates = false;

  int _UIState = UI_STATE_NOTHING_STARTED;

  HashMap<String, DriverLocation> _nearbyDriverLocations =
      HashMap<String, DriverLocation>();

  bool _isHamburgerVisible = true;
  bool _isHamburgerDrawerMode = true;

  final double CAR_ICON_SIZE_RATIO = 0.22;
  final double PIN_ICON_SIZE_RATIO = 0.16;

  BitmapDescriptor? _CAR_ICON;
  BitmapDescriptor? _PICKUP_PIN_ICON;
  BitmapDescriptor? _DROPOFF_PIN_ICON;

  late ImageProvider _defaultProfileImage;
  late ImageProvider _networkProfileImage;
  bool _networkProfileLoaded = false;

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

  String get _getCustomerID => FirebaseAuth.instance.currentUser!.uid;

  bool get isDriverSelected => _selectedDriver != null;

  bool get isDriverGoingToPickup => (_currentRideRequest != null &&
      _currentRideRequest!.ride_status == RideRequest.STATUS_DRIVER_CONFIRMED);

  bool get isTripStarted => (_currentRideRequest != null &&
      _currentRideRequest!.ride_status == RideRequest.STATUS_TRIP_STARTED);

  bool _isInternetWorking = false;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  void setBottomMapPadding(double height) {
    const double MAP_BUFFER_HEIGHT = 5.0 + 15;
    _mapBottomPadding = height + MAP_BUFFER_HEIGHT;
  }

  @override
  void initState() {
    super.initState();

    _defaultProfileImage = AssetImage('images/user_icon.png');

    initConnectivity();

    updateLoginCredentials();

    loadCurrentUserInfo();

    setBottomMapPadding(WhereToBottomSheet.HEIGHT_WHERE_TO_RECOMMENDED_HEIGHT);

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    Future.delayed(Duration.zero, () async {
      loadMapIcons();
      await Geofire.initialize(FIREBASE_DB_PATHS.PATH_VEHICLE_LOCATIONS);
      _geoFireInitialized = true;
    });
  }

  @override
  void dispose() {
    _tripCounterTimer?.cancel();

    if (_geoFireInitialized) {
      Geofire.stopListener();
    }

    _connectivitySubscription.cancel();

    _geofireLocationStream?.cancel();

    super.dispose();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _isInternetWorking = result != ConnectivityResult.none;
    });
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      print(e.toString());
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
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
    _currentCustomer = Customer.fromSnapshot(
      await FirebaseFirestore.instance
          .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(),
    );

    if (!_currentCustomer!.documentExists()) {
      _currentCustomer = null;
    }

    loadNetworkProfileImage();
  }

  void loadNetworkProfileImage() async {
    _networkProfileLoaded = false;
    if (_currentCustomer == null ||
        _currentCustomer!.link_img_profile == null) {
      setState(() {});
      return;
    }

    _networkProfileImage = NetworkImage(_currentCustomer!.link_img_profile!);

    _networkProfileImage
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener(
          (_, __) {
            _networkProfileLoaded = true;
            setState(() {});
          },
          onError: (_, __) {
            _networkProfileLoaded = false;
            setState(() {});
          },
        ));
  }

  void loadMapIcons() async {
    _CAR_ICON = await AlphaNumericUtil.getBytesFromAsset(
        context, 'images/car.png', CAR_ICON_SIZE_RATIO);

    _PICKUP_PIN_ICON = await AlphaNumericUtil.getBytesFromAsset(
        context, 'images/dot_red.png', PIN_ICON_SIZE_RATIO);
    _DROPOFF_PIN_ICON = await AlphaNumericUtil.getBytesFromAsset(
        context, 'images/dot_blue.png', PIN_ICON_SIZE_RATIO);

    _CURRENT_PIN_ICON = Image.asset(
      'images/redmarker.png',
      height: SIZE_CURRENT_PIN_IMAGE,
      width: SIZE_CURRENT_PIN_IMAGE,
    );
  }

  void resetTripDetails() {
    setState(() {
      _UIState = UI_STATE_NOTHING_STARTED;
      _isHamburgerDrawerMode = true;

      setBottomMapPadding(
          WhereToBottomSheet.HEIGHT_WHERE_TO_RECOMMENDED_HEIGHT);

      _mapPolyLines.clear();
      _mapMarkers.clear();

      _ignoreGeofireUpdates = false;

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

      Provider.of<PickUpAndDropOffLocations>(context, listen: false)
          .updatePickupLocationAddress(null);
      Provider.of<PickUpAndDropOffLocations>(context, listen: false)
          .updateDropOffLocationAddress(null);
      Provider.of<PickUpAndDropOffLocations>(context, listen: false)
          .updateScheduledDuration(null);

      updateAvailableDriversOnMap();
    });
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
      case MenuOption.MENU_OPTION_PROFILE:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CustomerOrderHistory()),
        );
        break;
      case MenuOption.MENU_OPTION_MY_TRIPS:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CustomerOrderHistory()),
        );
        break;
      case MenuOption.MENU_OPTION_PAYMENT:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymentScreen()),
        );
        break;
      case MenuOption.MENU_OPTION_SETTINGS:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
        break;

      case MenuOption.MENU_OPTION_LANGUAGES:
        showDialog(
          context: context,
          builder: (_) => LanguageSelectorDialog(),
        );
        break;

      case MenuOption.MENU_OPTION_SIGNOUT:
        FirebaseAuth.instance.signOut();
        Navigator.pushNamedAndRemoveUntil(
            context, LoginPage.idScreen, (route) => false);

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
    return phone;
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
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CustomerProfileScreen()),
                              );

                              _currentCustomer = Customer.fromSnapshot(
                                await FirebaseFirestore.instance
                                    .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
                                    .doc(_getCustomerID)
                                    .get(),
                              );

                              if (!_currentCustomer!.documentExists()) {
                                _currentCustomer = null;
                              }

                              loadNetworkProfileImage();
                            },
                            child: Text(
                                SafeLocalizations.of(context)!
                                    .nav_header_edit_profile,
                                style: TextStyle(color: Colors.blue.shade500)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: Container()),
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: _networkProfileLoaded
                          ? _networkProfileImage
                          : _defaultProfileImage,
                      radius: 30.0,
                    ),
                    SizedBox(width: 16.0),
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

    if (_UIState == UI_STATE_TRIP_COMPLETED ||
        _UIState == UI_STATE_DRIVER_NOT_FOUND) {
      bool isTripCompletionDialog = _UIState == UI_STATE_TRIP_COMPLETED;
      _UIState = UI_STATE_NOTICE_DIALOG_SHOWN;
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
              builder: (_) {
                if (isTripCompletionDialog) {
                  return TripCompletionDialog(
                      rideRequest: _currentRideRequest!);
                } else {
                  return DriverNotFoundDialog();
                }
              });

          resetTripDetails();
        },
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
                setBottomMapPadding(
                    screenHeight * WhereToBottomSheet.HEIGHT_WHERE_TO_PERCENT);
              });

              bool locationAcquired = await zoomCameraToCurrentPosition();

              // start listening to nearby drivers once location is acquired
              if (locationAcquired) {
                await attachGeoFireListener();
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
            enableButtonSelection: _isInternetWorking,
            customerName: _currentCustomer?.user_name,
            actionCallback: () {
              _UIState = UI_STATE_WHERE_TO_SELECTED;

              setBottomMapPadding(screenHeight *
                  DestinationPickerBottomSheet
                      .HEIGHT_DESTINATION_SELECTOR_PERCENT);

              _isHamburgerDrawerMode = false;

              setState(() {});
            },
            onDisabledCallback: () {
              displayToastMessage(
                  SafeLocalizations.of(context)!.generic_message_no_internet,
                  context);
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
              setBottomMapPadding(screenHeight *
                  ConfirmRideDetailsBottomSheet.HEIGHT_RIDE_DETAILS_PERCENT);

              // stop showing nearby drivers
              ignoreGeoFireUpdates();

              setState(() {});
            },
          ),

          if (_UIState == UI_STATE_SELECT_PIN_SELECTED &&
              _CURRENT_PIN_ICON != null &&
              _currentPosition != null) ...[
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
                setBottomMapPadding(screenHeight *
                    ConfirmRideDetailsBottomSheet.HEIGHT_RIDE_DETAILS_PERCENT);

                // stop showing nearby drivers
                ignoreGeoFireUpdates();

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
              if (!_isInternetWorking) {
                displayToastMessage(
                    SafeLocalizations.of(context)!.generic_message_no_internet,
                    context);
              } else {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => CustomProgressDialog(
                      message: SafeLocalizations.of(context)!
                          .main_screen_creating_order_progress),
                );

                _UIState = await createNewRideRequest();

                Navigator.pop(context);

                // Will update UI when either driver is assigned OR trip is cancelled
                await listenToRideStatusUpdates();

                setBottomMapPadding(_UIState == UI_STATE_NOTHING_STARTED
                    ? 0
                    : (screenHeight *
                        SearchingForDriverBottomSheet
                            .HEIGHT_SEARCHING_FOR_DRIVER_PERCENT));

                _isHamburgerDrawerMode = true;
              }

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

  Future<void> listenToRideStatusUpdates() async {
    _rideRequestRef?.snapshots().listen(
      (snapshot) async {
        _currentRideRequest = RideRequest.fromSnapshot(snapshot);

        int rideStatus = _currentRideRequest!.ride_status;

        // driver couldn't be found, or error happened.
        if (rideStatus == RideRequest.STATUS_DRIVER_NOT_FOUND ||
            RideRequest.isRideRequestCancelled(rideStatus)) {
          resetTripDetails();

          if (rideStatus == RideRequest.STATUS_DRIVER_NOT_FOUND) {
            setState(() {
              _UIState = UI_STATE_DRIVER_NOT_FOUND;
            });
          }

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
          // prevent summary dialog being shown multiple times
          if (_UIState != UI_STATE_NOTICE_DIALOG_SHOWN) {
            _UIState = UI_STATE_TRIP_COMPLETED;
          }
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
        double? bottomSheetHeightPercent;

        if (isDriverPicked) {
          pathColor = Color(0xff299bfb);
          encodedPathRoute =
              _currentRideRequest!.driver_to_pickup_encoded_points!;
          lineWidth = 3;

          bottomSheetHeightPercent =
              DriverPickedBottomSheet.HEIGHT_DRIVER_PICKED_PERCENT;
          _isHamburgerVisible = false;

          _UIState = UI_STATE_DRIVER_PICKED;
        } else if (isOnWayToPickup) {
          pathColor = Color(0xff299bfb);
          encodedPathRoute =
              _currentRideRequest!.driver_to_pickup_encoded_points!;
          lineWidth = 5;

          bottomSheetHeightPercent =
              DriverToPickupBottomSheet.HEIGHT_DRIVER_ON_WAY_TO_PICKUP_PERCENT;

          _UIState = UI_STATE_DRIVER_CONFIRMED;
        } else if (hasTripStarted) {
          pathColor = Color(0xff299bfb);
          encodedPathRoute = _currentRideRequest!
              .actual_pickup_to_initial_dropoff_encoded_points!;
          lineWidth = 5;

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

          bottomSheetHeightPercent =
              TripDetailsBottomSheet.HEIGHT_TRIP_DETAILS_PERCENT;
          _UIState = UI_STATE_TRIP_STARTED;
        }

        if (bottomSheetHeightPercent != null) {
          setBottomMapPadding(
              MediaQuery.of(context).size.height * bottomSheetHeightPercent);
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

          _mapMarkers = {
            Marker(
              markerId: MarkerId('pickup id'),
              icon: (hasTripStarted ? _DROPOFF_PIN_ICON : _PICKUP_PIN_ICON) ??
                  BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow),
              infoWindow: InfoWindow(
                  title: hasTripStarted
                      ? _currentRideRequest!.dropoff_address_name
                      : _currentRideRequest!.pickup_address_name,
                  snippet: SafeLocalizations.of(context)!
                      .customer_marker_info_pickup),
              position: hasTripStarted
                  ? _currentRideRequest!.dropoff_location!
                  : _currentRideRequest!.pickup_location!,
            ),
          };
        }

        // cancel any previous driver's location stream
        _selectedDriverCurrentLocation = null;
        _selectedDriverLocationStream?.cancel();
        _selectedDriverLocationStream = FirebaseDatabase.instance
            .reference()
            .child(FIREBASE_DB_PATHS.PATH_VEHICLE_LOCATIONS)
            .child(driverId)
            .onValue
            .listen(
          (locSnapshot) {
            bool firstTimeLocationAcquired =
                _selectedDriverCurrentLocation == null;
            _selectedDriverCurrentLocation =
                DriverLocation.fromSnapshot(locSnapshot.snapshot);

            bool has_trip_started = _currentRideRequest!.ride_status ==
                RideRequest.STATUS_TRIP_STARTED;
            if (firstTimeLocationAcquired) {
              zoomCameraToWithinBounds(
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                has_trip_started
                    ? _currentRideRequest!.dropoff_location!
                    : _selectedDriverCurrentLocation!.getLocationLatLng,
                110,
              );
            }

            _mapMarkers = {
              // Car live locations
              Marker(
                markerId: MarkerId(
                    'driver${_selectedDriverCurrentLocation!.driverID}'),
                position: LatLng(_selectedDriverCurrentLocation!.latitude,
                    _selectedDriverCurrentLocation!.longitude),
                icon: _CAR_ICON ?? BitmapDescriptor.defaultMarker,
                rotation: 0,
              ),

              // Pickup | Dropoff pins
              Marker(
                markerId: MarkerId('pickup id'),
                icon:
                    (has_trip_started ? _DROPOFF_PIN_ICON : _PICKUP_PIN_ICON) ??
                        BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueYellow),
                infoWindow: InfoWindow(
                    title: has_trip_started
                        ? _currentRideRequest!.dropoff_address_name
                        : _currentRideRequest!.pickup_address_name,
                    snippet: SafeLocalizations.of(context)!
                        .customer_marker_info_pickup),
                position: has_trip_started
                    ? _currentRideRequest!.dropoff_location!
                    : _currentRideRequest!.pickup_location!,
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

      Address address = await GoogleApiUtils.searchCoordinateAddress(position);

      Provider.of<PickUpAndDropOffLocations>(context, listen: false)
          .updatePickupLocationAddress(address);
      return true;
    } catch (err) {}

    return false;
  }

  Future<int> createNewRideRequest() async {
    Address pickUpAddress =
        Provider.of<PickUpAndDropOffLocations>(context, listen: false)
            .pickUpLocation!;
    Address dropOffAddress =
        Provider.of<PickUpAndDropOffLocations>(context, listen: false)
            .dropOffLocation!;
    Duration? scheduledDuration =
        Provider.of<PickUpAndDropOffLocations>(context, listen: false)
            .scheduledDuration;
    bool isStudent =
        Provider.of<PickUpAndDropOffLocations>(context, listen: false)
                .isStudent ??
            false;

    Map<String, dynamic> rideFields = new Map();

    rideFields[RideRequest.FIELD_RIDE_STATUS] = RideRequest.STATUS_PLACED;
    rideFields[RideRequest.FIELD_CUSTOMER_ID] = PrefUtil.getCurrentUserID();
    rideFields[RideRequest.FIELD_CUSTOMER_NAME] = _currentCustomer!.user_name!;
    rideFields[RideRequest.FIELD_CUSTOMER_PHONE] =
        _currentCustomer!.phone_number!;
    rideFields[RideRequest.FIELD_CUSTOMER_DEVICE_TOKEN] =
        await FirebaseMessaging.instance.getToken();
    rideFields[RideRequest.FIELD_CUSTOMER_EMAIL] =
        _currentCustomer!.email ?? '';
    rideFields[RideRequest.FIELD_PICKUP_LOCATION] =
        FirebaseDocument.LatLngToJson(pickUpAddress.location);
    rideFields[RideRequest.FIELD_PICKUP_ADDRESS_NAME] = pickUpAddress.placeName;
    rideFields[RideRequest.FIELD_DROPOFF_LOCATION] =
        FirebaseDocument.LatLngToJson(dropOffAddress.location);
    rideFields[RideRequest.FIELD_DROPOFF_ADDRESS_NAME] =
        dropOffAddress.placeName;
    rideFields[RideRequest.FIELD_DATE_RIDE_CREATED] =
        FieldValue.serverTimestamp();
    rideFields[RideRequest.FIELD_IS_STUDENT] = isStudent;
    rideFields[RideRequest.FIELD_IS_SCHEDULED] = scheduledDuration != null;
    if (scheduledDuration != null) {
      rideFields[RideRequest.FIELD_SCHEDULED_AFTER_SECONDS] =
          scheduledDuration.inSeconds;
    }

    _rideRequestRef = await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_RIDES)
        .add(rideFields);

    return scheduledDuration != null
        ? UI_STATE_NOTHING_STARTED
        : UI_STATE_SEARCHING_FOR_DRIVER;
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
        _pickupToDropOffRouteDetail!.dropOffLoc, 150);
  }

  void zoomCameraToWithinBounds(
      LatLng startLoc, LatLng finalLoc, double padding) {
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
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, padding));
  }

  Future<void> attachGeoFireListener() async {
    final String FIELD_CALLBACK = 'callBack';
    final String FIELD_KEY = 'key';
    final String FIELD_LATITUDE = 'latitude';
    final String FIELD_LONGITUDE = 'longitude';

    _isNearbyDriverLoadingComplete = false;

    _geofireLocationStream = Geofire.queryAtLocation(_currentPosition!.latitude,
            _currentPosition!.longitude, DRIVER_RADIUS_KILOMETERS)
        ?.listen(
      (map) async {
        if (map == null || _ignoreGeofireUpdates) {
          return;
        }

        var callBack = map[FIELD_CALLBACK];

        switch (callBack) {
          case Geofire.onKeyEntered:
            setDriverLocationAndBearing(
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
            _nearbyDriverLocations.remove(driver_ID);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            setDriverLocationAndBearing(
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

        setState(() {});
      },
    );
  }

  void ignoreGeoFireUpdates() {
    _ignoreGeofireUpdates = true;
  }

  void updateAvailableDriversOnMap() {
    _mapMarkers = _nearbyDriverLocations.values
        .map((driver) => Marker(
              markerId: MarkerId('driver${driver.driverID}'),
              position: LatLng(driver.latitude, driver.longitude),
              icon: _CAR_ICON ?? BitmapDescriptor.defaultMarker,
              rotation: driver.orientation ?? 0,
            ))
        .toSet();
  }

  void setDriverLocationAndBearing(DriverLocation driverLoc) {
    if (_nearbyDriverLocations.containsKey(driverLoc.driverID)) {
      DriverLocation prevLocation = _nearbyDriverLocations[driverLoc.driverID]!;

      double angle = Geolocator.bearingBetween(prevLocation.latitude,
          prevLocation.longitude, driverLoc.latitude, driverLoc.longitude);

      if (angle < 0) angle += 360.0;
      angle += 90.0;
      if (angle > 360.0) angle -= 360.0;

      driverLoc.orientation = angle;
    } else {
      driverLoc.orientation =
          _RANDOM_GENERATOR.nextDouble() * 360.0; // start off @ a random angle
    }

    _nearbyDriverLocations[driverLoc.driverID] = driverLoc;
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
  MENU_OPTION_PROFILE,
  MENU_OPTION_MY_TRIPS,
  MENU_OPTION_PAYMENT,
  MENU_OPTION_SETTINGS,
  MENU_OPTION_LANGUAGES,
  MENU_OPTION_CONTACT_US,
  MENU_OPTION_EMERGENCY,
  MENU_OPTION_SIGNOUT,
}
