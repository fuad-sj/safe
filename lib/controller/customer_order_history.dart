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

class CustomerOrderHistory extends StatefulWidget {
  const CustomerOrderHistory({Key? key}) : super(key: key);

  @override
  _CustomerOrderHistoryState createState() => _CustomerOrderHistoryState();
}

class _CustomerOrderHistoryState extends State<CustomerOrderHistory> {
  StreamController<List<RideRequest>> _rideRequestsStreamController =
      StreamController<List<RideRequest>>.broadcast();

  List<RideRequest> _requests = [];

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
      appBar: new AppBar(
          backgroundColor: Color(0xfe7a110a),
          elevation: 0.0,
          leading: new BackButton(color: Colors.black),
          title: Text(SafeLocalizations.of(context)!.order_history_title),
          actions: <Widget>[]),
      body: ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          RideRequest request = _requests[index];
          return _RideRequestListItem(
            request: request,
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

class _RideRequestListItem extends StatelessWidget {
  final RideRequest request;
  final Function(RideRequest) onRequestSelected;

  const _RideRequestListItem(
      {required this.request, required this.onRequestSelected});

  @override
  Widget build(BuildContext context) {
    FontWeight _bold = FontWeight.bold;

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

    _StatusTextTheme statusTheme = getStatusTextTheme(request.ride_status);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (request.ride_status == RideRequest.STATUS_TRIP_COMPLETED) {
          onRequestSelected(request);
        }
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(statusTheme.txtStatus,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: _bold,
                          color: statusTheme.colorTxt,
                          fontSize: 14.0)),
                  if (request.ride_status ==
                      RideRequest.STATUS_TRIP_COMPLETED) ...[
                    Expanded(child: Container()),
                    Icon(Icons.double_arrow),
                  ],
                ],
              ),
              Text(
                AlphaNumericUtil.formatDateLongVersion(request.date_ride_created),
                style: TextStyle(color: Colors.grey.shade700, fontSize: 10.0),
              ),

              // Pickup
              SizedBox(height: 25.0),
              Row(
                children: [
                  Image.asset('images/dot_red.png', height: 16.0, width: 16.0),
                  SizedBox(width: 18.0),
                  Text(request.pickup_address_name),
                ],
              ),
              SizedBox(height: 10.0),
              greyVerticalDivider(0.3),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Image.asset('images/dot_blue.png', height: 16.0, width: 16.0),
                  SizedBox(width: 18.0),
                  Text(request.dropoff_address_name),
                ],
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
