import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe/controller/dialogs/trip_summary_dialog.dart';
import 'package:safe/controller/ui_helpers.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/ride_request.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:widget_mask/widget_mask.dart';

class CustomerOrderHistory extends StatefulWidget {
  const CustomerOrderHistory({Key? key}) : super(key: key);

  @override
  _CustomerOrderHistoryState createState() => _CustomerOrderHistoryState();
}

class _CustomerOrderHistoryState extends State<CustomerOrderHistory> {
  StreamController<List<RideRequest>> _rideRequestsStreamController =
      StreamController<List<RideRequest>>.broadcast();

  List<RideRequest> _requests = [];
  late ImageProvider _defaultDriverProfileImage;

  @override
  void initState() {
    super.initState();
    _setupRequestStream();
  }

  @override
  void didUpdateWidget(covariant CustomerOrderHistory oldWidget) {
    super.didUpdateWidget(oldWidget);

    _setupRequestStream();
  }

  void _setupRequestStream() async {
    _defaultDriverProfileImage = AssetImage('images/mask2.png');

    FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(FIRESTORE_PATHS.SUB_COL_CUSTOMERS_RIDE_HISTORY)
        .orderBy(RideRequest.FIELD_DATE_RIDE_CREATED, descending: true)
        .snapshots()
        .listen((requestSnapshots) {
      if (requestSnapshots.docs.isNotEmpty) {
        var requests = requestSnapshots.docs
            .map((snapshot) => RideRequest.fromSnapshot(snapshot))
            .toList();
        _rideRequestsStreamController.add(requests);
      }
    });

    _rideRequestsStreamController.stream
        .listen((List<RideRequest> fetchedRides) {
      if (mounted) {
        setState(() {
          _requests = fetchedRides;
        });
      }
    });
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
          SafeLocalizations.of(context)!.order_history_title,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontFamily: 'Lato',
              fontSize: 21.0),
        ),
        actions: <Widget>[],
      ),
      body: ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          RideRequest request = _requests[index];
          return _RideRequestListItem(
            request: request,
            defaultDriverProfileImage: _defaultDriverProfileImage,
            onRequestSelected: (RideRequest request) {
              showDialog(
                  context: context,
                  builder: (_) => TripCompletionDialog(rideRequest: request));
            },
          );
        },
      ),
    );
  }
}

class _StatusTextTheme {
  Color colorTxt;
  String txtStatus;

  _StatusTextTheme({required this.colorTxt, required this.txtStatus});
}

class _RideRequestListItem extends StatefulWidget {
  final RideRequest request;
  final Function(RideRequest) onRequestSelected;
  final ImageProvider defaultDriverProfileImage;

  const _RideRequestListItem(
      {Key? key,
      required this.request,
      required this.onRequestSelected,
      required this.defaultDriverProfileImage})
      : super(key: key);

  @override
  State<_RideRequestListItem> createState() => _RideRequestListItemState();
}

class _RideRequestListItemState extends State<_RideRequestListItem> {
  bool _ImgLoadComplete = false;
  late ImageProvider _networkDriverProfileImage;
  late String _driverName;
  late String _carType;
  late String _actualPrice;

  @override
  void initState() {
    super.initState();

    if (widget.request.driver_profile_pic != null) {
      _networkDriverProfileImage =
          NetworkImage(widget.request.driver_profile_pic!);

      _networkDriverProfileImage
          .resolve(new ImageConfiguration())
          .addListener(ImageStreamListener(
            (_, __) {
              _ImgLoadComplete = true;
              setState(() {});
            },
            onError: (_, __) {
              _ImgLoadComplete = false;
              setState(() {});
            },
          ));
    }

    if (widget.request.actual_trip_fare != null) {
      _actualPrice = '${AlphaNumericUtil.formatDouble(widget.request.actual_trip_fare!, 2)}'  + '  ETB';
    } else {
      _actualPrice = 'Cancelled Trip';
    }

    if (widget.request.driver_name != null) {
      _driverName = widget.request.driver_name!;
    } else {
      _driverName = 'Driver Name';
    }

    if (widget.request.car_model != null) {
      _carType = widget.request.car_model!;
    } else {
      _carType = 'Car Model';
    }
  }

