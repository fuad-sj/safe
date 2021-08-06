import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe/controller/ui_helpers.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/ride_request.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';

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
          title: Text('Order History'),
          actions: <Widget>[]),
      body: ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          RideRequest request = _requests[index];
          return _RideRequestListItem(request: request);
        },
      ),
    );
  }
}

class _RequestStatusResources {
  Color colorBkgnd, colorTxt;
  String txtStatus;

  _RequestStatusResources(
      {required this.colorBkgnd,
      required this.colorTxt,
      required this.txtStatus});
}

class _RideRequestListItem extends StatelessWidget {
  final RideRequest request;

  const _RideRequestListItem({required this.request});

  _RequestStatusResources getResourceForOrderStatus(int requestStatus) {
    Color bkgndColor, txtColor;
    String status;

    switch (requestStatus) {
      case RideRequest.STATUS_PLACED:
        bkgndColor = Colors.teal.shade700;
        txtColor = Colors.grey.shade100;
        status = 'Request Created';
        break;
      case RideRequest.STATUS_DRIVER_CONFIRMED:
        bkgndColor = Colors.teal.shade200;
        txtColor = Colors.grey.shade800;
        status = 'Driver Confirmed';
        break;
      case RideRequest.STATUS_TRIP_STARTED:
        bkgndColor = Colors.teal.shade300;
        txtColor = Colors.grey.shade700;
        status = 'Trip Started';
        break;
      case RideRequest.STATUS_TRIP_COMPLETED:
        bkgndColor = Colors.teal.shade400;
        txtColor = Colors.grey.shade700;
        status = 'Trip Completed';
        break;
      default:
        bkgndColor = Colors.teal.shade100;
        txtColor = Colors.grey.shade900;
        status = 'Request Cancelled';
        break;
    }

    return _RequestStatusResources(
        colorBkgnd: bkgndColor, colorTxt: txtColor, txtStatus: status);
  }

  @override
  Widget build(BuildContext context) {
    FontWeight _bold = FontWeight.bold;

    _RequestStatusResources orderResource =
        getResourceForOrderStatus(request.ride_status);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Order status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(1.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    color: orderResource.colorBkgnd,
                    child: Center(
                      child: Text(orderResource.txtStatus,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: _bold,
                              color: orderResource.colorTxt)),
                    ),
                  ),
                  height: 40,
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date:', style: TextStyle(fontWeight: _bold)),
                    SizedBox(
                      width: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                          //   order.date_created.toString(),
                          AlphaNumericUtil.formatDate(
                              request.date_ride_created)),
                    ),
                  ],
                )
              ],
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
    );
  }
}