  @override
  Widget build(BuildContext context) {
    FontWeight _bold = FontWeight.bold;

    double vHeight = MediaQuery.of(context).size.height;
    double hWidth = MediaQuery.of(context).size.width;

    _StatusTextTheme getStatusTextTheme(int requestStatus) {
      Color txtColor;
      String status;

      if (requestStatus == RideRequest.STATUS_TRIP_COMPLETED) {
        txtColor = Colors.teal.shade900;
        status =
            SafeLocalizations.of(context)!.order_history_order_status_completed;
      } else if (RideRequest.isRideRequestCancelled(requestStatus)) {
        txtColor = Colors.red.shade900;
        status =
            SafeLocalizations.of(context)!.order_history_order_status_cancelled;
      } else {
        txtColor = Colors.blue.shade900;
        status =
            SafeLocalizations.of(context)!.order_history_order_status_started;
      }

      return _StatusTextTheme(colorTxt: txtColor, txtStatus: status);
    }

    TextStyle mainTextFieldStyle() {
      return const TextStyle(
        color: Color.fromRGBO(43, 47, 45, 1),
        fontWeight: FontWeight.w500,
        fontFamily: 'Lato',
        fontSize: 14.0,
      );
    }

    TextStyle secondTextFieldStyle() {
      return const TextStyle(
        color: Color.fromRGBO(144, 145, 144, 1),
        fontWeight: FontWeight.w300,
        fontFamily: 'Lato',
        fontSize: 12.0,
      );
    }

    _StatusTextTheme statusTheme =
        getStatusTextTheme(widget.request.ride_status);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        /*
        if (widget.request.ride_status == RideRequest.STATUS_TRIP_COMPLETED) {
          widget.onRequestSelected(widget.request);
        }

         */
      },
      child: Padding(
        padding: EdgeInsets.only(
            top: 10.0,
            left: hWidth * 0.076,
            right: hWidth * 0.076,
            bottom: vHeight * 0.02),
        child: Container(
          padding: EdgeInsets.only(
              top: vHeight * 0.021,
              left: hWidth * 0.080,
              right: hWidth * 0.050,
              bottom: vHeight * 0.032),
          decoration: BoxDecoration(
              color: Color(0xffF6F6F6),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(2, 4))
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    WidgetMask(
                      blendMode: BlendMode.srcATop,
                      childSaveLayer: true,
                      mask: Image(
                          image: _ImgLoadComplete
                              ? _networkDriverProfileImage
                              : widget.defaultDriverProfileImage,
                          fit: BoxFit.fill),
                      child: Image.asset(
                        'images/mask2.png',
                        width: hWidth * 0.092,
                        height: vHeight * 0.055,
                      ),
                    ),
                    SizedBox(width: hWidth * 0.038),
                    Container(
                      child: Column(
                        children: [
                          Text(
                            _driverName,
                            style: mainTextFieldStyle(),
                          ),
                          Text(_carType, style: secondTextFieldStyle())
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.only(right: hWidth * 0.033),
                      child: Column(
                        children: [
                          Text(
                            AlphaNumericUtil.formatDate(
                                widget.request.date_ride_created),
                            style: mainTextFieldStyle(),
                          ),
                          Text(
                            AlphaNumericUtil.formatTimeVersion(
                                widget.request.date_ride_created),
                            style: secondTextFieldStyle(),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: vHeight * 0.021),
              Container(
                height: vHeight * 0.003,
                width: hWidth * 0.81,
                color: Color.fromRGBO(81, 81, 81, 0.3),
              ),
              SizedBox(height: vHeight * 0.021),
              Container(
                child: Row(
                  children: [
                    Image.asset('images/location.png', height: vHeight * 0.09),
                    SizedBox(width: hWidth * 0.024),
                    Column(
                      children: [
                        Container(
                          width: hWidth * 0.61,
                          child: Text(
                            widget.request.pickup_address_name as String,
                            style: mainTextFieldStyle(),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(height: vHeight * 0.040),
                        Container(
                          width: hWidth * 0.61,
                          child:
                          Text(
                            widget.request.dropoff_address_name.toString(),
                            style: mainTextFieldStyle(),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: vHeight * 0.021),
              Container(
                height: vHeight * 0.003,
                width: hWidth * 0.81,
                color: Color.fromRGBO(81, 81, 81, 0.3),
              ),
              SizedBox(height: vHeight * 0.021),
              Container(
                child: Text(

                  _actualPrice,
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 20.0,
                      color: Color.fromRGBO(211, 0, 0, 1)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
